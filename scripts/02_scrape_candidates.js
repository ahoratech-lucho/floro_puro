/**
 * Script 02: Scraping de candidatos del JNE
 *
 * Abre la Plataforma Electoral con Puppeteer.
 * Hay 2 rutas:
 *   - Busqueda simple: DNI/Nombre + CAPTCHA de imagen
 *   - Busqueda avanzada: filtros por partido/tipo de eleccion
 *
 * El script intenta ambas. Tu resuelves el CAPTCHA en el navegador.
 *
 * API: apiplataformaelectoral4.jne.gob.pe
 * reCAPTCHA Enterprise invisible + CAPTCHA de imagen custom
 *
 * Uso: node scripts/02_scrape_candidates.js [--timeout 10]
 *       --timeout: minutos de espera (default 10)
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const OUTPUT_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const PROGRESS_FILE = path.join(__dirname, '..', 'data', 'candidates_progress.json');
const RAW_FILE = path.join(__dirname, 'config', 'raw_api_responses.json');
const BASE_URL = 'https://plataformaelectoral.jne.gob.pe';
const API_HOST = 'apiplataformaelectoral4.jne.gob.pe';

const args = process.argv.slice(2);
const timeoutIdx = args.indexOf('--timeout');
const TIMEOUT_MIN = timeoutIdx !== -1 ? parseInt(args[timeoutIdx + 1]) : 10;

async function scrapeCandidates() {
  console.log('=== Scraping de Candidatos JNE - Peru 2026 ===');
  console.log(`Timeout: ${TIMEOUT_MIN} minutos\n`);

  const browser = await puppeteer.launch({
    headless: false,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1400,900'],
    defaultViewport: { width: 1400, height: 900 }
  });

  const page = await browser.newPage();

  // === INTERCEPTOR ===
  const capturedResponses = [];
  const allCandidates = [];

  page.on('response', async (response) => {
    const url = response.url();
    if (!url.includes(API_HOST)) return;
    const contentType = response.headers()['content-type'] || '';
    if (!contentType.includes('json')) return;

    try {
      const data = await response.json();
      capturedResponses.push({
        url, method: response.request().method(),
        status: response.status(),
        postData: response.request().postData(),
        timestamp: new Date().toISOString(), data
      });

      // Detectar listas de candidatos
      if (data.data && Array.isArray(data.data) && data.data.length > 0) {
        const sample = JSON.stringify(data.data[0]).toLowerCase();
        // Excluir la lista de procesos electorales
        if (sample.includes('idprocesoelectoral') && !sample.includes('candidato') && !sample.includes('apellido')) return;

        if (/candidato|postulante|nombre|apellido|organizacion|foto|hojavida|expediente/.test(sample)) {
          const prevCount = allCandidates.length;
          data.data.forEach(item => {
            const c = extractCandidate(item);
            if (c.nombre || c.dni) allCandidates.push(c);
          });
          const newCount = allCandidates.length - prevCount;
          if (newCount > 0) {
            console.log(`\n  *** +${newCount} candidatos (total: ${allCandidates.length}) ***`);
            saveProgress(allCandidates, capturedResponses);
          }
        }
      }
    } catch { /* skip */ }
  });

  // === PASO 1: Abrir busqueda avanzada (mas opciones de filtro) ===
  console.log('Abriendo Busqueda Avanzada de Candidatos...');
  try {
    await page.goto(`${BASE_URL}/candidatos/busqueda-avanzada/buscar`, {
      waitUntil: 'networkidle2', timeout: 60000
    });
    console.log('Busqueda Avanzada cargada.\n');
  } catch {
    // Fallback a busqueda simple
    console.log('Busqueda Avanzada no disponible. Cargando busqueda simple...');
    await page.goto(`${BASE_URL}/candidatos/busqueda/buscar`, {
      waitUntil: 'networkidle2', timeout: 60000
    });
  }
  await sleep(2000);

  // Screenshot
  await page.screenshot({
    path: path.join(__dirname, 'config', 'search_page.png'), fullPage: true
  });

  // Listar lo que hay en la pagina
  const pageInfo = await page.evaluate(() => {
    const info = { url: location.href, title: document.title, forms: [] };
    document.querySelectorAll('select, input, button, .mat-select, [role="listbox"]').forEach(el => {
      info.forms.push({
        tag: el.tagName, type: el.type || '', id: el.id || '',
        name: el.name || '', placeholder: el.placeholder || '',
        text: el.textContent?.trim().substring(0, 40) || '',
        class: el.className?.substring(0, 50) || '',
        options: el.tagName === 'SELECT' ? Array.from(el.options || []).map(o => ({ value: o.value, text: o.text })) : undefined
      });
    });
    // Obtener texto visible para entender la pagina
    info.visibleText = document.body.innerText.substring(0, 2000);
    return info;
  });

  console.log(`Pagina: ${pageInfo.url}`);
  console.log(`\nElementos del formulario:`);
  pageInfo.forms.forEach(f => {
    const desc = f.placeholder || f.text || f.id || f.name || f.class;
    console.log(`  [${f.tag}${f.type ? ':' + f.type : ''}] ${desc}`);
    if (f.options && f.options.length > 0) {
      f.options.slice(0, 5).forEach(o => console.log(`    - ${o.text} (${o.value})`));
      if (f.options.length > 5) console.log(`    ... (${f.options.length} opciones total)`);
    }
  });

  console.log(`\nTexto visible:`);
  console.log(pageInfo.visibleText.substring(0, 800));

  // === INSTRUCCIONES ===
  console.log(`\n${'='.repeat(60)}`);
  console.log('INSTRUCCIONES:');
  console.log('='.repeat(60));
  console.log('El navegador esta abierto. Haz lo siguiente:');
  console.log('');
  console.log('OPCION A - Busqueda Avanzada (si la pagina lo permite):');
  console.log('  1. Selecciona filtros (proceso electoral, tipo, partido)');
  console.log('  2. Haz clic en Buscar');
  console.log('  3. Navega por TODAS las paginas de resultados');
  console.log('');
  console.log('OPCION B - Busqueda Simple:');
  console.log('  1. Ve a: Candidatos > Busqueda de Candidato');
  console.log('  2. Escribe un apellido comun (ej: "GARCIA")');
  console.log('  3. Resuelve el CAPTCHA de imagen');
  console.log('  4. Click Buscar');
  console.log('  5. Navega por todas las paginas');
  console.log('  6. Repite con otros apellidos: RODRIGUEZ, TORRES,');
  console.log('     FLORES, QUISPE, HUAMAN, DIAZ, CHAVEZ, etc.');
  console.log('');
  console.log('Los datos se capturan AUTOMATICAMENTE.');
  console.log(`Tienes ${TIMEOUT_MIN} minutos. Presiona Ctrl+C cuando termines.`);
  console.log('='.repeat(60));

  // === ESPERAR ===
  const MAX_WAIT = TIMEOUT_MIN * 60;
  let waitedSec = 0;
  let lastCount = 0;
  let idleCount = 0;

  while (waitedSec < MAX_WAIT) {
    await sleep(10000);
    waitedSec += 10;

    if (allCandidates.length > lastCount) {
      const diff = allCandidates.length - lastCount;
      console.log(`[${Math.floor(waitedSec / 60)}m${waitedSec % 60}s] +${diff} candidatos (total: ${allCandidates.length})`);
      lastCount = allCandidates.length;
      idleCount = 0;
    } else {
      idleCount++;
      if (idleCount % 6 === 0) {
        console.log(`[${Math.floor(waitedSec / 60)}m] Esperando... (${allCandidates.length} candidatos)`);
      }
    }

    // Si hay candidatos y 3 min sin actividad, preguntar
    if (allCandidates.length > 0 && idleCount >= 18) {
      console.log('\n3 minutos sin nuevos datos.');
      console.log(`Candidatos capturados: ${allCandidates.length}`);
      console.log('Esperando 2 minutos mas por si sigues navegando...');
      await sleep(120000);
      waitedSec += 120;
      if (allCandidates.length === lastCount) {
        console.log('Sin cambios. Finalizando.');
        break;
      }
    }
  }

  // === GUARDAR RESULTADOS ===
  const uniqueMap = new Map();
  allCandidates.forEach(c => {
    const key = c.dni || c.nombre || JSON.stringify(c);
    if (!uniqueMap.has(key)) uniqueMap.set(key, c);
  });
  const uniqueCandidates = [...uniqueMap.values()];

  const output = {
    scrapedAt: new Date().toISOString(),
    election: 'Peru 2026 - Elecciones Generales',
    source: 'plataformaelectoral.jne.gob.pe',
    total: uniqueCandidates.length,
    totalBeforeDedup: allCandidates.length,
    candidates: uniqueCandidates
  };

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));
  fs.writeFileSync(RAW_FILE, JSON.stringify(capturedResponses, null, 2));

  console.log(`\n${'='.repeat(60)}`);
  console.log('RESULTADO FINAL');
  console.log('='.repeat(60));
  console.log(`Candidatos capturados: ${allCandidates.length}`);
  console.log(`Candidatos unicos: ${uniqueCandidates.length}`);
  console.log(`API responses: ${capturedResponses.length}`);
  console.log(`Guardado: ${OUTPUT_FILE}`);

  if (uniqueCandidates.length > 0) {
    console.log('\nMuestra:');
    uniqueCandidates.slice(0, 10).forEach((c, i) => {
      console.log(`  ${i + 1}. ${c.nombre} | ${c.partido || '?'} | ${c.cargo || '?'} | foto:${c.foto ? 'Si' : 'No'}`);
    });

    const porPartido = {};
    uniqueCandidates.forEach(c => {
      const p = c.partido || 'Sin partido';
      porPartido[p] = (porPartido[p] || 0) + 1;
    });
    console.log('\nPor partido:');
    Object.entries(porPartido).sort((a, b) => b[1] - a[1]).forEach(([p, n]) => {
      console.log(`  ${p}: ${n}`);
    });
  } else {
    console.log('\nNo se capturaron candidatos.');
    console.log('Tip: Asegurate de buscar candidatos en el navegador y navegar las paginas de resultados.');
  }

  await browser.close();
}

function extractCandidate(item) {
  return {
    nombre: item.strCandidato || item.strNombreCompleto ||
      [item.strApellidoPaterno, item.strApellidoMaterno, item.strNombres].filter(Boolean).join(' ') ||
      item.nombre || null,
    dni: item.strDocumentoIdentidad || item.strDNI || item.dni || null,
    partido: item.strOrganizacionPolitica || item.strPartidoPolitico || item.partido || null,
    cargo: item.strCargoEleccion || item.strTipoEleccion || item.cargo || null,
    foto: item.strFoto || item.strRutaFoto || item.foto || item.strUrlFoto || null,
    hojaVida: item.strRutaHojaVida || item.strUrlHojaVida || item.hojaVida || null,
    expediente: item.strExpediente || item.idExpediente || null,
    jee: item.strJuradoElectoralEspecial || null,
    distrito: item.strDistritoPostula || item.strDistrito || null,
    region: item.strDepartamento || item.strRegion || null,
    posicion: item.intPosicion || item.numOrden || null,
    idCandidato: item.idCandidato || item.idHojaVida || null,
    idOrganizacion: item.idOrganizacionPolitica || null,
    estado: item.strEstado || item.strEstadoExpediente || null,
    raw: item
  };
}

function saveProgress(candidates, responses) {
  try {
    fs.writeFileSync(PROGRESS_FILE, JSON.stringify({
      savedAt: new Date().toISOString(), total: candidates.length, candidates
    }, null, 2));
  } catch { /* ignore */ }
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

process.on('SIGINT', () => {
  console.log('\n\nGuardando datos...');
  if (fs.existsSync(PROGRESS_FILE)) {
    const data = JSON.parse(fs.readFileSync(PROGRESS_FILE, 'utf8'));
    // Deduplicar
    const map = new Map();
    data.candidates.forEach(c => {
      const key = c.dni || c.nombre;
      if (!map.has(key)) map.set(key, c);
    });
    const unique = [...map.values()];
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify({
      scrapedAt: new Date().toISOString(),
      election: 'Peru 2026 - Elecciones Generales',
      total: unique.length, candidates: unique
    }, null, 2));
    console.log(`Guardados ${unique.length} candidatos unicos en candidates.json`);
  }
  process.exit(0);
});

scrapeCandidates().catch(err => { console.error('Error:', err); process.exit(1); });
