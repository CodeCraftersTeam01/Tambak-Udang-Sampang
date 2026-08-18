import { useRef } from "react";
import { FaEnvelope, FaGlobe, FaMapMarkerAlt } from "react-icons/fa";

export default function Footer() {
  const sectionRef = useRef(null);

  return (
    <footer id="contact" className="footer" ref={sectionRef}>
      <div className="footerGrid">
        <div className="footerBrand">
          <a href="/" className="logo" style={{ marginBottom: 0, textDecoration: "none" }}>
            <img
              src="/favicon.png"
              alt="Aquaculture Logo"
              style={{ width: "36px", height: "36px", borderRadius: "10px", objectFit: "cover" }}
            />
            <span className="logoText">
              Aqua<span className="logoAccent">culture</span>
            </span>
          </a>
          <p>
            Smart Aquaculture Monitoring System berbasis IoT dan dashboard web
            untuk mendukung efisiensi budidaya tambak udang di Indonesia.
          </p>
        </div>

        <div>
          <h3>Navigation</h3>
          <ul className="footerLinks">
            <li><a href="#home">Home</a></li>
            <li><a href="#features">Fitur</a></li>
            <li><a href="#stats">Data Live</a></li>
            <li><a href="#benur">Status Benur</a></li>
          </ul>
        </div>

        <div>
          <h3>Contact</h3>
          <ul className="footerLinks">
            <li><span><FaEnvelope /> info@aquaculture.m-tech.fun</span></li>
            <li><span><FaGlobe /> aquaculture.m-tech.fun</span></li>
            <li><span><FaMapMarkerAlt /> Surabaya, Indonesia</span></li>
          </ul>
        </div>
      </div>

      <div className="footerBottom">
        <span>&copy; {new Date().getFullYear()} Aquaculture. All rights reserved.</span>
        <span>Built with IoT & AI</span>
      </div>
    </footer>
  );
}
