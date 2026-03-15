/**
 * Script 07: Optimizar imagenes para CDN
 *
 * Convierte fotos (JPG) y caricaturas (PNG) a WebP optimizado
 * para servir desde Vercel como CDN.
 *
 * Uso: node scripts/07_optimize_images.js [--caricatures-only] [--photos-only]
 */

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const PHOTOS_SRC = path.join(__dirname, '..', 'data', 'photos');
const CARICATURES_SRC = path.join(__dirname, '..', 'data', 'caricatures');
const PHOTOS_DEST = path.join(__dirname, '..', 'landing', 'public', 'images', 'photos');
const CARICATURES_DEST = path.join(__dirname, '..', 'landing', 'public', 'images', 'caricatures');

const args = process.argv.slice(2);
const CARICATURES_ONLY = args.includes('--caricatures-only');
const PHOTOS_ONLY = args.includes('--photos-only');

async function optimizeImages() {
  console.log('=== Optimizacion de Imagenes para CDN ===\n');

  // Ensure output dirs
  [PHOTOS_DEST, CARICATURES_DEST].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  });

  let totalSaved = 0;

  // Photos: JPG -> WebP, max 400px wide, 75% quality
  if (!CARICATURES_ONLY) {
    const photos = fs.readdirSync(PHOTOS_SRC).filter(f => f.endsWith('.jpg'));
    console.log(`Fotos: ${photos.length} archivos`);
    let done = 0;
    let errors = 0;

    for (const file of photos) {
      const src = path.join(PHOTOS_SRC, file);
      const dest = path.join(PHOTOS_DEST, file.replace('.jpg', '.webp'));

      if (fs.existsSync(dest)) { done++; continue; }

      try {
        const srcSize = fs.statSync(src).size;
        await sharp(src)
          .resize({ width: 400, withoutEnlargement: true })
          .webp({ quality: 75 })
          .toFile(dest);
        const destSize = fs.statSync(dest).size;
        totalSaved += srcSize - destSize;
        done++;
      } catch (e) {
        errors++;
      }

      if (done % 500 === 0) {
        console.log(`  Fotos: ${done}/${photos.length} (${errors} errores)`);
      }
    }
    console.log(`  Fotos completadas: ${done}/${photos.length} (${errors} errores)`);
  }

  // Caricatures: PNG -> WebP, max 512px wide, 80% quality
  if (!PHOTOS_ONLY) {
    const caricatures = fs.readdirSync(CARICATURES_SRC).filter(f => f.endsWith('.png'));
    console.log(`Caricaturas: ${caricatures.length} archivos`);
    let done = 0;
    let errors = 0;

    for (const file of caricatures) {
      const src = path.join(CARICATURES_SRC, file);
      const dest = path.join(CARICATURES_DEST, file.replace('.png', '.webp'));

      if (fs.existsSync(dest)) { done++; continue; }

      try {
        const srcSize = fs.statSync(src).size;
        await sharp(src)
          .resize({ width: 512, withoutEnlargement: true })
          .webp({ quality: 80 })
          .toFile(dest);
        const destSize = fs.statSync(dest).size;
        totalSaved += srcSize - destSize;
        done++;
      } catch (e) {
        errors++;
      }

      if (done % 500 === 0) {
        console.log(`  Caricaturas: ${done}/${caricatures.length} (${errors} errores)`);
      }
    }
    console.log(`  Caricaturas completadas: ${done}/${caricatures.length} (${errors} errores)`);
  }

  console.log(`\n=== Resultado ===`);
  console.log(`Ahorro total: ${(totalSaved / 1024 / 1024).toFixed(1)} MB`);

  // Stats
  const photoDest = fs.readdirSync(PHOTOS_DEST).filter(f => f.endsWith('.webp'));
  const caricDest = fs.readdirSync(CARICATURES_DEST).filter(f => f.endsWith('.webp'));
  const photoSize = photoDest.reduce((sum, f) => sum + fs.statSync(path.join(PHOTOS_DEST, f)).size, 0);
  const caricSize = caricDest.reduce((sum, f) => sum + fs.statSync(path.join(CARICATURES_DEST, f)).size, 0);

  console.log(`Fotos WebP: ${photoDest.length} archivos (${(photoSize / 1024 / 1024).toFixed(1)} MB)`);
  console.log(`Caricaturas WebP: ${caricDest.length} archivos (${(caricSize / 1024 / 1024).toFixed(1)} MB)`);
  console.log(`Total CDN: ${((photoSize + caricSize) / 1024 / 1024).toFixed(1)} MB`);
}

optimizeImages().catch(err => { console.error('Error:', err); process.exit(1); });
