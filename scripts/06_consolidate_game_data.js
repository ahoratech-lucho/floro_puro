/**
 * Script 06: Consolidar datos para el juego
 *
 * Combina toda la data recopilada en un solo game_data.json
 * listo para usar en el frontend del juego.
 *
 * Uso: node scripts/06_consolidate_game_data.js
 */

const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const DETAILED_FILE = path.join(DATA_DIR, 'candidates_detailed.json');
const CANDIDATES_FILE = path.join(DATA_DIR, 'candidates.json');
const CONTROVERSIES_DIR = path.join(DATA_DIR, 'controversies');
const ENRICHMENT_DIR = path.join(DATA_DIR, 'enrichment_results');
const PHOTOS_DIR = path.join(DATA_DIR, 'photos');
const CARICATURES_DIR = path.join(DATA_DIR, 'caricatures');
const OUTPUT_FILE = path.join(DATA_DIR, 'game_data.json');

// Sistema de puntuacion del Radar del Floro
const SCORING = {
  incoherencia: { max: 25 },
  promesasInviables: { max: 25 },
  opacidad: { max: 20 },
  populismo: { max: 15 },
  victimismoEstrategico: { max: 10 },
  reciclajePolitico: { max: 5 }
};

// Helper: ensure value is array
function toArraySafe(val) {
  if (Array.isArray(val)) return val;
  if (typeof val === 'string' && val.length > 0) return [val];
  return [];
}

function consolidate() {
  console.log('=== Consolidacion de Datos para Radar del Floro ===\n');

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

  console.log(`Candidatos base: ${candidates.length}`);

  // Count enrichment files available
  let enrichmentCount = 0;
  if (fs.existsSync(ENRICHMENT_DIR)) {
    enrichmentCount = fs.readdirSync(ENRICHMENT_DIR).filter(f => f.endsWith('.json')).length;
  }
  let controversyCount = 0;
  if (fs.existsSync(CONTROVERSIES_DIR)) {
    controversyCount = fs.readdirSync(CONTROVERSIES_DIR).filter(f => f.endsWith('.json')).length;
  }
  console.log(`Archivos en controversies/: ${controversyCount}`);
  console.log(`Archivos en enrichment_results/: ${enrichmentCount}`);

  let fromControversies = 0;
  let fromEnrichment = 0;
  let noData = 0;

  const gameCards = [];

  for (let i = 0; i < candidates.length; i++) {
    const c = candidates[i];
    const id = c.dni || slugify(c.nombre) || `candidato_${i}`;

    // Cargar controversias: primero controversies/, luego enrichment_results/
    let controversy = null;
    const slugId = slugify(c.nombre);

    // 1. Buscar en controversies/ por DNI o slug (formato antiguo: .analysis)
    const contFile = path.join(CONTROVERSIES_DIR, `${id}.json`);
    const contFileSlug = path.join(CONTROVERSIES_DIR, `${slugId}.json`);
    if (fs.existsSync(contFile)) {
      controversy = JSON.parse(fs.readFileSync(contFile, 'utf8')).analysis;
    } else if (slugId && slugId !== id && fs.existsSync(contFileSlug)) {
      controversy = JSON.parse(fs.readFileSync(contFileSlug, 'utf8')).analysis;
    }

    // Track source
    const fromContDir = !!controversy;

    // 2. Si no se encontro, buscar en enrichment_results/ (formato nuevo: .enrichment)
    if (!controversy) {
      const enrichFile = path.join(ENRICHMENT_DIR, `${slugId}.json`);
      const enrichFileId = path.join(ENRICHMENT_DIR, `${id}.json`);
      let enrichData = null;
      if (slugId && fs.existsSync(enrichFile)) {
        enrichData = JSON.parse(fs.readFileSync(enrichFile, 'utf8')).enrichment;
      } else if (fs.existsSync(enrichFileId)) {
        enrichData = JSON.parse(fs.readFileSync(enrichFileId, 'utf8')).enrichment;
      }

      // Normalizar formato enrichment -> formato controversy
      if (enrichData) {
        controversy = {
          controversias: enrichData.controversias || [],
          banderas_rojas: enrichData.senales || [],
          antecedentes_penales: enrichData.antecedentes || [],
          procesos_judiciales: enrichData.procesosJudiciales || [],
          cambios_partido: enrichData.cambiosPartido || [],
          pension_alimenticia: enrichData.pensionAlimenticia === true ? 'si' : (enrichData.pensionAlimenticia === false ? 'no' : (enrichData.pensionAlimenticia || 'no determinado')),
          resumen: enrichData.frase || '',
          nivel_riesgo: (enrichData.patronDominante || '').toLowerCase() === 'peligroso' ? 'muy alto' :
                        (enrichData.patronDominante || '').toLowerCase() === 'florero' ? 'alto' :
                        (enrichData.patronDominante || '').toLowerCase() === 'sospechoso' ? 'medio' : 'bajo',
          fuentes: enrichData.fuentes || [],
          // Preserve enrichment-specific fields
          _fraseNarrador: enrichData.fraseNarrador || '',
          _patronDominante: enrichData.patronDominante || '',
        };
      }
    }

    // Verificar assets
    const hasPhoto = fs.existsSync(path.join(PHOTOS_DIR, `${id}.jpg`));
    const hasCaricature = fs.existsSync(path.join(CARICATURES_DIR, `${id}.png`));

    // Calcular puntajes del Indice de Floro
    const scores = calculateScores(c, controversy);

    // Determinar respuesta ideal del jugador
    const idealResponse = getIdealResponse(scores.total);

    // Generar frase del narrador
    const narratorPhrase = generateNarratorPhrase(scores, controversy);

    // Determinar patron dominante
    const dominantPattern = getDominantPattern(scores);

    const card = {
      id,
      nombre: c.nombre,
      partido: c.partido,
      cargo: c.cargo,
      region: c.region || c.distrito,

      // Assets
      foto: hasPhoto ? `photos/${id}.jpg` : null,
      caricatura: hasCaricature ? `caricatures/${id}.png` : null,

      // Frase de campana o declaracion
      frase: controversy?.resumen || `Candidato de ${c.partido || 'partido no identificado'}`,

      // Senales de alerta (ensure arrays)
      senales: toArraySafe(controversy?.banderas_rojas),
      antecedentes: toArraySafe(controversy?.antecedentes_penales),
      controversias: toArraySafe(controversy?.controversias),
      pensionAlimenticia: controversy?.pension_alimenticia || 'no determinado',
      procesosJudiciales: toArraySafe(controversy?.procesos_judiciales),
      cambiosPartido: toArraySafe(controversy?.cambios_partido),

      // Puntajes
      indiceFloro: scores.total,
      puntajes: {
        incoherencia: scores.incoherencia,
        promesasInviables: scores.promesasInviables,
        opacidad: scores.opacidad,
        populismo: scores.populismo,
        victimismoEstrategico: scores.victimismoEstrategico,
        reciclajePolitico: scores.reciclajePolitico
      },

      // Nivel
      nivel: getLevel(scores.total),
      nivelRiesgo: controversy?.nivel_riesgo || 'no determinado',

      // Juego
      respuestaIdeal: idealResponse,
      patronDominante: controversy?._patronDominante || dominantPattern,
      fraseNarrador: controversy?._fraseNarrador || narratorPhrase,

      // Fuentes
      fuentes: controversy?.fuentes || []
    };

    // Count sources
    if (controversy && fromContDir) fromControversies++;
    else if (controversy && !fromContDir) fromEnrichment++;
    else noData++;

    gameCards.push(card);
  }

  // Ordenar por indice de floro (mayor primero)
  gameCards.sort((a, b) => b.indiceFloro - a.indiceFloro);

  // Estadisticas
  const stats = {
    total: gameCards.length,
    conFoto: gameCards.filter(c => c.foto).length,
    conCaricatura: gameCards.filter(c => c.caricatura).length,
    conControversias: gameCards.filter(c => c.senales.length > 0).length,
    porNivel: {
      alertaMaxima: gameCards.filter(c => c.nivel === 'Alerta maxima').length,
      banderaRoja: gameCards.filter(c => c.nivel === 'Bandera roja').length,
      muchoFloro: gameCards.filter(c => c.nivel === 'Mucho floro').length,
      dudoso: gameCards.filter(c => c.nivel === 'Dudoso').length,
      pasaRaspando: gameCards.filter(c => c.nivel === 'Pasa raspando').length,
    },
    porPartido: {}
  };

  gameCards.forEach(c => {
    const partido = c.partido || 'Sin partido';
    if (!stats.porPartido[partido]) stats.porPartido[partido] = 0;
    stats.porPartido[partido]++;
  });

  const output = {
    generatedAt: new Date().toISOString(),
    election: 'Peru 2026 - Elecciones Generales',
    gameVersion: '1.0.0',
    stats,
    cards: gameCards
  };

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));

  console.log(`\n=== Fuentes de datos ===`);
  console.log(`  Desde controversies/: ${fromControversies}`);
  console.log(`  Desde enrichment_results/: ${fromEnrichment}`);
  console.log(`  Sin datos: ${noData}`);
  console.log(`\n=== Resultado ===`);
  console.log(`Total cartas: ${stats.total}`);
  console.log(`Con foto: ${stats.conFoto}`);
  console.log(`Con caricatura: ${stats.conCaricatura}`);
  console.log(`Con controversias: ${stats.conControversias}`);
  console.log(`\nDistribucion por nivel:`);
  Object.entries(stats.porNivel).forEach(([k, v]) => console.log(`  ${k}: ${v}`));
  console.log(`\nGuardado en: ${OUTPUT_FILE}`);
}

function calculateScores(candidate, controversy) {
  const scores = {
    incoherencia: 0,
    promesasInviables: 0,
    opacidad: 0,
    populismo: 0,
    victimismoEstrategico: 0,
    reciclajePolitico: 0
  };

  if (!controversy) {
    return { ...scores, total: 0 };
  }

  // Ensure all fields are arrays (some enrichment files have strings instead)
  const toArray = (val) => {
    if (Array.isArray(val)) return val;
    if (typeof val === 'string' && val.length > 0) return [val];
    return [];
  };

  const flags = toArray(controversy.banderas_rojas).map(f => String(f).toLowerCase());
  const antecedentes = toArray(controversy.antecedentes_penales);
  const controversias = toArray(controversy.controversias);
  const cambios = toArray(controversy.cambios_partido);
  const procesos = toArray(controversy.procesos_judiciales);
  const riesgo = String(controversy.nivel_riesgo || '');

  // Concatenar todo el texto para busqueda amplia
  const allText = [...flags, ...(controversias.map(c => String(c).toLowerCase())),
    ...(antecedentes.map(a => String(a).toLowerCase())),
    ...(procesos.map(p => String(p).toLowerCase())),
    String(controversy.resumen || '').toLowerCase()
  ].join(' | ');

  // Incoherencia (max 25)
  if (cambios.length >= 3) scores.incoherencia += 15;
  else if (cambios.length >= 2) scores.incoherencia += 10;
  else if (cambios.length >= 1) scores.incoherencia += 5;
  if (/incoher|contradic|transfug|golondrin/.test(allText)) scores.incoherencia += 10;
  if (/cambi.{0,10}partido|salt.{0,10}partido/.test(allText)) scores.incoherencia += 5;
  scores.incoherencia = Math.min(scores.incoherencia, SCORING.incoherencia.max);

  // Promesas inviables (max 25)
  if (/promesa|inviable|imposible/.test(allText)) scores.promesasInviables += 15;
  if (/sin plan|sin ruta|sin presupuesto|populis/.test(allText)) scores.promesasInviables += 10;
  if (/demagogia|clientel/.test(allText)) scores.promesasInviables += 5;
  scores.promesasInviables = Math.min(scores.promesasInviables, SCORING.promesasInviables.max);

  // Opacidad (max 20) - expanded patterns
  if (/opac|oculta|no declara|evade|omiti|ocultamiento/.test(allText)) scores.opacidad += 12;
  if (antecedentes.length > 0) scores.opacidad += 8;
  if (antecedentes.length >= 3) scores.opacidad += 5; // multiple records = more opacity
  if (controversy.pension_alimenticia === 'si') scores.opacidad += 5;
  if (/lavado|enriquecimiento|peculado/.test(allText)) scores.opacidad += 8;
  scores.opacidad = Math.min(scores.opacidad, SCORING.opacidad.max);

  // Populismo (max 15)
  if (/populis|demagogia|simplific/.test(allText)) scores.populismo += 10;
  if (/emocional|miedo|odio|polariz/.test(allText)) scores.populismo += 5;
  if (/autoritari|dictad|mano dura/.test(allText)) scores.populismo += 5;
  scores.populismo = Math.min(scores.populismo, SCORING.populismo.max);

  // Victimismo estrategico (max 10)
  if (/victim|persecucion|complot|conspira/.test(allText)) scores.victimismoEstrategico += 10;
  if (/alega.*politica|inocen/.test(allText)) scores.victimismoEstrategico += 5;
  scores.victimismoEstrategico = Math.min(scores.victimismoEstrategico, SCORING.victimismoEstrategico.max);

  // Reciclaje politico (max 5)
  if (cambios.length >= 2) scores.reciclajePolitico += 5;
  else if (cambios.length >= 1) scores.reciclajePolitico += 3;
  if (/reelecc|perpetuar|dinast/.test(allText)) scores.reciclajePolitico += 3;
  scores.reciclajePolitico = Math.min(scores.reciclajePolitico, SCORING.reciclajePolitico.max);

  // Bonus por gravedad de delitos
  let total = Object.values(scores).reduce((a, b) => a + b, 0);

  // Bonus por cantidad de controversias
  if (controversias.length >= 5) total += 15;
  else if (controversias.length >= 3) total += 10;
  else if (controversias.length >= 1) total += 5;

  // Bonus por procesos judiciales
  if (procesos.length >= 3) total += 10;
  else if (procesos.length >= 1) total += 5;

  // Bonus por sentencias/condenas
  if (/sentencia|condena|prision|carcel|reo/.test(allText)) total += 15;
  if (/narcotr|droga|homicid|asesin/.test(allText)) total += 10;
  if (/corrupcion|cohecho|soborno|coima/.test(allText)) total += 10;

  // Bonus por riesgo alto
  if (riesgo === 'muy alto') total += 10;
  else if (riesgo === 'alto') total += 5;

  return { ...scores, total: Math.min(total, 100) };
}

function getLevel(score) {
  if (score >= 81) return 'Alerta maxima';
  if (score >= 61) return 'Bandera roja';
  if (score >= 41) return 'Mucho floro';
  if (score >= 21) return 'Dudoso';
  return 'Pasa raspando';
}

function getIdealResponse(score) {
  if (score >= 70) return 'Puro floro';
  if (score >= 50) return 'Bandera roja';
  if (score >= 30) return 'Sospechoso';
  return 'Pasa raspando';
}

function getDominantPattern(scores) {
  const categories = [
    { name: 'Incoherencia narrativa', score: scores.incoherencia },
    { name: 'Promesa inflada', score: scores.promesasInviables },
    { name: 'Opacidad calculada', score: scores.opacidad },
    { name: 'Populismo simplificador', score: scores.populismo },
    { name: 'Victimismo estrategico', score: scores.victimismoEstrategico },
    { name: 'Reciclaje politico', score: scores.reciclajePolitico },
  ];

  categories.sort((a, b) => b.score - a.score);
  return categories[0].score > 0 ? categories[0].name : 'Sin patron dominante';
}

function generateNarratorPhrase(scores, controversy) {
  const phrases = [];

  if (scores.total >= 80) {
    phrases.push(
      'El radar se encendio completo con este perfil.',
      'Aqui el floro viene con todo.',
      'Nivel de alerta: maximo. El sistema detecto multiples banderas.'
    );
  } else if (scores.total >= 60) {
    phrases.push(
      'Bastante humo detectado en este perfil.',
      'El radar marca varias senales de alerta.',
      'Hay mas floro que plan verificable.'
    );
  } else if (scores.total >= 40) {
    phrases.push(
      'El radar detecto algunas senales sospechosas.',
      'No todo es floro, pero hay zonas grises.',
      'Merece una revision mas detallada.'
    );
  } else if (scores.total >= 20) {
    phrases.push(
      'Pocas senales de alerta, pero conviene estar atento.',
      'El radar marca bajo, aunque no limpio del todo.',
    );
  } else {
    phrases.push(
      'El radar no detecto senales significativas.',
      'Pasa raspando. Sin banderas rojas evidentes.'
    );
  }

  // Agregar detalle de controversias si hay
  if (controversy && controversy.antecedentes_penales && controversy.antecedentes_penales.length > 0) {
    phrases.push('Atencion: se detectaron antecedentes penales/judiciales.');
  }
  if (controversy && controversy.pension_alimenticia === 'si') {
    phrases.push('Nota: registra obligaciones de pension alimenticia.');
  }

  return phrases[Math.floor(Math.random() * Math.min(phrases.length, 3))];
}

function slugify(text) {
  if (!text) return null;
  return text.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .substring(0, 60);
}

consolidate();
