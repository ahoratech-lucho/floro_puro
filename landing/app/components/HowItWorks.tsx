export default function HowItWorks() {
  return (
    <section className="py-20 px-6">
      <div className="max-w-4xl mx-auto">
        <h2 className="text-3xl font-bold text-white text-center mb-12">
          ¿Cómo funciona?
        </h2>

        <div className="grid md:grid-cols-3 gap-8">
          <Step
            number="1"
            emoji="👆"
            title="Desliza"
            description="Cada carta muestra un candidato con su caricatura y una frase del narrador. Desliza según tu instinto."
          />
          <Step
            number="2"
            emoji="🔍"
            title="Descubre"
            description="Después de cada swipe, se revelan los datos reales: controversias, antecedentes y fuentes verificadas."
          />
          <Step
            number="3"
            emoji="📊"
            title="Puntúa"
            description="Tu radar de floro se mide con el Índice de Floro: 6 ejes de análisis político basados en datos del JNE."
          />
        </div>

        {/* Swipe directions */}
        <div className="mt-16 grid md:grid-cols-3 gap-6">
          <SwipeOption
            direction="← Izquierda"
            label="PURO FLORO"
            description="Definitivamente turbio"
            color="red"
          />
          <SwipeOption
            direction="↑ Arriba"
            label="SOSPECHOSO"
            description="Algo no cuadra"
            color="amber"
          />
          <SwipeOption
            direction="→ Derecha"
            label="PASA RASPANDO"
            description="Parece limpio... por ahora"
            color="green"
          />
        </div>
      </div>
    </section>
  );
}

function Step({
  number,
  emoji,
  title,
  description,
}: {
  number: string;
  emoji: string;
  title: string;
  description: string;
}) {
  return (
    <div className="text-center">
      <div className="text-5xl mb-4">{emoji}</div>
      <div className="inline-block bg-red-600/20 text-red-400 text-xs font-bold px-3 py-1 rounded-full mb-3">
        PASO {number}
      </div>
      <h3 className="text-xl font-bold text-white mb-2">{title}</h3>
      <p className="text-gray-400 text-sm">{description}</p>
    </div>
  );
}

function SwipeOption({
  direction,
  label,
  description,
  color,
}: {
  direction: string;
  label: string;
  description: string;
  color: string;
}) {
  const colorClasses: Record<string, string> = {
    red: "border-red-500/30 bg-red-500/5 text-red-400",
    amber: "border-amber-500/30 bg-amber-500/5 text-amber-400",
    green: "border-green-500/30 bg-green-500/5 text-green-400",
  };

  return (
    <div
      className={`border rounded-xl p-6 text-center ${colorClasses[color]}`}
    >
      <div className="text-sm font-medium opacity-60 mb-1">{direction}</div>
      <div className="text-lg font-bold mb-1">{label}</div>
      <div className="text-xs opacity-60">{description}</div>
    </div>
  );
}
