"use client";

import { useState, useEffect, useRef } from "react";

interface PreviewCard {
  nombre: string;
  partido: string;
  cargo: string;
  nivel: string;
  indiceFloro: number;
  fraseNarrador: string;
  id: string;
}

const NIVEL_COLORS: Record<string, string> = {
  "Alerta maxima": "bg-red-600",
  "Bandera roja": "bg-orange-600",
  "Mucho floro": "bg-amber-500",
  Dudoso: "bg-blue-500",
  "Pasa raspando": "bg-green-500",
};

const AVAILABLE_IDS = [
  "keiko_sofia_fujimori_higuchi",
  "rafael_bernardo_lopez_aliaga_cazorla",
  "george_patrick_forsyth_sommer",
  "cesar_acuna_peralta",
  "jose_leon_luna_galvez",
  "vladimir_roy_cerron_rojas",
  "roberto_enrique_chiabra_leon",
  "ricardo_pablo_belmont_cassinelli",
];

export default function CardPreview() {
  const [cards, setCards] = useState<PreviewCard[]>([]);
  const scrollRef = useRef<HTMLDivElement>(null);
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(true);

  useEffect(() => {
    fetch("/game_data.json")
      .then((r) => r.json())
      .then((data) => {
        const interesting = data.cards
          .filter(
            (c: any) =>
              AVAILABLE_IDS.includes(c.id) &&
              c.indiceFloro > 30 &&
              c.fraseNarrador
          )
          .sort((a: any, b: any) => b.indiceFloro - a.indiceFloro)
          .slice(0, 8);
        setCards(interesting);
      })
      .catch(() => {});
  }, []);

  const checkScroll = () => {
    if (!scrollRef.current) return;
    const el = scrollRef.current;
    setCanScrollLeft(el.scrollLeft > 10);
    setCanScrollRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 10);
  };

  const scroll = (direction: "left" | "right") => {
    if (!scrollRef.current) return;
    const scrollAmount = 300;
    scrollRef.current.scrollBy({
      left: direction === "left" ? -scrollAmount : scrollAmount,
      behavior: "smooth",
    });
  };

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.addEventListener("scroll", checkScroll);
    checkScroll();
    return () => el.removeEventListener("scroll", checkScroll);
  }, [cards]);

  // Auto-scroll carousel
  useEffect(() => {
    if (cards.length === 0) return;
    const interval = setInterval(() => {
      if (!scrollRef.current) return;
      const el = scrollRef.current;
      if (el.scrollLeft >= el.scrollWidth - el.clientWidth - 10) {
        el.scrollTo({ left: 0, behavior: "smooth" });
      } else {
        el.scrollBy({ left: 300, behavior: "smooth" });
      }
    }, 4000);
    return () => clearInterval(interval);
  }, [cards]);

  if (cards.length === 0) return null;

  return (
    <section id="candidatos" className="relative py-20 px-6 overflow-hidden bg-gray-50 scroll-mt-20">
      <div className="relative z-10 max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold text-gray-900 text-center mb-3">
          Conoce a los candidatos
        </h2>
        <p className="text-gray-500 text-center mb-10">
          2,600 cartas basadas en datos oficiales del JNE
        </p>

        {/* Carousel */}
        <div className="relative">
          {/* Left arrow */}
          {canScrollLeft && (
            <button
              onClick={() => scroll("left")}
              className="absolute left-0 top-1/2 -translate-y-1/2 z-20 w-12 h-12 bg-white shadow-xl rounded-full flex items-center justify-center hover:bg-gray-50 transition-colors border border-gray-200"
            >
              <svg className="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
          )}

          {/* Right arrow */}
          {canScrollRight && (
            <button
              onClick={() => scroll("right")}
              className="absolute right-0 top-1/2 -translate-y-1/2 z-20 w-12 h-12 bg-white shadow-xl rounded-full flex items-center justify-center hover:bg-gray-50 transition-colors border border-gray-200"
            >
              <svg className="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
              </svg>
            </button>
          )}

          {/* Fade edges */}
          <div className="absolute left-0 top-0 bottom-0 w-16 bg-gradient-to-r from-gray-50 to-transparent z-10 pointer-events-none" />
          <div className="absolute right-0 top-0 bottom-0 w-16 bg-gradient-to-l from-gray-50 to-transparent z-10 pointer-events-none" />

          {/* Scrollable cards */}
          <div
            ref={scrollRef}
            className="flex gap-6 overflow-x-auto scrollbar-hide px-8 pb-4 snap-x snap-mandatory"
            style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
          >
            {cards.map((card) => (
              <div
                key={card.id}
                className="flex-shrink-0 w-72 bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-300 border border-gray-100 snap-center hover:-translate-y-1"
              >
                {/* Caricature */}
                <div className="relative h-72 bg-gradient-to-b from-gray-800 to-gray-900">
                  <img
                    src={`/images/caricaturas_webp/${card.id}.webp`}
                    alt={card.nombre}
                    className="w-full h-full object-cover"
                    loading="lazy"
                  />
                  <div
                    className={`absolute top-3 right-3 ${
                      NIVEL_COLORS[card.nivel] || "bg-gray-600"
                    } text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg`}
                  >
                    {card.nivel}
                  </div>
                  <div className="absolute top-3 left-3 bg-black/70 backdrop-blur-sm text-white text-[10px] font-medium px-2.5 py-1.5 rounded-lg uppercase tracking-wide">
                    {card.cargo}
                  </div>
                  <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-white to-transparent" />
                </div>

                {/* Info */}
                <div className="p-4">
                  <h3 className="text-gray-900 font-bold text-base mb-1 line-clamp-1">
                    {card.nombre}
                  </h3>
                  <p className="text-gray-400 text-xs mb-2 line-clamp-1">{card.partido}</p>
                  <p className="text-red-500 text-xs italic leading-relaxed line-clamp-2">
                    &ldquo;{card.fraseNarrador}&rdquo;
                  </p>

                  <div className="mt-3 flex items-center gap-2">
                    <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-green-500 via-amber-500 to-red-500 rounded-full"
                        style={{ width: `${card.indiceFloro}%` }}
                      />
                    </div>
                    <span className="text-gray-900 text-sm font-black">
                      {card.indiceFloro}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
