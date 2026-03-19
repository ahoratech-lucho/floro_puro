"use client";

import { useEffect, useState } from "react";

export default function Header() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-white/95 backdrop-blur-md shadow-md py-2"
          : "bg-transparent py-4"
      }`}
    >
      <div className="max-w-6xl mx-auto px-6 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className={`font-black text-lg tracking-wider transition-colors ${scrolled ? "text-gray-900" : "text-gray-900"}`}>
            RADAR DEL FLORO
          </span>
        </div>
        <nav className="hidden md:flex items-center gap-6 text-sm">
          <a href="#como-funciona" className="text-gray-600 hover:text-red-600 transition-colors">Cómo funciona</a>
          <a href="#candidatos" className="text-gray-600 hover:text-red-600 transition-colors">Candidatos</a>
          <a href="#descargar" className="text-gray-600 hover:text-red-600 transition-colors">Descargar</a>
        </nav>
        <a
          href="#descargar"
          className={`text-sm font-bold px-4 py-2 rounded-lg transition-all backdrop-blur-xl border border-white/15 ${
            scrolled
              ? "bg-[#8B1A1A]/85 text-white hover:bg-[#6B1414]/95"
              : "bg-[#8B1A1A]/70 text-white hover:bg-[#6B1414]/85"
          }`}
        >
          Descargar App
        </a>
      </div>
    </header>
  );
}
