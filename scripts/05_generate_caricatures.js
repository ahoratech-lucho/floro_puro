/**
 * Script 05: Generacion de caricaturas
 *
 * 3 modos disponibles:
 *   --provider css       → GRATIS: Aplica filtros cartoon con Canvas (Node.js)
 *   --provider replicate → PAGO: Usa Replicate API (~$0.01-0.05/imagen)
 *   --provider stability → PAGO: Usa Stability AI API
 *
 * Uso:
 *   node scripts/05_generate_caricatures.js --provider css [--limit 5]
 *   node scripts/05_generate_caricatures.js --provider replicate [--limit 5]
 *
 * El modo CSS es gratis y genera un efecto cartoon basico.
 * Los modos de pago generan caricaturas de mayor calidad artistica.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { createCanvas, loadImage } = (() => {
  try { return require('canvas'); }
  catch { return { createCanvas: null, loadImage: null }; }
})();

const DETAILED_FILE = path.join(__dirname, '..', 'data', 'candidates_detailed.json');
const CANDIDATES_FILE = path.join(__dirname, '..', 'data', 'candidates.json');
const PHOTOS_DIR = path.join(__dirname, '..', 'data', 'photos');
const CARICATURES_DIR = path.join(__dirname, '..', 'data', 'caricatures');

const args = process.argv.slice(2);
const LIMIT = args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) : 0;
const providerIdx = args.indexOf('--provider');
const PROVIDER = providerIdx !== -1 ? args[providerIdx + 1] : 'css';

const REPLICATE_API_TOKEN = process.env.REPLICATE_API_TOKEN;
const STABILITY_API_KEY = process.env.STABILITY_API_KEY;

async function generateCaricatures() {
  console.log('=== Generacion de Caricaturas ===');
  console.log(`Provider: ${PROVIDER}\n`);

  if (PROVIDER === 'replicate' && !REPLICATE_API_TOKEN) {
    console.log('ERROR: Necesitas REPLICATE_API_TOKEN');
    console.log('  set REPLICATE_API_TOKEN=r8_...');
    process.exit(1);
  }
  if (PROVIDER === 'stability' && !STABILITY_API_KEY) {
    console.log('ERROR: Necesitas STABILITY_API_KEY');
    process.exit(1);
  }

  if (PROVIDER === 'css' && !createCanvas) {
    console.log('El modo CSS necesita el paquete "canvas".');
    console.log('Instalando: npm install canvas');
    const { execSync } = require('child_process');
    try {
      execSync('npm install canvas', { cwd: path.join(__dirname, '..'), stdio: 'inherit' });
    } catch {
      console.log('\nNo se pudo instalar canvas. Alternativa: usar modo Puppeteer.');
      console.log('Cambiando a modo puppeteer-css...');
      return await generateWithPuppeteerCSS();
    }
  }

  // Cargar candidatos
  let candidates;
  if (fs.existsSync(DETAILED_FILE)) {
    candidates = JSON.parse(fs.readFileSync(DETAILED_FILE, 'utf8')).candidates;
  } else if (fs.existsSync(CANDIDATES_FILE)) {
    candidates = JSON.parse(fs.readFileSync(CANDIDATES_FILE, 'utf8')).candidates;
  } else {
    console.log('Error: No hay datos de candidatos.');
    process.exit(1);
  }

  const withPhotos = candidates.filter((c, i) => {
    const id = c.dni || slugify(c.nombre) || `candidato_${i}`;
    return fs.existsSync(path.join(PHOTOS_DIR, `${id}.jpg`));
  });

  const toProcess = LIMIT > 0 ? withPhotos.slice(0, LIMIT) : withPhotos;
  console.log(`Candidatos con foto: ${withPhotos.length}`);
  console.log(`A procesar: ${toProcess.length}\n`);

  let success = 0, errors = 0;

  for (let i = 0; i < toProcess.length; i++) {
    const candidate = toProcess[i];
    const id = candidate.dni || slugify(candidate.nombre) || `candidato_${i}`;
    const name = candidate.nombre || id;
    const photoPath = path.join(PHOTOS_DIR, `${id}.jpg`);
    const outputPath = path.join(CARICATURES_DIR, `${id}.png`);

    if (fs.existsSync(outputPath)) {
      console.log(`[${i + 1}/${toProcess.length}] ${name} - Ya existe`);
      continue;
    }

    console.log(`[${i + 1}/${toProcess.length}] ${name}`);

    try {
      switch (PROVIDER) {
        case 'css':
          await generateWithCanvasCartoon(photoPath, outputPath);
          break;
        case 'replicate':
          await generateWithReplicate(photoPath, outputPath);
          break;
        case 'stability':
          await generateWithStability(photoPath, outputPath);
          break;
      }
      success++;
      console.log(`  Caricatura generada`);
    } catch (e) {
      errors++;
      console.log(`  Error: ${e.message}`);
    }

    if (PROVIDER !== 'css') await sleep(5000);
  }

  console.log(`\n=== Resumen ===`);
  console.log(`Generadas: ${success} | Errores: ${errors}`);
}

// === MODO GRATIS: Canvas cartoon effect ===
async function generateWithCanvasCartoon(inputPath, outputPath) {
  const { createCanvas: cc, loadImage: li } = require('canvas');
  const img = await li(inputPath);

  const width = img.width;
  const height = img.height;
  const canvas = cc(width, height);
  const ctx = canvas.getContext('2d');

  // Dibujar imagen original
  ctx.drawImage(img, 0, 0);

  // Obtener pixels
  const imageData = ctx.getImageData(0, 0, width, height);
  const data = imageData.data;

  // Efecto 1: Posterizar (reducir colores para efecto cartoon)
  const levels = 6;
  for (let i = 0; i < data.length; i += 4) {
    data[i] = Math.round(data[i] / (256 / levels)) * (256 / levels);     // R
    data[i + 1] = Math.round(data[i + 1] / (256 / levels)) * (256 / levels); // G
    data[i + 2] = Math.round(data[i + 2] / (256 / levels)) * (256 / levels); // B
  }

  // Efecto 2: Aumentar saturacion
  for (let i = 0; i < data.length; i += 4) {
    const r = data[i], g = data[i + 1], b = data[i + 2];
    const max = Math.max(r, g, b), min = Math.min(r, g, b);
    const avg = (r + g + b) / 3;
    const factor = 1.5; // Saturacion boost
    data[i] = Math.min(255, avg + (r - avg) * factor);
    data[i + 1] = Math.min(255, avg + (g - avg) * factor);
    data[i + 2] = Math.min(255, avg + (b - avg) * factor);
  }

  ctx.putImageData(imageData, 0, 0);

  // Efecto 3: Bordes gruesos (edge detection simplificado)
  const edgeCanvas = cc(width, height);
  const edgeCtx = edgeCanvas.getContext('2d');
  edgeCtx.drawImage(img, 0, 0);
  const edgeData = edgeCtx.getImageData(0, 0, width, height);
  const ed = edgeData.data;

  const edgeOverlay = cc(width, height);
  const edgeOverlayCtx = edgeOverlay.getContext('2d');
  const overlayData = edgeOverlayCtx.getImageData(0, 0, width, height);
  const od = overlayData.data;

  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      const idx = (y * width + x) * 4;
      const idxLeft = (y * width + (x - 1)) * 4;
      const idxUp = ((y - 1) * width + x) * 4;

      const gx = Math.abs(ed[idx] - ed[idxLeft]) + Math.abs(ed[idx + 1] - ed[idxLeft + 1]) + Math.abs(ed[idx + 2] - ed[idxLeft + 2]);
      const gy = Math.abs(ed[idx] - ed[idxUp]) + Math.abs(ed[idx + 1] - ed[idxUp + 1]) + Math.abs(ed[idx + 2] - ed[idxUp + 2]);
      const edge = gx + gy;

      if (edge > 80) {
        od[idx] = 0; od[idx + 1] = 0; od[idx + 2] = 0; od[idx + 3] = 200;
      } else {
        od[idx + 3] = 0;
      }
    }
  }

  edgeOverlayCtx.putImageData(overlayData, 0, 0);

  // Combinar: imagen posterizada + bordes
  ctx.drawImage(edgeOverlay, 0, 0);

  // Guardar
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(outputPath, buffer);
}

// === FALLBACK: Puppeteer con CSS filters ===
async function generateWithPuppeteerCSS() {
  const puppeteer = require('puppeteer');

  let candidates;
  if (fs.existsSync(DETAILED_FILE)) {
    candidates = JSON.parse(fs.readFileSync(DETAILED_FILE, 'utf8')).candidates;
  } else if (fs.existsSync(CANDIDATES_FILE)) {
    candidates = JSON.parse(fs.readFileSync(CANDIDATES_FILE, 'utf8')).candidates;
  } else {
    console.log('Error: No hay datos de candidatos.');
    return;
  }

  const withPhotos = candidates.filter((c, i) => {
    const id = c.dni || slugify(c.nombre) || `candidato_${i}`;
    return fs.existsSync(path.join(PHOTOS_DIR, `${id}.jpg`));
  });

  const toProcess = LIMIT > 0 ? withPhotos.slice(0, LIMIT) : withPhotos;

  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
  const page = await browser.newPage();

  let success = 0;

  for (let i = 0; i < toProcess.length; i++) {
    const candidate = toProcess[i];
    const id = candidate.dni || slugify(candidate.nombre) || `candidato_${i}`;
    const photoPath = path.join(PHOTOS_DIR, `${id}.jpg`).replace(/\\/g, '/');
    const outputPath = path.join(CARICATURES_DIR, `${id}.png`);

    if (fs.existsSync(outputPath)) continue;

    try {
      // Crear pagina HTML con filtros CSS cartoon
      const html = `
        <html><body style="margin:0;padding:0;background:#fff;">
        <div style="position:relative;display:inline-block;">
          <img id="photo" src="file:///${photoPath}"
            style="
              filter: contrast(1.4) saturate(1.8) brightness(1.1);
              -webkit-filter: contrast(1.4) saturate(1.8) brightness(1.1);
            " />
          <svg style="position:absolute;top:0;left:0;width:100%;height:100%;">
            <filter id="cartoon">
              <feGaussianBlur stdDeviation="2" result="blur"/>
              <feColorMatrix type="saturate" values="2" in="blur" result="saturated"/>
              <feComponentTransfer in="saturated" result="posterized">
                <feFuncR type="discrete" tableValues="0 0.2 0.4 0.6 0.8 1"/>
                <feFuncG type="discrete" tableValues="0 0.2 0.4 0.6 0.8 1"/>
                <feFuncB type="discrete" tableValues="0 0.2 0.4 0.6 0.8 1"/>
              </feComponentTransfer>
            </filter>
            <image href="file:///${photoPath}" width="100%" height="100%" filter="url(#cartoon)"/>
          </svg>
        </div>
        </body></html>`;

      await page.setContent(html, { waitUntil: 'networkidle0' });

      const img = await page.$('#photo');
      if (img) {
        await img.screenshot({ path: outputPath, type: 'png' });
        success++;
        console.log(`[${i + 1}/${toProcess.length}] ${candidate.nombre || id} - OK`);
      }
    } catch (e) {
      console.log(`[${i + 1}/${toProcess.length}] Error: ${e.message}`);
    }
  }

  await browser.close();
  console.log(`\nCaricaturas CSS generadas: ${success}`);
}

// === MODO PAGO: Replicate ===
async function generateWithReplicate(inputPath, outputPath) {
  const imageBuffer = fs.readFileSync(inputPath);
  const base64 = imageBuffer.toString('base64');
  const dataUri = `data:image/jpeg;base64,${base64}`;

  const createBody = JSON.stringify({
    version: 'a07f252abbbd832009640b27f063ea52d87d7a23a185ca165bec23b5b6571ad9',
    input: {
      image: dataUri,
      prompt: 'Transform into colorful political cartoon caricature, exaggerated features, satirical style, bold colors, simple background',
      num_inference_steps: 30,
      image_guidance_scale: 1.2,
      guidance_scale: 7
    }
  });

  const prediction = await makeRequest('POST', 'api.replicate.com', '/v1/predictions', {
    'Authorization': `Bearer ${REPLICATE_API_TOKEN}`,
    'Content-Type': 'application/json'
  }, createBody);

  let result = prediction;
  let attempts = 0;
  while (result.status !== 'succeeded' && result.status !== 'failed' && attempts < 60) {
    await sleep(3000);
    result = await makeRequest('GET', 'api.replicate.com', `/v1/predictions/${prediction.id}`, {
      'Authorization': `Bearer ${REPLICATE_API_TOKEN}`
    });
    attempts++;
  }

  if (result.status === 'failed') throw new Error(`Replicate: ${result.error}`);
  if (!result.output) throw new Error('No output');

  const outputUrl = Array.isArray(result.output) ? result.output[0] : result.output;
  await downloadFile(outputUrl, outputPath);
}

// === MODO PAGO: Stability ===
async function generateWithStability(inputPath, outputPath) {
  const imageBuffer = fs.readFileSync(inputPath);
  const base64 = imageBuffer.toString('base64');

  const body = JSON.stringify({
    text_prompts: [{
      text: 'Political cartoon caricature, exaggerated features, satirical illustration, colorful, bold outlines',
      weight: 1
    }],
    init_image: base64,
    init_image_mode: 'IMAGE_STRENGTH',
    image_strength: 0.4,
    cfg_scale: 7, samples: 1, steps: 30,
    style_preset: 'comic-book'
  });

  const result = await makeRequest('POST', 'api.stability.ai',
    '/v1/generation/stable-diffusion-xl-1024-v1-0/image-to-image', {
      'Authorization': `Bearer ${STABILITY_API_KEY}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }, body);

  if (result.artifacts && result.artifacts[0]) {
    fs.writeFileSync(outputPath, Buffer.from(result.artifacts[0].base64, 'base64'));
  } else {
    throw new Error('No artifacts');
  }
}

function makeRequest(method, hostname, apiPath, headers, body) {
  return new Promise((resolve, reject) => {
    const req = https.request({ hostname, path: apiPath, method, headers, timeout: 120000 }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch { reject(new Error(data.substring(0, 200))); } });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    https.get(url, { timeout: 60000 }, (res) => {
      if (res.statusCode === 301 || res.statusCode === 302)
        return downloadFile(res.headers.location, destPath).then(resolve).catch(reject);
      if (res.statusCode !== 200) return reject(new Error(`HTTP ${res.statusCode}`));
      const file = fs.createWriteStream(destPath);
      res.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', reject);
  });
}

function slugify(text) {
  if (!text) return null;
  return text.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .substring(0, 60);
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

generateCaricatures().catch(err => { console.error('Error:', err); process.exit(1); });
