export default function DownloadSection() {
  return (
    <section className="py-20 px-6 bg-gray-50" id="descargar">
      <div className="max-w-2xl mx-auto text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">
          Descarga el juego
        </h2>
        <p className="text-gray-500 mb-8">
          Disponible para Android. Descarga la APK e instálala en tu dispositivo.
        </p>

        <a
          href="/downloads/radar-del-floro.apk"
          className="inline-flex items-center gap-3 bg-[#8B1A1A]/85 backdrop-blur-xl text-white font-bold py-4 px-10 rounded-2xl text-lg hover:bg-[#6B1414]/95 transition-all shadow-xl shadow-[#8B1A1A]/20 border border-white/15"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
          </svg>
          Descargar APK
        </a>

        <div className="mt-8 grid grid-cols-3 gap-4 max-w-sm mx-auto">
          <InfoPill
            icon={<svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3" /></svg>}
            label="Android"
            sub="Plataforma"
          />
          <InfoPill
            icon={<svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" /></svg>}
            label="2,562"
            sub="Candidatos"
          />
          <InfoPill
            icon={<svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>}
            label="Gratis"
            sub="Precio"
          />
        </div>

        <div className="mt-8 p-4 bg-amber-50 rounded-xl border border-amber-200">
          <p className="text-amber-700 text-sm flex items-start gap-2">
            <svg className="w-5 h-5 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
            </svg>
            <span><strong>Nota:</strong> Al instalar, Android puede mostrar una advertencia de &ldquo;fuente desconocida&rdquo;. Es normal para APKs descargadas fuera de Play Store. Acepta para continuar.</span>
          </p>
        </div>
      </div>
    </section>
  );
}

function InfoPill({ icon, label, sub }: { icon: React.ReactNode; label: string; sub: string }) {
  return (
    <div className="text-center bg-white rounded-xl p-3 border border-gray-100 flex flex-col items-center gap-1">
      <div className="text-[#8B1A1A]">{icon}</div>
      <div className="text-gray-900 font-bold text-sm">{label}</div>
      <div className="text-gray-400 text-xs">{sub}</div>
    </div>
  );
}
