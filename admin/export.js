require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function main() {
  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });
  await client.connect();

  const result = await client.query('SELECT * FROM candidates ORDER BY nombre');
  const cards = result.rows.map(r => ({
    id: r.id,
    nombre: r.nombre,
    partido: r.partido,
    cargo: r.cargo,
    region: r.region || undefined,
    foto: r.foto,
    caricatura: r.caricatura,
    frase: r.frase,
    senales: r.senales || [],
    antecedentes: r.antecedentes || [],
    controversias: r.controversias || [],
    pensionAlimenticia: r.pension_alimenticia || undefined,
    procesosJudiciales: r.procesos_judiciales || [],
    cambiosPartido: r.cambios_partido || [],
    indiceFloro: r.indice_floro,
    puntajes: r.puntajes || {},
    nivel: r.nivel,
    nivelRiesgo: r.nivel_riesgo,
    respuestaIdeal: r.respuesta_ideal,
    patronDominante: r.patron_dominante,
    fraseNarrador: r.frase_narrador,
    fuentes: r.fuentes || [],
    dni: r.dni || undefined,
    linkJNE: r.link_jne || undefined,
  }));

  // Stats
  const stats = {
    total: cards.length,
    conFoto: cards.filter(c => c.foto).length,
    conCaricatura: cards.filter(c => c.caricatura).length,
    conControversias: cards.filter(c => c.controversias.length > 0).length,
  };

  const gameData = {
    generatedAt: new Date().toISOString(),
    election: 'Elecciones Generales 2026',
    gameVersion: '2.0',
    stats,
    cards,
  };

  // Write to data/
  const dataPath = path.join(__dirname, '..', 'data', 'game_data.json');
  fs.writeFileSync(dataPath, JSON.stringify(gameData, null, 2), 'utf-8');
  console.log(`Exported ${cards.length} candidates to ${dataPath}`);

  // Copy to Flutter assets
  const flutterPath = path.join(__dirname, '..', 'flutter_app', 'assets', 'game_data.json');
  if (fs.existsSync(path.dirname(flutterPath))) {
    fs.copyFileSync(dataPath, flutterPath);
    console.log(`Copied to ${flutterPath}`);
  }

  await client.end();
  console.log('Export complete!');
}

main().catch(err => {
  console.error('Export failed:', err.message);
  process.exit(1);
});
