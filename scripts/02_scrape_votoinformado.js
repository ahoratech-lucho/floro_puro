/**
 * Script 02 (v3): Scraping via Voto Informado
 *
 * Voto Informado NO tiene CAPTCHA y muestra todos los candidatos
 * organizados por tipo de eleccion y partido.
 *
 * Estrategia:
 *   - Presidentes: pagina directa con todos los candidatos
 *   - Senadores/Diputados/Parlamento: pagina con cards de partidos (divs clickeables, NO links)
 *     -> Extraer partidoId del logo src (GetSimbolo/{id})
 *     -> Navegar a /{categoria}?partido={id} para ver candidatos
 *
 * Fuentes de datos:
 *   - Fotos: mpesije.jne.gob.pe/apidocs/
 *   - Logos: sroppublico.jne.gob.pe/Consulta/Simbolo/GetSimbolo/
 *   - Datos: votoinformado.jne.gob.pe
 *
 * Uso: node scripts/02_scrape_votoinformado.js [--limit 5]
 *   --limit: maximo de partidos a scrapear por categoria (0 = todos)
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const OUTPUT_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const PROGRESS_FILE = path.join(__dirname, '..', 'data', 'candidates_progress.json');
const BASE_URL = 'https://votoinformado.jne.gob.pe';

const args = process.argv.slice(2);
const LIMIT = args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) : 0;

const CATEGORIES = [
  { name: 'PRESIDENTE', url: '/presidente-vicepresidentes', type: 'direct' },
  { name: 'SENADOR', url: '/senadores', type: 'by_party' },
  { name: 'DIPUTADO', url: '/diputados', type: 'by_party' },
  { name: 'PARLAMENTO ANDINO', url: '/parlamento-andino', type: 'by_party' },
];

async function scrapeVotoInformado() {
  console.log('=== Scraping via Voto Informado (sin CAPTCHA) ===');
  console.log(`Limit: ${LIMIT || 'todos'}\n`);

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1400,900'],
    defaultViewport: { width: 1400, height: 900 }
  });

  const allCandidates = [];

  for (const category of CATEGORIES) {
    console.log(`\n${'='.repeat(50)}`);
    console.log(`--- ${category.name} ---`);
    console.log('='.repeat(50));

    try {
      if (category.type === 'direct') {
        // === PRESIDENTES: candidatos directos en la pagina ===
        const page = await browser.newPage();
        await page.goto(`${BASE_URL}${category.url}`, {
          waitUntil: 'networkidle2', timeout: 60000
        });
        await sleep(3000);
        await autoScroll(page);

        const candidates = await extractCandidatesFromPage(page, category.name, null);
        allCandidates.push(...candidates);
        console.log(`  ${candidates.length} candidatos extraidos`);

        await page.close();

      } else if (category.type === 'by_party') {
        // === SENADORES/DIPUTADOS/PARLAMENTO: hay que ir partido por partido ===

        // Paso 1: Obtener lista de partidos (cards con logos)
        const listPage = await browser.newPage();
        await listPage.goto(`${BASE_URL}${category.url}`, {
          waitUntil: 'networkidle2', timeout: 60000
        });
        await sleep(3000);
        await autoScroll(listPage);

        // Extraer partidos: las cards son DIVs con cursor-pointer (NO son <a> tags)
        // El ID del partido esta en el src del logo: GetSimbolo/{id}
        const parties = await listPage.evaluate(() => {
          const results = [];
          const cards = document.querySelectorAll('.border.border-gray-200.bg-white');
          cards.forEach(card => {
            const img = card.querySelector('img[src*="GetSimbolo"]');
            const nameEl = card.querySelector('h3') || card.querySelector('.font-bold');
            if (img && nameEl) {
              const src = img.src;
              const idMatch = src.match(/GetSimbolo\/(\d+)/);
              if (idMatch) {
                results.push({
                  id: idMatch[1],
                  name: nameEl.textContent.trim(),
                  logo: src
                });
              }
            }
          });
          return results;
        });

        await listPage.close();

        console.log(`  ${parties.length} partidos encontrados`);

        const partiesToProcess = LIMIT > 0 ? parties.slice(0, LIMIT) : parties;

        // Paso 2: Visitar cada partido por URL directa
        for (let i = 0; i < partiesToProcess.length; i++) {
          const party = partiesToProcess[i];
          const partyUrl = `${BASE_URL}${category.url}?partido=${party.id}`;
          console.log(`  [${i + 1}/${partiesToProcess.length}] ${party.name}`);

          try {
            const partyPage = await browser.newPage();
            await partyPage.goto(partyUrl, {
              waitUntil: 'networkidle2', timeout: 30000
            });
            await sleep(2000);
            await autoScroll(partyPage);

            const candidates = await extractCandidatesFromPage(partyPage, category.name, party);
            allCandidates.push(...candidates);
            console.log(`    -> ${candidates.length} candidatos`);

            await partyPage.close();
          } catch (e) {
            console.log(`    Error: ${e.message.substring(0, 80)}`);
          }

          // Rate limiting
          await sleep(1500);
        }
      }
    } catch (e) {
      console.log(`  Error en categoria: ${e.message}`);
    }

    // Guardar progreso despues de cada categoria
    saveProgress(allCandidates);
    console.log(`  [Progreso guardado: ${allCandidates.length} candidatos total]`);
  }

  await browser.close();

  // Deduplicar
  const uniqueMap = new Map();
  allCandidates.forEach(c => {
    const key = `${c.nombre}_${c.cargo}`;
    if (!uniqueMap.has(key)) uniqueMap.set(key, c);
  });
  const unique = [...uniqueMap.values()];

  // Guardar resultado final
  const output = {
    scrapedAt: new Date().toISOString(),
    source: 'votoinformado.jne.gob.pe',
    election: 'Peru 2026 - Elecciones Generales',
    total: unique.length,
    totalBeforeDedup: allCandidates.length,
    byCategory: {},
    candidates: unique
  };

  CATEGORIES.forEach(cat => {
    output.byCategory[cat.name] = unique.filter(c => c.cargo === cat.name).length;
  });

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));

  console.log(`\n${'='.repeat(50)}`);
  console.log('RESULTADO FINAL');
  console.log('='.repeat(50));
  console.log(`Total candidatos (antes dedup): ${allCandidates.length}`);
  console.log(`Total candidatos (unicos): ${unique.length}`);
  Object.entries(output.byCategory).forEach(([k, v]) => console.log(`  ${k}: ${v}`));
  console.log(`Guardado: ${OUTPUT_FILE}`);
}

/**
 * Extrae candidatos de una pagina de Voto Informado.
 * Funciona tanto para la pagina de presidentes (partido en texto)
 * como para paginas de partido individual (partido conocido).
 */
async function extractCandidatesFromPage(page, cargo, partyInfo) {
  return await page.evaluate((cargoParam, partyInfoParam) => {
    const candidates = [];

    // Extraer fotos de candidatos (fuente principal)
    const photos = Array.from(document.querySelectorAll('img[src*="mpesije.jne.gob.pe"]'))
      .filter(img => img.alt && img.alt.trim().length > 3);

    // Logos de partidos en la pagina
    const logos = Array.from(document.querySelectorAll('img[src*="GetSimbolo"]'))
      .map(img => img.src);

    // Si tenemos info del partido (paginas by_party), usarla directamente
    const knownParty = partyInfoParam ? partyInfoParam.name : null;
    const knownLogo = partyInfoParam ? partyInfoParam.logo : null;

    if (photos.length > 0) {
      // Metodo principal: usar las fotos con alt text = nombre del candidato
      const seen = new Set();
      photos.forEach((img, idx) => {
        const nombre = img.alt.trim();
        if (seen.has(nombre)) return;
        seen.add(nombre);

        candidates.push({
          nombre,
          foto: img.src,
          cargo: cargoParam,
          partido: knownParty,
          partyLogo: knownLogo || logos[0] || null
        });
      });

      // Si no tenemos partido conocido (pagina de presidentes),
      // intentar extraer del texto de la pagina
      if (!knownParty) {
        const fullText = document.body.innerText;
        const lines = fullText.split('\n').map(l => l.trim())
          .filter(l => l.length > 3);

        for (let i = 0; i < lines.length - 1; i++) {
          const candidateMatch = candidates.find(c =>
            c.nombre === lines[i + 1] && !c.partido
          );
          if (candidateMatch) {
            candidateMatch.partido = lines[i];
          }
        }

        // Asignar logos individuales para presidentes
        // En la pagina de presidentes cada candidato tiene su propio logo
        if (logos.length > 0) {
          // Los logos se repiten: cada candidato tiene 1 logo junto a su foto
          // El logo unico mas cercano al candidato es el correcto
          const uniqueLogos = [...new Set(logos)];
          candidates.forEach((c, idx) => {
            if (idx < uniqueLogos.length) {
              c.partyLogo = uniqueLogos[idx] || null;
            }
          });
        }
      }
    } else {
      // Sin fotos: extraer nombres de los spans
      const nameEls = document.querySelectorAll('.txt-nombre-candidato');
      nameEls.forEach(el => {
        candidates.push({
          nombre: el.textContent.trim(),
          foto: null,
          cargo: cargoParam,
          partido: knownParty,
          partyLogo: knownLogo || logos[0] || null
        });
      });
    }

    return candidates;
  }, cargo, partyInfo);
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
      setTimeout(resolve, 8000); // Max 8 seconds
    });
  });
}

function saveProgress(candidates) {
  try {
    fs.writeFileSync(PROGRESS_FILE, JSON.stringify({
      savedAt: new Date().toISOString(), total: candidates.length, candidates
    }, null, 2));
  } catch { }
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

process.on('SIGINT', () => {
  console.log('\nGuardando progreso...');
  if (fs.existsSync(PROGRESS_FILE)) {
    const data = JSON.parse(fs.readFileSync(PROGRESS_FILE, 'utf8'));
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify({
      scrapedAt: new Date().toISOString(),
      source: 'votoinformado.jne.gob.pe',
      total: data.total,
      candidates: data.candidates
    }, null, 2));
    console.log(`Guardados ${data.total} candidatos.`);
  }
  process.exit(0);
});

scrapeVotoInformado().catch(err => { console.error('Error:', err); process.exit(1); });
