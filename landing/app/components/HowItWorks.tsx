export default function HowItWorks() {
  return (
    <section id="como-funciona" className="relative py-20 px-6 overflow-hidden bg-white scroll-mt-20">
      <div className="relative z-10 max-w-5xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-900 text-center mb-3">
          &iquest;C&oacute;mo funciona?
        </h2>
        <p className="text-gray-500 text-center mb-12">
          Filtra, explora y compara candidatos con datos reales
        </p>

        <div className="grid md:grid-cols-2 gap-6 mb-12">
          <Feature
            icon={<svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 3c2.755 0 5.455.232 8.083.678.533.09.917.556.917 1.096v1.044a2.25 2.25 0 01-.659 1.591l-5.432 5.432a2.25 2.25 0 00-.659 1.591v2.927a2.25 2.25 0 01-1.244 2.013L9.75 21v-6.568a2.25 2.25 0 00-.659-1.591L3.659 7.409A2.25 2.25 0 013 5.818V4.774c0-.54.384-1.006.917-1.096A48.32 48.32 0 0112 3z" /></svg>}
            color="text-[#8B1A1A]"
            title="Filtra por cargo y región"
            description="Busca candidatos a Presidente, Senador, Diputado o Parlamento Andino. Filtra por tu región."
          />
          <Feature
            icon={<svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" /></svg>}
            color="text-[#8B1A1A]"
            title="Desliza como Tinder"
            description="Cada carta muestra un candidato con su caricatura. Desliza según tu instinto: ¿puro floro o pasa raspando?"
          />
          <Feature
            icon={<svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" /></svg>}
            color="text-[#8B1A1A]"
            title="Descubre la verdad"
            description="Después de cada swipe se revelan los datos reales: controversias, antecedentes y fuentes verificadas."
          />
          <Feature
            icon={<svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z" /></svg>}
            color="text-[#8B1A1A]"
            title="Índice de Floro en 6 ejes"
            description="Puntaje basado en: incoherencia, promesas inviables, opacidad, populismo, victimismo y reciclaje político."
          />
        </div>

        <div className="grid md:grid-cols-3 gap-6 mb-16">
          <MiniFeature
            icon={<svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M16.5 18.75h-9m9 0a3 3 0 013 3h-15a3 3 0 013-3m9 0v-3.375c0-.621-.503-1.125-1.125-1.125h-.871M7.5 18.75v-3.375c0-.621.504-1.125 1.125-1.125h.872m5.007 0H9.497m5.007 0a7.454 7.454 0 01-.982-3.172M9.497 14.25a7.454 7.454 0 00.981-3.172M5.25 4.236c-.982.143-1.954.317-2.916.52A6.003 6.003 0 007.73 9.728M5.25 4.236V4.5c0 2.108.966 3.99 2.48 5.228M5.25 4.236V2.721C7.456 2.41 9.71 2.25 12 2.25c2.291 0 4.545.16 6.75.47v1.516M18.75 4.236c.982.143 1.954.317 2.916.52A6.003 6.003 0 0016.27 9.728M18.75 4.236V4.5c0 2.108-.966 3.99-2.48 5.228m0 0a6.003 6.003 0 01-5.54 0" /></svg>}
            color="text-[#8B1A1A]"
            title="Ranking general"
            description="Compara quién tiene más floro entre todos los candidatos."
          />
          <MiniFeature
            icon={<svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" /></svg>}
            color="text-[#8B1A1A]"
            title="Comparador"
            description="Pon dos candidatos frente a frente y compara sus perfiles."
          />
          <MiniFeature
            icon={<svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z" /></svg>}
            color="text-[#8B1A1A]"
            title="Logros y rachas"
            description="Gana insignias por acertar y mantener rachas de aciertos."
          />
        </div>

        <h3 className="text-xl font-bold text-gray-900 text-center mb-6">
          Direcci&oacute;n de swipe
        </h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <SwipeOption direction="← Izquierda" label="PURO FLORO" description="Definitivamente turbio" color="red" icon="✕" />
          <SwipeOption direction="↓ Abajo" label="BANDERA ROJA" description="Alerta de corrupción" color="orange" icon="⚑" />
          <SwipeOption direction="↑ Arriba" label="SOSPECHOSO" description="Algo no cuadra" color="amber" icon="?" />
          <SwipeOption direction="→ Derecha" label="PASA RASPANDO" description="Parece limpio" color="green" icon="✓" />
        </div>
      </div>
    </section>
  );
}

function Feature({ icon, color, title, description }: { icon: React.ReactNode; color: string; title: string; description: string }) {
  return (
    <div className="flex gap-4 p-6 rounded-2xl bg-gray-50 border border-gray-100 hover:shadow-md transition-shadow">
      <div className={`${color} flex-shrink-0 mt-1`}>{icon}</div>
      <div>
        <h3 className="text-lg font-bold text-gray-900 mb-1">{title}</h3>
        <p className="text-gray-500 text-sm leading-relaxed">{description}</p>
      </div>
    </div>
  );
}

function MiniFeature({ icon, color, title, description }: { icon: React.ReactNode; color: string; title: string; description: string }) {
  return (
    <div className="text-center p-5 rounded-2xl bg-gray-50 border border-gray-100">
      <div className={`${color} flex justify-center mb-3`}>{icon}</div>
      <h3 className="text-base font-bold text-gray-900 mb-1">{title}</h3>
      <p className="text-gray-500 text-xs leading-relaxed">{description}</p>
    </div>
  );
}

function SwipeOption({ direction, label, description, color, icon }: { direction: string; label: string; description: string; color: string; icon: string }) {
  const colorClasses: Record<string, string> = {
    red: "border-red-200 bg-red-50 text-red-700",
    orange: "border-orange-200 bg-orange-50 text-orange-700",
    amber: "border-amber-200 bg-amber-50 text-amber-700",
    green: "border-green-200 bg-green-50 text-green-700",
  };
  return (
    <div className={`border-2 rounded-2xl p-5 text-center transition-transform hover:scale-105 ${colorClasses[color]}`}>
      <div className="text-2xl mb-2 font-bold">{icon}</div>
      <div className="text-sm font-medium opacity-60 mb-1">{direction}</div>
      <div className="text-base font-black mb-1">{label}</div>
      <div className="text-xs opacity-70">{description}</div>
    </div>
  );
}
