import { useState, useEffect } from "react";
import LocomotiveScroll from "locomotive-scroll";

import Navbar from "../components/layout/Navbar";
import Footer from "../components/layout/Footer";
import HeroSection from "../components/hero/HeroSection";
import FeatureCards from "../components/cards/FeatureCards";
import LoginModal from "../components/auth/LoginModal";
import ThreeBackground from "../components/ThreeBackground";
import ParallaxBackground from "../components/ParallaxBackground";
import UsiaBenurSection from "../components/landing/UsiaBenurSection";

import "../styles/landing.css";

export default function LandingPage() {
  const [showLogin, setShowLogin] = useState(false);

  useEffect(() => {
    let locomotiveScroll;
    // Dynamic import to avoid Vite CommonJS conflict
    import("locomotive-scroll").then((mod) => {
      const LS = mod.default || mod;
      locomotiveScroll = new LS({
        lenisOptions: {
          smoothTouch: false,
        },
      });
    });

    return () => {
      locomotiveScroll?.destroy();
    };
  }, []);

  return (
    <div className="landingRoot" data-scroll-container>
      {/* Background Components */}
      <ThreeBackground />
      <ParallaxBackground />

      <Navbar onLogin={() => setShowLogin(true)} />
      
      <main>
        <HeroSection onCtaClick={() => setShowLogin(true)} />
        <FeatureCards />
        <UsiaBenurSection />
      </main>

      <Footer />

      {showLogin && <LoginModal onClose={() => setShowLogin(false)} />}
    </div>
  );
}
