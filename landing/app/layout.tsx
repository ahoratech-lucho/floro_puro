import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Radar del Floro - Elecciones Peru 2026",
  description: "Juego satirico para detectar el floro politico. Conoce a tus candidatos antes de votar el 12 de abril.",
  openGraph: {
    title: "Radar del Floro",
    description: "Detecta el floro politico de los candidatos Peru 2026",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body className="bg-[#FAF6F1] text-gray-900 antialiased">
        {children}
      </body>
    </html>
  );
}
