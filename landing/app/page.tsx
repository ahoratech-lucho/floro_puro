import Hero from "./components/Hero";
import HowItWorks from "./components/HowItWorks";
import CardPreview from "./components/CardPreview";
import DownloadSection from "./components/DownloadSection";
import About from "./components/About";
import Header from "./components/Header";
import Footer from "./components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen">
      <Header />
      <Hero />
      <HowItWorks />
      <CardPreview />
      <DownloadSection />
      <About />
      <Footer />
    </main>
  );
}
