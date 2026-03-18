export default function HowItWorks() {
  return (
    <section className="relative py-20 px-6 overflow-hidden">
      {/* B&W caricature accents */}
      <div className="absolute top-10 left-4 w-24 h-24 rounded-full overflow-hidden opacity-[0.03] grayscale pointer-events-none">
        <img src="/images/caricaturas/maria_soledad_perez_tello_de_rodriguez.webp" alt="" className="w-full h-full object-cover" loading="lazy" />
      </div>
      <div className="absolute bottom-16 right-6 w-20 h-20 rounded-full overflow-hidden opacity-[0.03] grayscale pointer-events-none rotate-12">
        <img src="/images/caricaturas/napoleon_becerra_garcia.webp" alt="" className="w-full h-full object-cover" loading="lazy" />
      </div>

      <div className="relative z-10 max-w-4xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-900 text-center mb-12">
          &iquest;C&oacute;mo funciona?
        </h2>

        <div className="grid md:grid-cols-3 gap-8">
          <Step number="1" emoji="👆" title="Desliza" description="Cada carta muestra un candidato con su caricatura y una frase del narrador. Desliza seg&uacute;n tu instinto." />
          <Step number="2" emoji="🔍" title="Descubre" description="Despu&eacute;s de cada swipe, se revelan los datos reales: controversias, antecedentes y fuentes verificadas." />
          <Step number="3" emoji="📊" title="Punt&uacute;a" description="Tu radar de floro se mide con el &Iacute;ndice de Floro: 6 ejes de an&aacute;lisis pol&iacute;tico basados en datos del JNE." />
        </div>

        {/* Swipe directions */}
        <div className="mt-16 grid md:grid-cols-3 gap-6">
          <SwipeOption direction="&larr; Izquierda" label="PURO FLORO" description="Definitivamente turbio" color="red" />
          <SwipeOption direction="&uarr; Arriba" label="SOSPECHOSO" description="Algo no cuadra" color="amber" />
          <SwipeOption direction="&rarr; Derecha" label="PASA RASPANDO" description="Parece limpio... por ahora" color="green" />
        </div>
      </div>
    </section>
  );
}

function Step({ number, emoji, title, description }: { number: string; emoji: string; title: string; description: string }) {
  return (
    <div className="text-center">
      <div className="text-5xl mb-4">{emoji}</div>
      <div className="inline-block bg-red-600/10 text-red-600 text-xs font-bold px-3 py-1 rounded-full mb-3">
        PASO {number}
      </div>
      <h3 className="text-xl font-bold text-gray-900 mb-2">{title}</h3>
      <p className="text-gray-500 text-sm">{description}</p>
    </div>
  );
}

function SwipeOption({ direction, label, description, color }: { direction: string; label: string; description: string; color: string }) {
  const colorClasses: Record<string, string> = {
    red: "border-red-300 bg-red-50 text-red-600",
    amber: "border-amber-300 bg-amber-50 text-amber-600",
    green: "border-green-300 bg-green-50 text-green-600",
  };

  return (
    <div className={`border rounded-xl p-6 text-center ${colorClasses[color]}`}>
      <div className="text-sm font-medium opacity-60 mb-1">{direction}</div>
      <div className="text-lg font-bold mb-1">{label}</div>
      <div className="text-xs opacity-60">{description}</div>
    </div>
  );
}
