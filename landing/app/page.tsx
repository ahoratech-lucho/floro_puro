import Hero from "./components/Hero";
import HowItWorks from "./components/HowItWorks";
import CardPreview from "./components/CardPreview";
import DownloadSection from "./components/DownloadSection";
import About from "./components/About";

export default function Home() {
  return (
    <main className="min-h-screen">
      <Hero />
      <HowItWorks />
      <CardPreview />
      <DownloadSection />
      <About />
    </main>
  );
}
