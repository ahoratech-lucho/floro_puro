"use client";

import { useState, useEffect } from "react";

interface PreviewCard {
  nombre: string;
  partido: string;
  cargo: string;
  nivel: string;
  indiceFloro: number;
  fraseNarrador: string;
  caricatura: string;
}

const NIVEL_COLORS: Record<string, string> = {
  "Alerta maxima": "bg-red-600",
  "Bandera roja": "bg-orange-600",
  "Mucho floro": "bg-amber-500",
  "Dudoso": "bg-blue-500",
  "Pasa raspando": "bg-green-500",
};

export default function CardPreview() {
  const [cards, setCards] = useState<PreviewCard[]>([]);
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    fetch("/game_data.json")
      .then((r) => r.json())
      .then((data) => {
        const interesting = data.cards
          .filter((c: any) => c.indiceFloro > 30 && c.fraseNarrador)
          .sort((a: any, b: any) => b.indiceFloro - a.indiceFloro)
          .slice(0, 8);
        setCards(interesting);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    if (cards.length === 0) return;
    const interval = setInterval(() => {
      setCurrent((prev) => (prev + 1) % cards.length);
    }, 4000);
    return () => clearInterval(interval);
  }, [cards]);

  if (cards.length === 0) return null;

  const card = cards[current];
  const slug = card.caricatura?.replace("caricatures/", "").replace(".png", "");

  return (
    <section className="py-20 px-6">
      <div className="max-w-4xl mx-auto">
        <h2 className="text-3xl font-bold text-white text-center mb-4">
          Conoce a los candidatos
        </h2>
        <p className="text-gray-400 text-center mb-12">
          2,600 cartas basadas en datos oficiales del JNE
        </p>

        <div className="flex justify-center">
          <div className="w-80 bg-gray-900 rounded-2xl overflow-hidden border border-gray-800 shadow-2xl transition-all duration-500">
            {/* Caricature */}
            <div className="relative h-80 bg-gray-800">
              {slug && (
                <img
                  src={`/images/caricatures/${slug}.webp`}
                  alt={card.nombre}
                  className="w-full h-full object-cover transition-opacity duration-500"
                  loading="lazy"
                />
              )}
              {/* Nivel badge */}
              <div
                className={`absolute top-3 right-3 ${
                  NIVEL_COLORS[card.nivel] || "bg-gray-600"
                } text-white text-xs font-bold px-3 py-1 rounded-full`}
              >
                {card.nivel}
              </div>
              {/* Cargo badge */}
              <div className="absolute top-3 left-3 bg-black/60 text-gray-300 text-[10px] font-medium px-2 py-1 rounded-lg">
                {card.cargo}
              </div>
              {/* Gradient */}
              <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-gray-900 to-transparent" />
            </div>

            {/* Info */}
            <div className="p-5">
              <h3 className="text-white font-bold text-lg mb-1">
                {card.nombre}
              </h3>
              <p className="text-gray-400 text-sm mb-3">{card.partido}</p>
              <p className="text-amber-400 text-sm italic">
                &ldquo;{card.fraseNarrador}&rdquo;
              </p>

              {/* Floro index */}
              <div className="mt-4 flex items-center gap-2">
                <div className="flex-1 h-2 bg-gray-800 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-green-500 via-amber-500 to-red-500 rounded-full transition-all duration-1000"
                    style={{ width: `${card.indiceFloro}%` }}
                  />
                </div>
                <span className="text-white text-sm font-bold">
                  {card.indiceFloro}
                </span>
              </div>
              <p className="text-gray-600 text-xs mt-1">Índice de Floro</p>
            </div>
          </div>
        </div>

        {/* Dots */}
        <div className="flex justify-center gap-2 mt-6">
          {cards.map((_, i) => (
            <button
              key={i}
              onClick={() => setCurrent(i)}
              className={`w-2 h-2 rounded-full transition-all ${
                i === current ? "bg-red-500 w-6" : "bg-gray-700"
              }`}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
