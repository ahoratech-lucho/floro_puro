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
              <svg className="w-5 h-5 text-[#8B1A1A]" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25z" /></svg>
              Metodología
            </h3>
            <p>
              Los datos provienen de la plataforma{" "}
              <a href="https://votoinformado.jne.gob.pe" target="_blank" rel="noopener noreferrer" className="text-[#8B1A1A] underline">
                Voto Informado del JNE
              </a>
              , fuente oficial de hojas de vida de candidatos. Se analizaron antecedentes penales, procesos judiciales, cambios de partido, y declaraciones juradas.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <svg className="w-5 h-5 text-[#8B1A1A]" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m9.86-2.54a4.5 4.5 0 00-6.364-6.364L4.5 8.688" /></svg>
              Fuentes verificadas
            </h3>
            <p>
              Cada controversia incluye enlaces a fuentes periodísticas verificadas. Se consultaron medios como RPP, El Comercio, La República, Gestión, Infobae, Ojo Público y documentos del Poder Judicial.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <svg className="w-5 h-5 text-[#8B1A1A]" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z" /></svg>
              Índice de Floro
            </h3>
            <p>
              El puntaje se calcula en 6 ejes: incoherencia, promesas inviables, opacidad, populismo, victimismo estratégico y reciclaje político. Cada eje se evalúa de 0 a 20 puntos, más bonificaciones por antecedentes graves.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
            <h3 className="text-gray-900 font-semibold mb-2 flex items-center gap-2">
              <svg className="w-5 h-5 text-[#8B1A1A]" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m0-10.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" /></svg>
              Descargo
            </h3>
            <p>
              Este es un proyecto satírico e informativo. Las caricaturas son generadas por IA con fines humorísticos. La información presentada se basa en fuentes públicas y verificables. Invitamos a cada usuario a verificar los datos por su cuenta usando los enlaces proporcionados.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
