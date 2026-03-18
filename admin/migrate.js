require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DB_NAME = process.env.DB_NAME || 'radarfloro';

async function createDatabase() {
  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'postgres',
  });
  await client.connect();
  const res = await client.query(`SELECT 1 FROM pg_database WHERE datname = $1`, [DB_NAME]);
  if (res.rowCount === 0) {
    await client.query(`CREATE DATABASE ${DB_NAME}`);
    console.log(`Database "${DB_NAME}" created.`);
  } else {
    console.log(`Database "${DB_NAME}" already exists.`);
  }
  await client.end();
}

async function createSchema(client) {
  await client.query(`
    CREATE TABLE IF NOT EXISTS candidates (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      partido TEXT,
      cargo TEXT NOT NULL,
      region TEXT,
      dni TEXT,
      frase TEXT,
      senales TEXT[] DEFAULT '{}',
      antecedentes TEXT[] DEFAULT '{}',
      controversias TEXT[] DEFAULT '{}',
      pension_alimenticia TEXT,
      procesos_judiciales TEXT[] DEFAULT '{}',
      cambios_partido TEXT[] DEFAULT '{}',
      indice_floro INTEGER DEFAULT 0,
      puntajes JSONB DEFAULT '{}',
      nivel TEXT,
      nivel_riesgo TEXT,
      respuesta_ideal TEXT,
      patron_dominante TEXT,
      frase_narrador TEXT,
      fuentes TEXT[] DEFAULT '{}',
      link_jne TEXT,
      foto TEXT,
      caricatura TEXT,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    CREATE INDEX IF NOT EXISTS idx_candidates_cargo ON candidates(cargo);
    CREATE INDEX IF NOT EXISTS idx_candidates_partido ON candidates(partido);
    CREATE INDEX IF NOT EXISTS idx_candidates_nombre ON candidates USING gin(to_tsvector('spanish', nombre));
  `);
  console.log('Schema created.');
}

function toArray(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  return [val];
}

async function importData(client) {
  const dataPath = path.join(__dirname, '..', 'data', 'game_data.json');
  const raw = fs.readFileSync(dataPath, 'utf-8');
  const data = JSON.parse(raw);
  const cards = data.cards;

  console.log(`Importing ${cards.length} candidates...`);

  // Use a transaction for speed
  await client.query('BEGIN');

  // Clear existing data
  await client.query('DELETE FROM candidates');

  let count = 0;
  for (const c of cards) {
    await client.query(`
      INSERT INTO candidates (
        id, nombre, partido, cargo, region, dni, frase,
        senales, antecedentes, controversias, pension_alimenticia,
        procesos_judiciales, cambios_partido, indice_floro, puntajes,
        nivel, nivel_riesgo, respuesta_ideal, patron_dominante,
        frase_narrador, fuentes, link_jne, foto, caricatura
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, $11,
        $12, $13, $14, $15,
        $16, $17, $18, $19,
        $20, $21, $22, $23, $24
      )
      ON CONFLICT (id) DO UPDATE SET
        nombre = EXCLUDED.nombre,
        partido = EXCLUDED.partido,
        cargo = EXCLUDED.cargo,
        updated_at = NOW()
    `, [
      c.id,
      c.nombre,
      c.partido || null,
      c.cargo,
      c.region || null,
      c.dni || null,
      c.frase || null,
      toArray(c.senales),
      toArray(c.antecedentes),
      toArray(c.controversias),
      c.pensionAlimenticia || null,
      toArray(c.procesosJudiciales),
      toArray(c.cambiosPartido),
      c.indiceFloro || 0,
      JSON.stringify(c.puntajes || {}),
      c.nivel || null,
      c.nivelRiesgo || null,
      c.respuestaIdeal || null,
      c.patronDominante || null,
      c.fraseNarrador || null,
      toArray(c.fuentes),
      c.linkJNE || null,
      c.foto || null,
      c.caricatura || null,
    ]);
    count++;
    if (count % 500 === 0) console.log(`  ${count}/${cards.length}...`);
  }

  await client.query('COMMIT');
  console.log(`Done. ${count} candidates imported.`);
}

async function main() {
  try {
    await createDatabase();

    const client = new Client({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: DB_NAME,
    });
    await client.connect();
    await createSchema(client);
    await importData(client);
    await client.end();
    console.log('Migration complete!');
  } catch (err) {
    console.error('Migration failed:', err.message);
    process.exit(1);
  }
}

main();
