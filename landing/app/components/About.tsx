export default function About() {
  return (
    <section className="py-20 px-6 border-t border-gray-200">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-900 text-center mb-8">
          Sobre el proyecto
        </h2>

        <div className="space-y-6 text-gray-600 text-sm leading-relaxed">
          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <span className="text-amber-500">📋</span> Metodolog&iacute;a
            </h3>
            <p>
              Los datos provienen de la plataforma{" "}
              <a href="https://votoinformado.jne.gob.pe" target="_blank" rel="noopener noreferrer" className="text-red-600 underline">
                Voto Informado del JNE
              </a>
              , fuente oficial de hojas de vida de candidatos. Se analizaron antecedentes penales, procesos judiciales, cambios de partido, y declaraciones juradas.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <span className="text-red-500">🔗</span> Fuentes verificadas
            </h3>
            <p>
              Cada controversia incluye enlaces a fuentes period&iacute;sticas verificadas. Se consultaron medios como RPP, El Comercio, La Rep&uacute;blica, Gesti&oacute;n, Infobae, Ojo P&uacute;blico y documentos del Poder Judicial.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <span className="text-green-500">📊</span> &Iacute;ndice de Floro
            </h3>
            <p>
              El puntaje se calcula en 6 ejes: incoherencia, promesas inviables, opacidad, populismo, victimismo estrat&eacute;gico y reciclaje pol&iacute;tico. Cada eje se eval&uacute;a de 0 a 20 puntos, m&aacute;s bonificaciones por antecedentes graves.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <span className="text-purple-500">⚖️</span> Descargo
            </h3>
            <p>
              Este es un proyecto sat&iacute;rico e informativo. Las caricaturas son generadas por IA con fines humor&iacute;sticos. La informaci&oacute;n presentada se basa en fuentes p&uacute;blicas y verificables. Invitamos a cada usuario a verificar los datos por su cuenta usando los enlaces proporcionados.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-16 text-center">
          <p className="text-gray-400 text-xs">
            Radar del Floro &mdash; Proyecto independiente para las Elecciones Generales Per&uacute; 2026
          </p>
          <p className="text-gray-300 text-xs mt-1">
            Vota informado el 12 de abril
          </p>
        </div>
      </div>
    </section>
  );
}
