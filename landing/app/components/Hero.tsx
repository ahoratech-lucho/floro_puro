"use client";

import { useEffect, useState } from "react";

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

const POSITIONS = [
  { top: 5, left: 10, size: 120 },
  { top: 3, left: 76, size: 115 },
  { top: 22, left: 6, size: 110 },
  { top: 20, left: 80, size: 110 },
  { top: 40, left: 12, size: 105 },
  { top: 42, left: 76, size: 100 },
  { top: 58, left: 8, size: 100 },
  { top: 55, left: 82, size: 105 },
  { top: 72, left: 14, size: 95 },
  { top: 74, left: 74, size: 100 },
  { top: 86, left: 10, size: 90 },
  { top: 84, left: 78, size: 95 },
];

export default function Hero() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center px-6 py-20 overflow-hidden bg-gradient-to-b from-gray-50 to-white">
      {/* Radar wave pattern background */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden opacity-[0.15]">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[300px] h-[300px] rounded-full border-[3px] border-[#8B1A1A] animate-ping" style={{animationDuration: '4s'}} />
        </div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[500px] h-[500px] rounded-full border-[3px] border-[#8B1A1A] animate-ping" style={{animationDuration: '5s', animationDelay: '0.5s'}} />
        </div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[700px] h-[700px] rounded-full border-[3px] border-[#8B1A1A] animate-ping" style={{animationDuration: '6s', animationDelay: '1s'}} />
        </div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[900px] h-[900px] rounded-full border-[3px] border-[#8B1A1A] animate-ping" style={{animationDuration: '7s', animationDelay: '1.5s'}} />
        </div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="w-[1100px] h-[1100px] rounded-full border-[3px] border-[#8B1A1A] animate-ping" style={{animationDuration: '8s', animationDelay: '2s'}} />
        </div>
      </div>
      {/* Animated floating caricatures - FULLY VISIBLE */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {CARICATURES.map((name, i) => (
          <div
            key={name}
            className="absolute rounded-full overflow-hidden shadow-lg border-2 border-white/50"
            style={{
              width: `${POSITIONS[i].size}px`,
              height: `${POSITIONS[i].size}px`,
              top: `${POSITIONS[i].top}%`,
              left: `${POSITIONS[i].left}%`,
              animation: mounted
                ? `float-${i % 4} ${8 + (i % 5) * 2}s ease-in-out infinite ${i * 0.5}s`
                : "none",
              opacity: mounted ? 1 : 0,
              transition: `opacity 1s ease ${i * 0.15}s`,
            }}
          >
            <img
              src={`/images/caricaturas_webp/${name}.webp`}
              alt=""
              className="w-full h-full object-cover"
              loading="lazy"
            />
          </div>
        ))}
      </div>

      {/* CSS Animations */}
      <style jsx>{`
        @keyframes float-0 {
          0%, 100% { transform: translateY(0px) rotate(0deg); }
          25% { transform: translateY(-15px) rotate(3deg); }
          50% { transform: translateY(-25px) rotate(-2deg); }
          75% { transform: translateY(-10px) rotate(1deg); }
        }
        @keyframes float-1 {
          0%, 100% { transform: translateY(0px) rotate(0deg); }
          33% { transform: translateY(-20px) rotate(-3deg); }
          66% { transform: translateY(-8px) rotate(4deg); }
        }
        @keyframes float-2 {
          0%, 100% { transform: translateY(0px) rotate(0deg); }
          20% { transform: translateY(-12px) rotate(2deg); }
          50% { transform: translateY(-22px) rotate(-3deg); }
          80% { transform: translateY(-6px) rotate(1deg); }
        }
        @keyframes float-3 {
          0%, 100% { transform: translateY(0px) rotate(0deg); }
          40% { transform: translateY(-18px) rotate(-2deg); }
          70% { transform: translateY(-30px) rotate(3deg); }
        }
      `}</style>

      {/* Content */}
      <div className="relative z-10 text-center max-w-2xl mx-auto">
        <p className="text-xs tracking-[0.3em] text-gray-400 uppercase mb-2">
          Edici&oacute;n Especial
        </p>

        <h1 className="text-5xl md:text-7xl font-black text-gray-900 mb-3 tracking-tight font-serif drop-shadow-sm">
          RADAR DEL FLORO
        </h1>

        <div className="w-24 h-[3px] bg-[#8B1A1A] mx-auto mb-4 rounded-full" />

        <p className="text-base text-gray-500 mb-2">
          Gu&iacute;a sat&iacute;rica para detectar el floro pol&iacute;tico
        </p>

        <p className="text-lg text-[#8B1A1A] font-bold mb-10">
          Elecciones Per&uacute; 2026
        </p>

        {/* CTA */}
        <div id="descargar" className="mb-3">
          <a
            href="/downloads/radar-del-floro.apk"
            className="inline-flex items-center gap-3 bg-[#8B1A1A]/85 backdrop-blur-xl text-white font-bold py-4 px-10 rounded-2xl text-lg hover:bg-[#6B1414]/95 transition-all shadow-xl shadow-[#8B1A1A]/20 border border-white/15"
          >
            <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
              <path d="M17.523 2.235a.5.5 0 0 0-.866-.015l-1.69 2.86a8.5 8.5 0 0 0-5.934 0L7.343 2.22a.5.5 0 0 0-.866.015.5.5 0 0 0 .046.488l1.618 2.74A8.5 8.5 0 0 0 3.5 12.5h17a8.5 8.5 0 0 0-4.641-7.037l1.618-2.74a.5.5 0 0 0 .046-.488zM8.5 9.5a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2zM3.5 13.5v6A2.5 2.5 0 0 0 6 22h12a2.5 2.5 0 0 0 2.5-2.5v-6h-17z" />
            </svg>
            Descargar APK Android
          </a>
        </div>
        <p className="text-gray-400 text-xs mb-2">
          Versi&oacute;n 1.0 &middot; Android 6.0+ &middot; Gratis
        </p>
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg px-4 py-2 mb-10 max-w-md mx-auto">
          <p className="text-yellow-800 text-xs leading-relaxed">
            ⚠️ <strong>Beta:</strong> Algunas caricaturas están en proceso. Faltan datos de algunos candidatos menores. Actualizaciones próximamente.
          </p>
        </div>

        {/* Stats */}
        <div className="flex gap-8 justify-center flex-wrap">
          <Stat number="2,562" label="candidatos" />
          <Stat number="436" label="con alertas" />
          <Stat number="78" label="fuentes verificadas" />
        </div>
      </div>

      {/* Scroll hint */}
      <div className="absolute bottom-8 text-gray-400 animate-bounce">
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
      <div className="text-3xl font-black text-gray-900">{number}</div>
      <div className="text-xs text-gray-500 uppercase tracking-wider mt-1">{label}</div>
    </div>
  );
}
