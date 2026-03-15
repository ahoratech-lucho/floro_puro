/**
 * Script 04b: Analisis de controversias con Claude Code
 *
 * Este script NO se ejecuta con "node". Lo usa Claude Code
 * para leer los resultados de busqueda y generar el analisis.
 *
 * FLUJO:
 * 1. El usuario pide a Claude Code: "analiza las controversias"
 * 2. Claude Code lee los archivos de data/search_results/
 * 3. Claude Code genera el analisis en data/controversies/
 * 4. Todo gratis con el Plan Max
 *
 * FORMATO DE SALIDA (data/controversies/{dni}.json):
 * {
 *   "investigatedAt": "2026-03-14T...",
 *   "candidate": { nombre, dni, partido, cargo },
 *   "searchResults": [...],
 *   "analysis": {
 *     "nombre": "...",
 *     "resumen": "...",
 *     "antecedentes_penales": [],
 *     "denuncias_publicas": [],
 *     "cambios_partido": [],
 *     "controversias": [],
 *     "pension_alimenticia": "si/no/no determinado",
 *     "procesos_judiciales": [],
 *     "nivel_riesgo": "bajo/medio/alto/muy alto",
 *     "banderas_rojas": [],
 *     "fuentes": []
 *   }
 * }
 */

// Este archivo es documentacion del formato.
// Para ejecutar el analisis, pide a Claude Code:
//
// "Lee los archivos en data/search_results/ y genera
//  el analisis de controversias para cada candidato
//  guardandolos en data/controversies/"

console.log('Este script es documentacion del formato.');
console.log('Para analizar, pide a Claude Code que lea data/search_results/');
console.log('y genere los analisis en data/controversies/');
