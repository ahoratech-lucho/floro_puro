export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-400 py-12 px-6">
      <div className="max-w-6xl mx-auto">
        <div className="grid md:grid-cols-3 gap-8 mb-8">
          <div>
            <h3 className="text-white font-black text-lg mb-3">RADAR DEL FLORO</h3>
            <p className="text-sm leading-relaxed">
              Guía satírica e informativa sobre los candidatos a las Elecciones Perú 2026.
              No somos medio de comunicación.
            </p>
          </div>
          <div>
            <h4 className="text-white font-bold text-sm mb-3 uppercase tracking-wider">Enlaces</h4>
            <ul className="space-y-2 text-sm">
              <li><a href="/privacy.html" className="hover:text-white transition-colors">Política de Privacidad</a></li>
              <li><a href="mailto:bartolocruzazul@gmail.com" className="hover:text-white transition-colors">Contacto</a></li>
              <li><a href="#como-funciona" className="hover:text-white transition-colors">Cómo funciona</a></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white font-bold text-sm mb-3 uppercase tracking-wider">Fuentes</h4>
            <ul className="space-y-2 text-sm">
              <li>JNE - Voto Informado</li>
              <li>Fuentes periodísticas verificadas</li>
              <li>78 fuentes públicas consultadas</li>
            </ul>
          </div>
        </div>
        <div className="border-t border-gray-800 pt-6 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-xs">© 2026 LA.N.G.R.E · Proyecto satírico e informativo</p>
          <p className="text-xs">Hecho con ❤️ en Perú</p>
        </div>
      </div>
    </footer>
  );
}
