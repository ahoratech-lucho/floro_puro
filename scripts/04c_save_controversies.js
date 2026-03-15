/**
 * Script 04c: Guardar controversias desde JSON input
 *
 * Lee un archivo JSON con array de controversias y los guarda
 * como archivos individuales en data/controversies/{slug}.json
 *
 * Uso: node scripts/04c_save_controversies.js <input_file.json>
 *   o: cat input.json | node scripts/04c_save_controversies.js --stdin
 */

const fs = require('fs');
const path = require('path');

const CONTROVERSIES_DIR = path.join(__dirname, '..', 'data', 'controversies');
if (!fs.existsSync(CONTROVERSIES_DIR)) fs.mkdirSync(CONTROVERSIES_DIR, { recursive: true });

function slugify(text) {
  if (!text) return null;
  return text.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .substring(0, 60);
}

function saveControversies(candidates) {
  let saved = 0;
  let skipped = 0;

  for (const candidate of candidates) {
    const slug = candidate.slug || slugify(candidate.nombre);
    if (!slug) {
      console.log(`  Skipped: no slug/nombre`);
      skipped++;
      continue;
    }

    const filePath = path.join(CONTROVERSIES_DIR, `${slug}.json`);

    // If file already exists, merge (keep higher risk level)
    let existing = null;
    if (fs.existsSync(filePath)) {
      existing = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    }

    const output = {
      nombre: candidate.nombre,
      slug,
      searchedAt: new Date().toISOString(),
      analysis: candidate.analysis || {}
    };

    // Merge if existing has more data
    if (existing && existing.analysis) {
      const ea = existing.analysis;
      const na = output.analysis;
      // Keep the one with more content
      if ((ea.controversias || []).length > (na.controversias || []).length) {
        output.analysis.controversias = [...new Set([...(na.controversias || []), ...(ea.controversias || [])])];
      }
      if ((ea.banderas_rojas || []).length > (na.banderas_rojas || []).length) {
        output.analysis.banderas_rojas = [...new Set([...(na.banderas_rojas || []), ...(ea.banderas_rojas || [])])];
      }
    }

    fs.writeFileSync(filePath, JSON.stringify(output, null, 2));
    saved++;
    console.log(`  Saved: ${slug} (riesgo: ${output.analysis.nivel_riesgo || 'n/a'})`);
  }

  console.log(`\nTotal: ${saved} saved, ${skipped} skipped`);
  return saved;
}

// Main
const args = process.argv.slice(2);
if (args[0] === '--stdin') {
  let data = '';
  process.stdin.on('data', chunk => data += chunk);
  process.stdin.on('end', () => {
    const candidates = JSON.parse(data);
    saveControversies(Array.isArray(candidates) ? candidates : [candidates]);
  });
} else if (args[0]) {
  const data = JSON.parse(fs.readFileSync(args[0], 'utf8'));
  saveControversies(Array.isArray(data) ? data : [data]);
} else {
  console.log('Usage: node 04c_save_controversies.js <file.json> | --stdin');
}
