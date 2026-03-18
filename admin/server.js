require('dotenv').config();
const express = require('express');
const session = require('express-session');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Database pool
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
  secret: process.env.SESSION_SECRET || 'radar-floro-secret',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 24 * 60 * 60 * 1000 }, // 24h
}));

// Serve images from data directory
const dataDir = path.join(__dirname, '..', 'data');
app.use('/images/photos', express.static(path.join(dataDir, 'photos')));
app.use('/images/caricatures', express.static(path.join(dataDir, 'caricatures')));
app.use('/images/logos', express.static(path.join(dataDir, 'logos')));

// Multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const type = req.params.type; // 'photo' or 'caricature'
    const dir = type === 'photo'
      ? path.join(dataDir, 'photos')
      : path.join(dataDir, 'caricatures');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const id = req.params.id;
    const ext = type === 'photo' ? '.jpg' : '.png';
    cb(null, id + ext);
  },
});

function createUpload(type) {
  return multer({
    storage: multer.diskStorage({
      destination: (req, file, cb) => {
        const dir = type === 'photo'
          ? path.join(dataDir, 'photos')
          : path.join(dataDir, 'caricatures');
        fs.mkdirSync(dir, { recursive: true });
        cb(null, dir);
      },
      filename: (req, file, cb) => {
        const id = req.params.id;
        const ext = type === 'photo' ? '.jpg' : '.png';
        cb(null, id + ext);
      },
    }),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: (req, file, cb) => {
      if (file.mimetype.startsWith('image/')) cb(null, true);
      else cb(new Error('Solo se permiten imágenes'));
    },
  });
}

const uploadPhoto = createUpload('photo');
const uploadCaricature = createUpload('caricature');

// ─── Auth middleware ───
function requireAuth(req, res, next) {
  if (req.session && req.session.authenticated) return next();
  if (req.headers.accept && req.headers.accept.includes('json')) {
    return res.status(401).json({ error: 'No autenticado' });
  }
  res.redirect('/admin/login');
}

// ─── PUBLIC API ───

// GET /api/candidates - all candidates (for Flutter)
app.get('/api/candidates', async (req, res) => {
  try {
    const { cargo, partido, search } = req.query;
    let query = 'SELECT * FROM candidates WHERE 1=1';
    const params = [];

    if (cargo) {
      params.push(cargo);
      query += ` AND cargo = $${params.length}`;
    }
    if (partido) {
      params.push(partido);
      query += ` AND partido = $${params.length}`;
    }
    if (search) {
      params.push(`%${search}%`);
      query += ` AND nombre ILIKE $${params.length}`;
    }

    query += ' ORDER BY nombre';
    const result = await pool.query(query, params);
    res.json({ cards: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/candidates/:id
app.get('/api/candidates/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM candidates WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'No encontrado' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── ADMIN AUTH ───

app.get('/admin/login', (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'login.html'));
});

app.post('/admin/login', (req, res) => {
  const { password } = req.body;
  if (password === process.env.ADMIN_PASSWORD) {
    req.session.authenticated = true;
    res.redirect('/admin/dashboard');
  } else {
    res.redirect('/admin/login?error=1');
  }
});

app.get('/admin/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/admin/login');
});

// ─── ADMIN PANEL ───

app.get('/admin/dashboard', requireAuth, async (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'dashboard.html'));
});

// API for dashboard (paginated list)
app.get('/admin/api/candidates', requireAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;
    const { cargo, search } = req.query;

    let where = 'WHERE 1=1';
    const params = [];

    if (cargo && cargo !== 'TODOS') {
      params.push(cargo);
      where += ` AND cargo = $${params.length}`;
    }
    if (search) {
      params.push(`%${search}%`);
      where += ` AND (nombre ILIKE $${params.length} OR partido ILIKE $${params.length})`;
    }

    const countResult = await pool.query(`SELECT COUNT(*) FROM candidates ${where}`, params);
    const total = parseInt(countResult.rows[0].count);

    params.push(limit, offset);
    const result = await pool.query(
      `SELECT id, nombre, partido, cargo, region, indice_floro, nivel, foto, caricatura
       FROM candidates ${where}
       ORDER BY nombre
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );

    res.json({ candidates: result.rows, total, page, pages: Math.ceil(total / limit) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Edit page
app.get('/admin/candidates/:id/edit', requireAuth, (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'edit.html'));
});

// Get candidate data for edit form
app.get('/admin/api/candidates/:id', requireAuth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM candidates WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'No encontrado' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update candidate
app.post('/admin/api/candidates/:id', requireAuth, async (req, res) => {
  try {
    const b = req.body;
    await pool.query(`
      UPDATE candidates SET
        nombre = $2, partido = $3, cargo = $4, region = $5, dni = $6,
        frase = $7, senales = $8, antecedentes = $9, controversias = $10,
        pension_alimenticia = $11, procesos_judiciales = $12, cambios_partido = $13,
        indice_floro = $14, puntajes = $15, nivel = $16, nivel_riesgo = $17,
        respuesta_ideal = $18, patron_dominante = $19, frase_narrador = $20,
        fuentes = $21, link_jne = $22, updated_at = NOW()
      WHERE id = $1
    `, [
      req.params.id,
      b.nombre, b.partido || null, b.cargo, b.region || null, b.dni || null,
      b.frase || null,
      b.senales || [], b.antecedentes || [], b.controversias || [],
      b.pension_alimenticia || null, b.procesos_judiciales || [], b.cambios_partido || [],
      parseInt(b.indice_floro) || 0, JSON.stringify(b.puntajes || {}),
      b.nivel || null, b.nivel_riesgo || null, b.respuesta_ideal || null,
      b.patron_dominante || null, b.frase_narrador || null,
      b.fuentes || [], b.link_jne || null,
    ]);
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create candidate
app.get('/admin/candidates/new', requireAuth, (req, res) => {
  res.sendFile(path.join(__dirname, 'views', 'edit.html'));
});

app.post('/admin/api/candidates', requireAuth, async (req, res) => {
  try {
    const b = req.body;
    const id = b.nombre.toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');

    await pool.query(`
      INSERT INTO candidates (
        id, nombre, partido, cargo, region, dni, frase,
        senales, antecedentes, controversias, pension_alimenticia,
        procesos_judiciales, cambios_partido, indice_floro, puntajes,
        nivel, nivel_riesgo, respuesta_ideal, patron_dominante,
        frase_narrador, fuentes, link_jne
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, $11,
        $12, $13, $14, $15,
        $16, $17, $18, $19,
        $20, $21, $22
      )
    `, [
      id, b.nombre, b.partido || null, b.cargo, b.region || null, b.dni || null,
      b.frase || null,
      b.senales || [], b.antecedentes || [], b.controversias || [],
      b.pension_alimenticia || null, b.procesos_judiciales || [], b.cambios_partido || [],
      parseInt(b.indice_floro) || 0, JSON.stringify(b.puntajes || {}),
      b.nivel || null, b.nivel_riesgo || null, b.respuesta_ideal || null,
      b.patron_dominante || null, b.frase_narrador || null,
      b.fuentes || [], b.link_jne || null,
    ]);
    res.json({ ok: true, id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete candidate
app.delete('/admin/api/candidates/:id', requireAuth, async (req, res) => {
  try {
    await pool.query('DELETE FROM candidates WHERE id = $1', [req.params.id]);
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Upload photo
app.post('/admin/api/candidates/:id/photo', requireAuth, uploadPhoto.single('image'), async (req, res) => {
  try {
    const fotoPath = `photos/${req.params.id}.jpg`;
    await pool.query('UPDATE candidates SET foto = $1, updated_at = NOW() WHERE id = $2', [fotoPath, req.params.id]);
    res.json({ ok: true, path: fotoPath });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Upload caricature
app.post('/admin/api/candidates/:id/caricature', requireAuth, uploadCaricature.single('image'), async (req, res) => {
  try {
    const caricPath = `caricatures/${req.params.id}.png`;
    await pool.query('UPDATE candidates SET caricatura = $1, updated_at = NOW() WHERE id = $2', [caricPath, req.params.id]);
    res.json({ ok: true, path: caricPath });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Stats
app.get('/admin/api/stats', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) as total,
        COUNT(CASE WHEN foto IS NOT NULL THEN 1 END) as con_foto,
        COUNT(CASE WHEN caricatura IS NOT NULL THEN 1 END) as con_caricatura,
        COUNT(CASE WHEN array_length(controversias, 1) > 0 THEN 1 END) as con_controversias
      FROM candidates
    `);
    const cargos = await pool.query(`SELECT cargo, COUNT(*) as count FROM candidates GROUP BY cargo ORDER BY cargo`);
    res.json({ ...result.rows[0], por_cargo: cargos.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start
app.listen(PORT, () => {
  console.log(`Admin panel: http://localhost:${PORT}/admin/dashboard`);
  console.log(`API: http://localhost:${PORT}/api/candidates`);
});
