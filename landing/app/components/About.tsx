export default function About() {
  return (
    <section className="py-20 px-6 border-t border-gray-800/50">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-3xl font-bold text-white text-center mb-8">
          Sobre el proyecto
        </h2>

        <div className="space-y-6 text-gray-400 text-sm leading-relaxed">
          <div className="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
            <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
              <span className="text-amber-400">📋</span> Metodología
            </h3>
            <p>
              Los datos provienen de la plataforma{" "}
              <a
                href="https://votoinformado.jne.gob.pe"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-400 underline"
              >
                Voto Informado del JNE
              </a>
              , fuente oficial de hojas de vida de candidatos. Se analizaron
              antecedentes penales, procesos judiciales, cambios de partido, y
              declaraciones juradas.
            </p>
          </div>

          <div className="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
            <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
              <span className="text-red-400">🔗</span> Fuentes verificadas
            </h3>
            <p>
              Cada controversia incluye enlaces a fuentes periodísticas verificadas.
              Se consultaron medios como RPP, El Comercio, La República, Gestión,
              Infobae, Ojo Público y documentos del Poder Judicial.
            </p>
          </div>

          <div className="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
            <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
              <span className="text-green-400">📊</span> Índice de Floro
            </h3>
            <p>
              El puntaje se calcula en 6 ejes: incoherencia, promesas inviables,
              opacidad, populismo, victimismo estratégico y reciclaje político.
              Cada eje se evalúa de 0 a 20 puntos, más bonificaciones por
              antecedentes graves.
            </p>
          </div>

          <div className="bg-gray-900/50 rounded-xl p-6 border border-gray-800">
            <h3 className="text-white font-semibold mb-2 flex items-center gap-2">
              <span className="text-purple-400">⚖️</span> Descargo
            </h3>
            <p>
              Este es un proyecto satírico e informativo. Las caricaturas son
              generadas por IA con fines humorísticos. La información presentada
              se basa en fuentes públicas y verificables. Invitamos a cada usuario
              a verificar los datos por su cuenta usando los enlaces proporcionados.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-16 text-center">
          <p className="text-gray-600 text-xs">
            Radar del Floro — Proyecto independiente para las Elecciones Generales
            Perú 2026
          </p>
          <p className="text-gray-700 text-xs mt-1">
            Vota informado el 12 de abril 🗳️
          </p>
        </div>
      </div>
    </section>
  );
}
