import { FaEnvelope, FaGlobe, FaMapMarkerAlt } from "react-icons/fa";

export default function Footer() {
  return (
    <footer id="contact" className="footer">
      <div className="footerGrid">
        <div>
          <h2>AquiTech</h2>
          <p>Smart Aquaculture Monitoring System berbasis IoT dan dashboard web.</p>
        </div>

        <div>
          <h3>Contact</h3>
          <p><FaEnvelope /> info@aquaculture.m-tech.fun</p>
          <p><FaGlobe /> aquaculture.m-tech.fun</p>
          <p><FaMapMarkerAlt /> Surabaya, Indonesia</p>
        </div>
      </div>
    </footer>
  );
}