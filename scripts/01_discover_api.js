/**
 * Script 01: Descubrimiento de API interna del JNE
 *
 * Abre la Plataforma Electoral con Puppeteer en modo visible,
 * intercepta TODAS las llamadas XHR/Fetch y las cataloga.
 *
 * Uso: node scripts/01_discover_api.js
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const CONFIG_DIR = path.join(__dirname, 'config');
const OUTPUT_FILE = path.join(CONFIG_DIR, 'api_endpoints.json');
const BASE_URL = 'https://plataformaelectoral.jne.gob.pe';

async function discoverAPI() {
  console.log('=== Descubrimiento de API interna del JNE ===\n');

  const browser = await puppeteer.launch({
    headless: false,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1366,900'],
    defaultViewport: { width: 1366, height: 900 }
  });

  const page = await browser.newPage();

  const apiCalls = [];
  const seenUrls = new Set();

  // Interceptar TODAS las respuestas de red
  page.on('response', async (response) => {
    const url = response.url();
    const request = response.request();
    const resourceType = request.resourceType();

    if (resourceType !== 'xhr' && resourceType !== 'fetch') return;

    const method = request.method();
    const status = response.status();
    const contentType = response.headers()['content-type'] || '';

    if (!contentType.includes('json') && !contentType.includes('text/plain')) return;

    const urlKey = `${method} ${url}`;
    if (seenUrls.has(urlKey)) return;
    seenUrls.add(urlKey);

    let responseBody = null;
    try {
      responseBody = await response.json();
    } catch {
      try { responseBody = await response.text(); } catch { responseBody = null; }
    }

    const entry = {
      url,
      method,
      status,
      contentType,
      postData: request.postData() || null,
      responseSample: responseBody
        ? JSON.stringify(responseBody).substring(0, 1000)
        : null,
      timestamp: new Date().toISOString()
    };

    // Detectar endpoints de candidatos
    if (typeof responseBody === 'object' && responseBody !== null) {
      const json = JSON.stringify(responseBody).toLowerCase();
      if (/candidat|lista|partido|organiz|eleccion|postula/.test(json)) {
        entry.relevant = true;
        console.log(`*** RELEVANTE *** [${status}] ${method} ${url}`);
      }
      if (Array.isArray(responseBody)) {
        entry.arrayLength = responseBody.length;
      } else if (responseBody.data && Array.isArray(responseBody.data)) {
        entry.arrayLength = responseBody.data.length;
      }
    }

    apiCalls.push(entry);
    console.log(`[${status}] ${method} ${url.substring(0, 120)}`);
  });

  // Navegar a la pagina principal
  console.log('Navegando a Plataforma Electoral...');
  await page.goto(BASE_URL, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(3000);

  // Navegar a busqueda de candidatos
  console.log('Navegando a busqueda de candidatos...');
  const candidateUrls = [
    `${BASE_URL}/candidatos/busqueda/buscar`,
    `${BASE_URL}/candidato`,
    `${BASE_URL}/Candidato`,
  ];

  for (const url of candidateUrls) {
    try {
      await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
      console.log(`Cargado: ${url}`);
      await sleep(2000);
      break;
    } catch {
      console.log(`No disponible: ${url}`);
    }
  }

  // Guardar screenshot y HTML del estado actual
  await page.screenshot({
    path: path.join(CONFIG_DIR, 'page_state.png'),
    fullPage: true
  });

  const html = await page.content();
  fs.writeFileSync(
    path.join(CONFIG_DIR, 'page_structure.html'),
    html.substring(0, 100000)
  );
  console.log('Screenshot y HTML guardados en scripts/config/');

  // Listar todos los elementos interactivos
  const interactiveElements = await page.evaluate(() => {
    const elements = [];
    const selectors = ['input', 'select', 'button', 'a[href]', '[role="button"]',
      '[role="listbox"]', '[role="combobox"]', '.p-dropdown', 'mat-select'];
    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        elements.push({
          tag: el.tagName,
          type: el.type || '',
          id: el.id || '',
          name: el.name || '',
          class: el.className ? el.className.substring(0, 80) : '',
          placeholder: el.placeholder || '',
          text: (el.textContent || '').trim().substring(0, 50),
          href: el.href || ''
        });
      });
    });
    return elements;
  });

  fs.writeFileSync(
    path.join(CONFIG_DIR, 'interactive_elements.json'),
    JSON.stringify(interactiveElements, null, 2)
  );
  console.log(`Encontrados ${interactiveElements.length} elementos interactivos`);

  // Probar endpoints API comunes
  console.log('\nProbando endpoints API directos...');
  const probePaths = [
    '/api/v1/candidato',
    '/api/v1/candidatos',
    '/api/candidato',
    '/api/candidatos',
    '/api/v1/organizacion-politica',
    '/api/v1/proceso-electoral',
    '/api/v1/eleccion',
    '/Candidato/GetCandidatos',
    '/api/candidato/lista',
    '/api/candidato/buscar',
    '/candidato/lista',
    '/api/proceso',
    '/api/ubigeo',
  ];

  for (const apiPath of probePaths) {
    try {
      const result = await page.evaluate(async (fullUrl) => {
        try {
          const res = await fetch(fullUrl, { headers: { 'Accept': 'application/json' } });
          const text = await res.text();
          return { status: res.status, type: res.headers.get('content-type'), body: text.substring(0, 500) };
        } catch (e) {
          return { error: e.message };
        }
      }, `${BASE_URL}${apiPath}`);

      if (result.status && result.status !== 404 && result.status !== 0) {
        console.log(`  [${result.status}] ${apiPath}`);
        if (result.body && !result.body.startsWith('<!')) {
          console.log(`    -> ${result.body.substring(0, 150)}`);
          apiCalls.push({
            url: `${BASE_URL}${apiPath}`,
            method: 'GET',
            status: result.status,
            contentType: result.type,
            responseSample: result.body,
            source: 'probe'
          });
        }
      }
    } catch { /* skip */ }
  }

  // Esperar para capturar mas requests durante interaccion manual
  console.log('\n=== Navegador abierto 60 segundos ===');
  console.log('Busca candidatos manualmente para capturar mas endpoints.');
  console.log('Las requests se capturan automaticamente.\n');
  await sleep(60000);

  // Guardar resultados finales
  const output = {
    discoveredAt: new Date().toISOString(),
    baseUrl: BASE_URL,
    totalCalls: apiCalls.length,
    relevantEndpoints: apiCalls.filter(c => c.relevant),
    allEndpoints: apiCalls
  };

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));

  console.log(`\n=== Resumen ===`);
  console.log(`Total API calls: ${apiCalls.length}`);
  console.log(`Endpoints relevantes: ${output.relevantEndpoints.length}`);
  console.log(`Guardado en: ${OUTPUT_FILE}`);

  const uniquePaths = [...new Set(apiCalls.map(c => {
    try { return new URL(c.url).pathname; } catch { return c.url; }
  }))];
  console.log('\nPaths unicos:');
  uniquePaths.forEach(p => console.log(`  ${p}`));

  await browser.close();
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

discoverAPI().catch(err => {
  console.error('Error fatal:', err);
  process.exit(1);
});
