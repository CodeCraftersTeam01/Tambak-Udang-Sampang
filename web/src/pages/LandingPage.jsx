import { useState } from "react";

import Navbar from "../components/layout/Navbar";
import Topbar from "../components/layout/Topbar";
import Footer from "../components/layout/Footer";

import HeroSection from "../components/hero/HeroSection";
import FeatureCards from "../components/cards/FeatureCards";

import LoginModal from "../components/auth/LoginModal";

import "../styles/landing.css";

export default function LandingPage() {
  const [showLogin, setShowLogin] = useState(false);

  return (
    <>
      <Topbar />

      <Navbar onLogin={() => setShowLogin(true)} />

      <HeroSection />

      <FeatureCards />

      <Footer />

      {showLogin && (
        <LoginModal onClose={() => setShowLogin(false)} />
      )}
    </>
  );
}
