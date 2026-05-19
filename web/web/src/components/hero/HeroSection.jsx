import { FaTint, FaWifi, FaBell, FaChartLine } from "react-icons/fa";

export default function HeroSection() {
  return (
    <section id="home" className="hero">
      <div className="heroOverlay"></div>

      <div className="heroContent">
        <p className="eyebrow">Dedicated Smart Fish Farming</p>
        <h1>Smart Aquaculture Monitoring System</h1>
        <p className="heroDesc">
          Monitoring kualitas air tambak berbasis IoT untuk mendukung peringatan dini,
          efisiensi budidaya, dan pengambilan keputusan berbasis data.
        </p>

        <div className="heroActions">
          <a href="#features" className="btn primaryBtn">Explore Features</a>
          <a href="#contact" className="btn secondaryBtn">Contact Us</a>
        </div>

        <div className="heroBadges">
          <div className="heroBadge">
            <FaTint />
            <span>Water Quality</span>
          </div>
          <div className="heroBadge">
            <FaWifi />
            <span>IoT Sensor</span>
          </div>
          <div className="heroBadge">
            <FaBell />
            <span>Early Warning</span>
          </div>
          <div className="heroBadge">
            <FaChartLine />
            <span>Dashboard Analytics</span>
          </div>
        </div>
      </div>
    </section>
  );
}