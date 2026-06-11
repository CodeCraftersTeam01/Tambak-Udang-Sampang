import { useRef } from "react";
import { FaFish, FaEnvelope, FaGlobe, FaMapMarkerAlt } from "react-icons/fa";

export default function Footer() {
  const sectionRef = useRef(null);

  return (
    <footer id="contact" className="footer" ref={sectionRef}>
      <div className="footerGrid">
        <div className="footerBrand">
          <div className="logo" style={{ marginBottom: 0 }}>
            <div className="logoIcon">
              <FaFish />
            </div>
            <span className="logoText">
              Aqui<span className="logoAccent">Tech</span>
            </span>
          </div>
          <p>
            Smart Aquaculture Monitoring System berbasis IoT dan dashboard web
            untuk mendukung efisiensi budidaya tambak udang di Indonesia.
          </p>
        </div>

        <div>
          <h3>Navigation</h3>
          <ul className="footerLinks">
            <li><a href="#home">Home</a></li>
            <li><a href="#features">Features</a></li>
            <li><a href="#technology">Technology</a></li>
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
        <span>&copy; {new Date().getFullYear()} AquiTech. All rights reserved.</span>
        <span>Built with IoT & AI</span>
      </div>
    </footer>
  );
}
