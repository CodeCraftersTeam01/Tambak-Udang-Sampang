import { FaFish, FaBars } from "react-icons/fa";
import { useState } from "react";

export default function Navbar({ onLogin }) {
  const [open, setOpen] = useState(false);

  return (
    <header className="navbar">
      <div className="logo">
        <div className="logoIcon">
          <FaFish />
        </div>
        <strong>AquiTech</strong>
      </div>

      <button className="menuToggle" onClick={() => setOpen(!open)}>
        <FaBars />
      </button>

      <nav className={open ? "navMenu open" : "navMenu"}>
        <a href="#home">Home</a>
        <a href="#features">Features</a>
        <a href="#technology">Technology</a>
        <a href="#contact">Contact</a>
      </nav>

      <button className="btn" onClick={onLogin}>
        Login
      </button>
    </header>
  );
}