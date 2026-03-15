/**
 * Script 03: Descarga de fotos y extraccion de Hojas de Vida
 *
 * Lee candidates.json, descarga fotos y PDFs de Hoja de Vida,
 * y extrae informacion estructurada de los PDFs.
 *
 * Uso: node scripts/03_download_assets.js [--limit 10] [--skip-pdf] [--skip-photo]
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

const CANDIDATES_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const DETAILED_FILE = path.join(__dirname, '..', 'data', 'candidates_detailed.json');
const PHOTOS_DIR = path.join(__dirname, '..', 'data', 'photos');
const PDF_DIR = path.join(__dirname, '..', 'data', 'hojas-vida');

const args = process.argv.slice(2);
const LIMIT = args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) : 0;
const SKIP_PDF = args.includes('--skip-pdf');
const SKIP_PHOTO = args.includes('--skip-photo');

async function downloadAssets() {
  console.log('=== Descarga de Fotos y Hojas de Vida ===\n');

  if (!fs.existsSync(CANDIDATES_FILE)) {
    console.log('Error: No existe candidates.json. Ejecuta primero: npm run scrape');
    process.exit(1);
  }

  const { candidates } = JSON.parse(fs.readFileSync(CANDIDATES_FILE, 'utf8'));
  const toProcess = LIMIT > 0 ? candidates.slice(0, LIMIT) : candidates;
  console.log(`Candidatos a procesar: ${toProcess.length}\n`);

  const detailed = [];
  let photoCount = 0;
  let pdfCount = 0;
  let errorCount = 0;

  for (let i = 0; i < toProcess.length; i++) {
    const candidate = toProcess[i];
    const id = candidate.dni || slugify(candidate.nombre) || `candidato_${i}`;
    console.log(`[${i + 1}/${toProcess.length}] ${candidate.nombre || id}`);

    const detail = { ...candidate };

    // Descargar foto
    if (!SKIP_PHOTO && candidate.foto) {
      const photoPath = path.join(PHOTOS_DIR, `${id}.jpg`);
      if (!fs.existsSync(photoPath)) {
        try {
          await downloadFile(candidate.foto, photoPath);
          detail.photoLocal = `photos/${id}.jpg`;
          photoCount++;
          console.log(`  Foto descargada`);
        } catch (e) {
          console.log(`  Error foto: ${e.message}`);
          errorCount++;
        }
      } else {
        detail.photoLocal = `photos/${id}.jpg`;
        console.log(`  Foto ya existe`);
      }
    }

    // Descargar Hoja de Vida PDF
    if (!SKIP_PDF && candidate.hojaVida) {
      const pdfPath = path.join(PDF_DIR, `${id}.pdf`);
      if (!fs.existsSync(pdfPath)) {
        try {
          await downloadFile(candidate.hojaVida, pdfPath);
          detail.pdfLocal = `hojas-vida/${id}.pdf`;
          pdfCount++;
          console.log(`  PDF descargado`);
        } catch (e) {
          console.log(`  Error PDF: ${e.message}`);
          errorCount++;
        }
      } else {
        detail.pdfLocal = `hojas-vida/${id}.pdf`;
        console.log(`  PDF ya existe`);
      }

      // Extraer datos del PDF
      if (detail.pdfLocal && fs.existsSync(path.join(__dirname, '..', 'data', detail.pdfLocal))) {
        try {
          const pdfData = await extractPdfData(path.join(__dirname, '..', 'data', detail.pdfLocal));
          detail.hojaVidaData = pdfData;
          console.log(`  PDF procesado: ${Object.keys(pdfData).length} secciones`);
        } catch (e) {
          console.log(`  Error procesando PDF: ${e.message}`);
        }
      }
    }

    detailed.push(detail);

    // Rate limiting (200ms entre descargas)
    await sleep(200);
  }

  // Guardar resultados
  const output = {
    processedAt: new Date().toISOString(),
    total: detailed.length,
    photosDownloaded: photoCount,
    pdfsDownloaded: pdfCount,
    errors: errorCount,
    candidates: detailed
  };

  fs.writeFileSync(DETAILED_FILE, JSON.stringify(output, null, 2));

  console.log(`\n=== Resumen ===`);
  console.log(`Candidatos procesados: ${detailed.length}`);
  console.log(`Fotos descargadas: ${photoCount}`);
  console.log(`PDFs descargados: ${pdfCount}`);
  console.log(`Errores: ${errorCount}`);
  console.log(`Guardado en: ${DETAILED_FILE}`);
}

async function extractPdfData(pdfPath) {
  let pdfParse;
  try {
    pdfParse = require('pdf-parse');
  } catch {
    console.log('  pdf-parse no instalado, saltando extraccion');
    return { error: 'pdf-parse not installed' };
  }

  const buffer = fs.readFileSync(pdfPath);
  const data = await pdfParse(buffer);
  const text = data.text;

  // Extraer secciones de la Hoja de Vida del JNE
  const sections = {};

  // Datos personales
  sections.datosPersonales = extractSection(text, [
    'DATOS PERSONALES', 'I. DATOS PERSONALES'
  ], ['II.', 'FORMACION', 'EDUCACION']);

  // Formacion academica
  sections.formacion = extractSection(text, [
    'FORMACION ACADEMICA', 'II. FORMACION', 'EDUCACION'
  ], ['III.', 'EXPERIENCIA', 'TRAYECTORIA']);

  // Experiencia laboral
  sections.experiencia = extractSection(text, [
    'EXPERIENCIA LABORAL', 'EXPERIENCIA DE TRABAJO', 'III. EXPERIENCIA'
  ], ['IV.', 'TRAYECTORIA', 'INGRESOS', 'SENTENCIA']);

  // Trayectoria partidaria
  sections.trayectoriaPartidaria = extractSection(text, [
    'TRAYECTORIA PARTIDARIA', 'TRAYECTORIA POLITICA', 'ORGANIZACIONES POLITICAS'
  ], ['V.', 'SENTENCIA', 'INGRESOS', 'BIENES']);

  // Sentencias / Antecedentes penales
  sections.sentencias = extractSection(text, [
    'SENTENCIA', 'ANTECEDENTES', 'CONDENA', 'PENAL'
  ], ['VI.', 'INGRESOS', 'BIENES', 'DECLARACION']);

  // Ingresos y bienes
  sections.ingresos = extractSection(text, [
    'INGRESOS', 'REMUNERACION', 'RENTA'
  ], ['VII.', 'BIENES', 'INMUEBLES']);

  sections.bienes = extractSection(text, [
    'BIENES', 'INMUEBLES', 'MUEBLES', 'PATRIMONIO'
  ], ['VIII.', 'DECLARACION', 'OBSERVACION']);

  // Detectar banderas rojas
  sections.banderasRojas = detectRedFlags(text);

  // Contar partidos (reciclaje politico)
  sections.cantidadPartidos = countParties(text);

  return sections;
}

function extractSection(text, startKeywords, endKeywords) {
  const upperText = text.toUpperCase();
  let startIdx = -1;

  for (const keyword of startKeywords) {
    const idx = upperText.indexOf(keyword.toUpperCase());
    if (idx !== -1) {
      startIdx = idx;
      break;
    }
  }

  if (startIdx === -1) return null;

  let endIdx = text.length;
  for (const keyword of endKeywords) {
    const idx = upperText.indexOf(keyword.toUpperCase(), startIdx + 10);
    if (idx !== -1 && idx < endIdx) {
      endIdx = idx;
    }
  }

  return text.substring(startIdx, endIdx).trim();
}

function detectRedFlags(text) {
  const flags = [];
  const upperText = text.toUpperCase();

  const patterns = [
    { pattern: /SENTENCIA.{0,50}(CONDENATORIA|PENAL|PRISION)/i, flag: 'Sentencia condenatoria' },
    { pattern: /PENSION.{0,30}ALIMENT/i, flag: 'Pension alimenticia' },
    { pattern: /HOMICIDIO|ASESINATO/i, flag: 'Homicidio' },
    { pattern: /LAVADO.{0,20}ACTIVOS/i, flag: 'Lavado de activos' },
    { pattern: /CORRUPCION|PECULADO|COHECHO/i, flag: 'Corrupcion' },
    { pattern: /NARCOTRAFICO|DROGAS/i, flag: 'Narcotrafico' },
    { pattern: /VIOLENCIA.{0,20}(FAMILIAR|GENERO|MUJER)/i, flag: 'Violencia familiar/genero' },
    { pattern: /PROCESO.{0,30}JUDICIAL/i, flag: 'Proceso judicial activo' },
    { pattern: /INVESTIGACION.{0,30}FISCAL/i, flag: 'Investigacion fiscal' },
    { pattern: /DEUDA.{0,20}(TRIBUTARIA|SUNAT)/i, flag: 'Deuda tributaria' },
    { pattern: /NO DECLARA|SIN INFORMACION/i, flag: 'Informacion no declarada' },
  ];

  for (const { pattern, flag } of patterns) {
    if (pattern.test(text)) {
      flags.push(flag);
    }
  }

  return flags;
}

function countParties(text) {
  // Buscar nombres de partidos mencionados
  const partyPatterns = [
    /FUERZA POPULAR/gi, /ALIANZA PARA EL PROGRESO/gi, /ACCION POPULAR/gi,
    /RENOVACION POPULAR/gi, /PERU LIBRE/gi, /PODEMOS PERU/gi,
    /AVANZA PAIS/gi, /SOMOS PERU/gi, /PARTIDO MORADO/gi,
    /APP/gi, /APRA/gi, /FRENTE AMPLIO/gi, /UNION POR EL PERU/gi,
  ];

  const found = new Set();
  for (const pattern of partyPatterns) {
    if (pattern.test(text)) {
      found.add(pattern.source.replace(/\\s\+/g, ' '));
    }
  }

  return found.size;
}

function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(destPath);

    protocol.get(url, { timeout: 30000 }, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        file.close();
        fs.unlinkSync(destPath);
        return downloadFile(response.headers.location, destPath).then(resolve).catch(reject);
      }

      if (response.statusCode !== 200) {
        file.close();
        fs.unlinkSync(destPath);
        return reject(new Error(`HTTP ${response.statusCode}`));
      }

      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
      file.on('error', (err) => { fs.unlinkSync(destPath); reject(err); });
    }).on('error', (err) => {
      file.close();
      if (fs.existsSync(destPath)) fs.unlinkSync(destPath);
      reject(err);
    });
  });
}

function slugify(text) {
  if (!text) return null;
  return text.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // remove accents
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .substring(0, 60);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

downloadAssets().catch(err => {
  console.error('Error fatal:', err);
  process.exit(1);
});
