"use client";

export default function Hero() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center px-6 py-20 overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-gray-950 via-red-950/20 to-gray-950" />

      {/* Content */}
      <div className="relative z-10 text-center max-w-2xl mx-auto">
        <div className="text-7xl mb-6 animate-bounce">🔍</div>

        <h1 className="text-5xl md:text-6xl font-black text-white mb-4 tracking-tight">
          RADAR DEL <span className="text-red-500">FLORO</span>
        </h1>

        <p className="text-xl md:text-2xl text-amber-400 font-semibold mb-2">
          Elecciones Perú 2026
        </p>

        <p className="text-gray-400 text-lg mb-8 max-w-md mx-auto">
          ¿Puedes detectar el floro político? Desliza para juzgar a los candidatos con datos reales del JNE.
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12">
          <a
            href="/downloads/radar-del-floro.apk"
            className="bg-red-600 hover:bg-red-700 text-white font-bold py-4 px-8 rounded-2xl text-lg transition-all transform hover:scale-105 shadow-lg shadow-red-600/30 flex items-center gap-2"
          >
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M17.523 2.235a.5.5 0 0 0-.866-.015l-1.69 2.86a8.5 8.5 0 0 0-5.934 0L7.343 2.22a.5.5 0 0 0-.866.015.5.5 0 0 0 .046.488l1.618 2.74A8.5 8.5 0 0 0 3.5 12.5h17a8.5 8.5 0 0 0-4.641-7.037l1.618-2.74a.5.5 0 0 0 .046-.488zM8.5 9.5a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2zM3.5 13.5v6A2.5 2.5 0 0 0 6 22h12a2.5 2.5 0 0 0 2.5-2.5v-6h-17z"/>
            </svg>
            Descargar APK
          </a>
        </div>

        {/* Stats */}
        <div className="flex gap-6 justify-center flex-wrap">
          <Stat number="2,600" label="candidatos" />
          <Stat number="33" label="investigados" />
          <Stat number="78" label="fuentes verificadas" />
        </div>
      </div>

      {/* Scroll hint */}
      <div className="absolute bottom-8 text-gray-500 animate-pulse">
        <svg className="w-6 h-6 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
        </svg>
      </div>
    </section>
  );
}

function Stat({ number, label }: { number: string; label: string }) {
  return (
    <div className="text-center">
      <div className="text-2xl font-black text-white">{number}</div>
      <div className="text-xs text-gray-500 uppercase tracking-wide">{label}</div>
    </div>
  );
}
