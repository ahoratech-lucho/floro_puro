/**
 * Script 04: Busqueda de controversias en web
 *
 * MODO GRATIS: Solo hace busquedas en Google con Puppeteer y guarda
 * los resultados crudos. El analisis lo hace Claude Code despues
 * (gratis con tu Plan Max).
 *
 * Uso:
 *   node scripts/04_search_controversies.js [--limit 10]
 *
 * Despues de ejecutar, usa el Script 04b para que Claude Code
 * analice los resultados guardados.
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const DETAILED_FILE = path.join(__dirname, '..', 'data', 'candidates_detailed.json');
const CANDIDATES_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const SEARCH_DIR = path.join(__dirname, '..', 'data', 'search_results');
const CONTROVERSIES_DIR = path.join(__dirname, '..', 'data', 'controversies');

// Crear directorio de resultados de busqueda
if (!fs.existsSync(SEARCH_DIR)) fs.mkdirSync(SEARCH_DIR, { recursive: true });

const args = process.argv.slice(2);
const LIMIT = args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) : 0;
const FILTER = args.includes('--filter') ? args[args.indexOf('--filter') + 1] : null;
// --filter options: 'presidentes', 'huanuco', 'presidentes+huanuco'

function slugify(text) {
  if (!text) return null;
  return text.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .substring(0, 60);
}

async function searchControversies() {
  console.log('=== Busqueda de Controversias (Modo Gratis) ===');
  console.log('Solo busqueda web. El analisis con IA lo hace Claude Code despues.\n');

  // Cargar candidatos
  let candidates;
  if (fs.existsSync(DETAILED_FILE)) {
    candidates = JSON.parse(fs.readFileSync(DETAILED_FILE, 'utf8')).candidates;
  } else if (fs.existsSync(CANDIDATES_FILE)) {
    candidates = JSON.parse(fs.readFileSync(CANDIDATES_FILE, 'utf8')).candidates;
  } else {
    console.log('Error: No hay datos de candidatos. Ejecuta primero los scripts anteriores.');
    process.exit(1);
  }

  // Filtrar por categoria si se especifica
  let filtered = candidates;
  if (FILTER) {
    const filters = FILTER.toLowerCase().split('+');
    filtered = candidates.filter(c => {
      if (filters.includes('presidentes') && c.cargo === 'PRESIDENTE') return true;
      if (filters.includes('huanuco') && c.region === 'HUANUCO') return true;
      return false;
    });
    console.log(`Filtro: ${FILTER} -> ${filtered.length} candidatos`);
  }
  const toProcess = LIMIT > 0 ? filtered.slice(0, LIMIT) : filtered;
  console.log(`Candidatos a investigar: ${toProcess.length}\n`);

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  let processedCount = 0;
  let errorCount = 0;
  let skippedCount = 0;

  for (let i = 0; i < toProcess.length; i++) {
    const candidate = toProcess[i];
    const id = candidate.dni || slugify(candidate.nombre) || `candidato_${i}`;
    const name = candidate.nombre || 'Desconocido';
    const outputFile = path.join(SEARCH_DIR, `${id}.json`);

    // Saltar si ya se busco
    if (fs.existsSync(outputFile)) {
      skippedCount++;
      if (skippedCount <= 3) console.log(`[${i + 1}/${toProcess.length}] ${name} - Ya buscado, saltando`);
      else if (skippedCount === 4) console.log('  ... (saltando ya buscados)');
      continue;
    }

    console.log(`[${i + 1}/${toProcess.length}] Buscando: ${name}`);

    const searchQueries = [
      `"${name}" candidato Peru 2026 denuncia controversia`,
      `"${name}" antecedentes penales pension alimenticia sentencia Peru`,
    ];

    const allSearchResults = [];
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36');

    for (const query of searchQueries) {
      try {
        const encodedQuery = encodeURIComponent(query);
        // Usar Bing en vez de Google (no tiene CAPTCHA agresivo)
        await page.goto(
          `https://www.bing.com/search?q=${encodedQuery}&setlang=es`,
          { waitUntil: 'networkidle2', timeout: 30000 }
        );
        await sleep(1500 + Math.random() * 2000);

        // Extraer resultados de Bing
        const results = await page.evaluate(() => {
          const items = [];
          document.querySelectorAll('.b_algo').forEach(el => {
            const titleEl = el.querySelector('h2 a') || el.querySelector('a');
            const snippetEl = el.querySelector('p') || el.querySelector('.b_lineclamp2');

            if (titleEl && titleEl.textContent.trim().length > 5) {
              items.push({
                title: titleEl.textContent.trim(),
                url: titleEl.href,
                snippet: snippetEl ? snippetEl.textContent.trim() : ''
              });
            }
          });
          return items.slice(0, 7);
        });

        allSearchResults.push(...results);
      } catch (e) {
        console.log(`  Error: ${e.message.substring(0, 60)}`);
      }
    }

    await page.close();

    // Deduplicar por URL
    const uniqueResults = [];
    const seenUrls = new Set();
    for (const r of allSearchResults) {
      if (!seenUrls.has(r.url)) {
        seenUrls.add(r.url);
        uniqueResults.push(r);
      }
    }

    // Guardar resultados de busqueda (sin analisis de IA)
    const output = {
      searchedAt: new Date().toISOString(),
      candidate: {
        nombre: name,
        dni: id,
        partido: candidate.partido,
        cargo: candidate.cargo,
        region: candidate.region || candidate.distrito
      },
      hojaVidaData: candidate.hojaVidaData || null,
      queriesUsed: searchQueries,
      totalResults: uniqueResults.length,
      searchResults: uniqueResults,
      // Este campo lo llena Claude Code despues
      analysis: null
    };

    fs.writeFileSync(outputFile, JSON.stringify(output, null, 2));
    processedCount++;
    console.log(`  ${uniqueResults.length} resultados guardados`);

    // Rate limiting
    await sleep(2000 + Math.random() * 2000);
  }

  await browser.close();

  // Generar indice de busquedas
  const searchFiles = fs.readdirSync(SEARCH_DIR).filter(f => f.endsWith('.json'));
  const index = searchFiles.map(f => {
    const data = JSON.parse(fs.readFileSync(path.join(SEARCH_DIR, f), 'utf8'));
    return {
      file: f,
      nombre: data.candidate.nombre,
      partido: data.candidate.partido,
      resultados: data.totalResults,
      analizado: data.analysis !== null
    };
  });

  fs.writeFileSync(
    path.join(SEARCH_DIR, '_index.json'),
    JSON.stringify({ total: index.length, candidates: index }, null, 2)
  );

  console.log(`\n${'='.repeat(50)}`);
  console.log(`RESULTADO`);
  console.log(`${'='.repeat(50)}`);
  console.log(`Buscados ahora: ${processedCount}`);
  console.log(`Saltados (ya existian): ${skippedCount}`);
  console.log(`Errores: ${errorCount}`);
  console.log(`Total archivos: ${searchFiles.length}`);
  console.log(`\nGuardados en: data/search_results/`);
  console.log(`\nSIGUIENTE PASO:`);
  console.log(`Pide a Claude Code que ejecute el analisis:`);
  console.log(`  "Analiza los resultados de busqueda en data/search_results/`);
  console.log(`   y genera los archivos de controversias en data/controversies/"`);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

process.on('SIGINT', () => {
  console.log('\nInterrumpido. Los resultados parciales ya estan guardados.');
  process.exit(0);
});

searchControversies().catch(err => {
  console.error('Error fatal:', err);
  process.exit(1);
});
