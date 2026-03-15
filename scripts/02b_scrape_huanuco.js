/**
 * Script 02b: Scraping de candidatos de HUANUCO
 *
 * Extrae diputados del distrito electoral de Huanuco
 * desde votoinformado.jne.gob.pe
 *
 * Uso: node scripts/02b_scrape_huanuco.js
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const OUTPUT_FILE = path.join(__dirname, '..', 'data', 'candidates_huanuco.json');
const CANDIDATES_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const BASE_URL = 'https://votoinformado.jne.gob.pe';

async function scrapeHuanuco() {
  console.log('=== Scraping Diputados de HUANUCO ===\n');

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1400,900'],
    defaultViewport: { width: 1400, height: 900 }
  });

  const allCandidates = [];

  // Paso 1: Ir a diputados y obtener lista de partidos
  const listPage = await browser.newPage();
  await listPage.goto(`${BASE_URL}/diputados`, {
    waitUntil: 'networkidle2', timeout: 60000
  });
  await sleep(3000);

  // Seleccionar HUANUCO (090000) en el dropdown
  await listPage.select('select', '090000');
  await sleep(3000);

  // Obtener partidos
  const parties = await listPage.evaluate(() => {
    const results = [];
    const cards = document.querySelectorAll('.border.border-gray-200.bg-white');
    cards.forEach(card => {
      const img = card.querySelector('img[src*="GetSimbolo"]');
      const nameEl = card.querySelector('h3') || card.querySelector('.font-bold');
      if (img && nameEl) {
        const idMatch = img.src.match(/GetSimbolo\/(\d+)/);
        if (idMatch) {
          results.push({ id: idMatch[1], name: nameEl.textContent.trim(), logo: img.src });
        }
      }
    });
    return results;
  });

  console.log(`${parties.length} partidos en HUANUCO\n`);

  // Paso 2: Para cada partido, clickear en la card y extraer candidatos
  for (let i = 0; i < parties.length; i++) {
    const party = parties[i];
    console.log(`[${i + 1}/${parties.length}] ${party.name}`);

    try {
      // Volver a la lista de partidos si no estamos ahi
      if (!listPage.url().includes('/diputados') || listPage.url().includes('partido=')) {
        await listPage.goto(`${BASE_URL}/diputados`, {
          waitUntil: 'networkidle2', timeout: 30000
        });
        await sleep(2000);
        // Re-seleccionar HUANUCO
        await listPage.select('select', '090000');
        await sleep(2000);
      }

      // Clickear en la card del partido (buscar por ID en el logo src)
      await listPage.evaluate((partyId) => {
        const cards = document.querySelectorAll('.border.border-gray-200.bg-white');
        for (const card of cards) {
          const img = card.querySelector(`img[src*="GetSimbolo/${partyId}"]`);
          if (img) {
            card.click();
            break;
          }
        }
      }, party.id);

      await sleep(3000);

      // Auto scroll para cargar todo
      await autoScroll(listPage);

      // Extraer candidatos
      const candidates = await listPage.evaluate((partyName, partyLogo) => {
        const results = [];
        const photos = document.querySelectorAll('img[src*="mpesije"]');
        const seen = new Set();

        photos.forEach(img => {
          const nombre = img.alt?.trim();
          if (!nombre || nombre.length < 3 || seen.has(nombre)) return;
          seen.add(nombre);
          results.push({
            nombre,
            foto: img.src,
            cargo: 'DIPUTADO',
            partido: partyName,
            partyLogo: partyLogo,
            region: 'HUANUCO'
          });
        });

        // Fallback: use name spans if no photos
        if (results.length === 0) {
          const nameEls = document.querySelectorAll('.txt-nombre-candidato');
          nameEls.forEach(el => {
            const nombre = el.textContent.trim();
            if (nombre.length > 3 && !seen.has(nombre)) {
              seen.add(nombre);
              results.push({
                nombre,
                foto: null,
                cargo: 'DIPUTADO',
                partido: partyName,
                partyLogo: partyLogo,
                region: 'HUANUCO'
              });
            }
          });
        }

        return results;
      }, party.name, party.logo);

      allCandidates.push(...candidates);
      console.log(`  -> ${candidates.length} candidatos`);

    } catch (e) {
      console.log(`  Error: ${e.message.substring(0, 80)}`);
    }

    await sleep(1000);
  }

  await browser.close();

  // Deduplicar
  const uniqueMap = new Map();
  allCandidates.forEach(c => {
    const key = `${c.nombre}_DIPUTADO_HUANUCO`;
    if (!uniqueMap.has(key)) uniqueMap.set(key, c);
  });
  const unique = [...uniqueMap.values()];

  // Guardar archivo separado
  const output = {
    scrapedAt: new Date().toISOString(),
    source: 'votoinformado.jne.gob.pe',
    election: 'Peru 2026 - Elecciones Generales',
    region: 'HUANUCO',
    total: unique.length,
    candidates: unique
  };

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));

  // Tambien agregar al candidates.json principal (marcados como HUANUCO)
  if (fs.existsSync(CANDIDATES_FILE)) {
    const mainData = JSON.parse(fs.readFileSync(CANDIDATES_FILE, 'utf8'));

    // Remover diputados que ya esten (los que scrapeamos antes eran de Lima)
    // y agregar los de Huanuco
    const existingNames = new Set(mainData.candidates.map(c => c.nombre));
    let added = 0;
    for (const c of unique) {
      if (!existingNames.has(c.nombre)) {
        mainData.candidates.push(c);
        existingNames.add(c.nombre);
        added++;
      }
    }

    mainData.total = mainData.candidates.length;
    mainData.byCategory = mainData.byCategory || {};
    mainData.byCategory['DIPUTADO_HUANUCO'] = unique.length;

    fs.writeFileSync(CANDIDATES_FILE, JSON.stringify(mainData, null, 2));
    console.log(`\n${added} candidatos nuevos agregados a candidates.json`);
  }

  console.log(`\n=== RESULTADO ===`);
  console.log(`Diputados de HUANUCO: ${unique.length}`);
  console.log(`Guardado en: ${OUTPUT_FILE}`);
}

async function autoScroll(page) {
  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let totalHeight = 0;
      const distance = 400;
      const timer = setInterval(() => {
        window.scrollBy(0, distance);
        totalHeight += distance;
        if (totalHeight >= document.body.scrollHeight) {
          clearInterval(timer);
          resolve();
        }
      }, 100);
      setTimeout(resolve, 8000);
    });
  });
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

scrapeHuanuco().catch(err => { console.error('Error:', err); process.exit(1); });
