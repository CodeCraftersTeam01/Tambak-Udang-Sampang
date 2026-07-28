import { FaBars, FaTimes } from "react-icons/fa";
import { useState, useEffect, useRef } from "react";
import gsap from "gsap";

export default function Navbar({ onLogin }) {
  const [open, setOpen] = useState(false);
  const [hidden, setHidden] = useState(false);
  const lastScroll = useRef(0);
  const navRef = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      const cur = window.scrollY;
      setHidden(cur > lastScroll.current && cur > 80);
      lastScroll.current = cur;
    };
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    gsap.fromTo(navRef.current, { y: -80, opacity: 0 }, { y: 0, opacity: 1, duration: 0.8, ease: "power3.out" });
  }, []);

  return (
    <header className={`navbar${hidden ? " hidden" : ""}`} ref={navRef}>
      <a href="/" className="logo">
        <img src="/favicon.png" alt="AquiTech Logo" style={{ width: "36px", height: "36px", borderRadius: "10px", objectFit: "cover" }} />
        <span className="logoText">
          Aqui<span className="logoAccent">Tech</span>
        </span>
      </a>

      <button className="menuToggle" onClick={() => setOpen(!open)}>
        {open ? <FaTimes /> : <FaBars />}
      </button>

      <nav className={`navLinks${open ? " open" : ""}`}>
        <a href="#home" onClick={() => setOpen(false)}>Home</a>
        <a href="#features" onClick={() => setOpen(false)}>Fitur</a>
        <a href="#stats" onClick={() => setOpen(false)}>Data Live</a>
        <a href="#benur" onClick={() => setOpen(false)}>Status Benur</a>
        <a href="#contact" onClick={() => setOpen(false)}>Kontak</a>
        <button className="navBtn navSignInMobile" style={{ width: "100%", marginTop: "4px" }} onClick={() => { setOpen(false); onLogin(); }}>
          Sign In
        </button>
      </nav>

      <button className="navBtn" onClick={onLogin}>
        Sign In
      </button>
    </header>
  );
}
