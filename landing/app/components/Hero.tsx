"use client";

const CARICATURES = [
  "keiko_sofia_fujimori_higuchi",
  "rafael_bernardo_lopez_aliaga_cazorla",
  "george_patrick_forsyth_sommer",
  "cesar_acuna_peralta",
  "jose_leon_luna_galvez",
  "vladimir_roy_cerron_rojas",
  "roberto_enrique_chiabra_leon",
  "ricardo_pablo_belmont_cassinelli",
  "jose_daniel_williams_zapata",
  "jorge_nieto_montesinos",
  "napoleon_becerra_garcia",
  "pablo_alfonso_lopez_chau_nava",
];

export default function Hero() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center px-6 py-20 overflow-hidden">
      {/* Floating caricatures B&W very subtle */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {CARICATURES.map((name, i) => (
          <div
            key={name}
            className="absolute rounded-full overflow-hidden opacity-[0.04] grayscale"
            style={{
              width: `${80 + (i % 3) * 30}px`,
              height: `${80 + (i % 3) * 30}px`,
              top: `${5 + (i * 8) % 85}%`,
              left: i % 2 === 0 ? `${2 + (i * 7) % 15}%` : `${83 - (i * 5) % 15}%`,
              transform: `rotate(${-15 + (i * 7) % 30}deg)`,
            }}
          >
            <img
              src={`/images/caricaturas/${name}.webp`}
              alt=""
              className="w-full h-full object-cover"
              loading="lazy"
            />
          </div>
        ))}
      </div>

      {/* Content */}
      <div className="relative z-10 text-center max-w-2xl mx-auto">
        <p className="text-xs tracking-[0.3em] text-gray-400 uppercase mb-2">Edici&oacute;n Especial</p>

        <h1 className="text-5xl md:text-6xl font-black text-gray-900 mb-2 tracking-tight font-serif">
          RADAR DEL FLORO
        </h1>

        <div className="w-24 h-[2px] bg-red-600 mx-auto mb-4" />

        <p className="text-sm text-gray-500 mb-2">
          Gu&iacute;a sat&iacute;rica para detectar el floro pol&iacute;tico
        </p>

        <p className="text-lg text-red-600 font-semibold mb-8">
          Elecciones Per&uacute; 2026
        </p>

        {/* CTA Card */}
        <div className="bg-red-600 rounded-3xl p-8 text-white mb-8 shadow-lg max-w-sm mx-auto">
          <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-red-600 font-bold text-lg">?!</span>
          </div>
          <h2 className="text-2xl font-bold mb-2">&iquest;Puedes detectar el floro pol&iacute;tico?</h2>
          <p className="text-red-100 text-sm mb-6">2907 candidatos investigados &middot; 436 con alertas</p>

          <div className="bg-gray-500/40 text-white font-bold py-3 px-6 rounded-2xl text-base inline-block cursor-not-allowed">
            Pr&oacute;ximamente en Android
          </div>
          <p className="text-red-200 text-xs mt-3">Estamos preparando la nueva versi&oacute;n</p>
        </div>

        {/* Stats */}
        <div className="flex gap-6 justify-center flex-wrap">
          <Stat number="2,600+" label="candidatos" />
          <Stat number="33" label="investigados" />
          <Stat number="78" label="fuentes verificadas" />
        </div>
      </div>

      {/* Scroll hint */}
      <div className="absolute bottom-8 text-gray-400 animate-pulse">
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
      <div className="text-2xl font-black text-gray-900">{number}</div>
      <div className="text-xs text-gray-400 uppercase tracking-wide">{label}</div>
    </div>
  );
}
