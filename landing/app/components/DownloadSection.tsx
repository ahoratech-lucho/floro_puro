export default function DownloadSection() {
  return (
    <section className="py-20 px-6" id="descargar">
      <div className="max-w-2xl mx-auto text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">
          Descarga el juego
        </h2>
        <p className="text-gray-500 mb-8">
          Estamos preparando la nueva versi&oacute;n con m&aacute;s candidatos y funciones.
        </p>

        <div className="inline-flex items-center gap-3 bg-gray-300 text-gray-500 font-bold py-4 px-10 rounded-2xl text-lg cursor-not-allowed">
          <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
            <path d="M17.523 2.235a.5.5 0 0 0-.866-.015l-1.69 2.86a8.5 8.5 0 0 0-5.934 0L7.343 2.22a.5.5 0 0 0-.866.015.5.5 0 0 0 .046.488l1.618 2.74A8.5 8.5 0 0 0 3.5 12.5h17a8.5 8.5 0 0 0-4.641-7.037l1.618-2.74a.5.5 0 0 0 .046-.488zM8.5 9.5a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2zM3.5 13.5v6A2.5 2.5 0 0 0 6 22h12a2.5 2.5 0 0 0 2.5-2.5v-6h-17z"/>
          </svg>
          Pr&oacute;ximamente
        </div>

        <div className="mt-8 grid grid-cols-3 gap-4 max-w-sm mx-auto">
          <InfoPill label="Android" sub="Plataforma" />
          <InfoPill label="2,600+" sub="Candidatos" />
          <InfoPill label="Gratis" sub="Precio" />
        </div>

        <div className="mt-8 p-4 bg-amber-50 rounded-xl border border-amber-200">
          <p className="text-amber-700 text-sm">
            La descarga estar&aacute; disponible pronto. Mientras tanto, explora los candidatos en esta p&aacute;gina.
          </p>
        </div>
      </div>
    </section>
  );
}

function InfoPill({ label, sub }: { label: string; sub: string }) {
  return (
    <div className="text-center">
      <div className="text-gray-900 font-bold text-sm">{label}</div>
      <div className="text-gray-400 text-xs">{sub}</div>
    </div>
  );
}
