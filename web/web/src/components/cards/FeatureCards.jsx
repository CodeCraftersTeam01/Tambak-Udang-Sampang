import {
  FaWater,
  FaThermometerHalf,
  FaBroadcastTower,
  FaBell,
  FaWind,
  FaClipboardList,
  FaBoxes,
} from "react-icons/fa";

export default function FeatureCards() {
  return (
    <section id="features" className="featuresSection">
      <div className="sectionHeading">
        <p className="eyebrow">Core Features</p>
        <h2>Solusi Monitoring dan Manajemen Tambak</h2>
        <p>
          Sistem ini tidak hanya memantau kualitas air, tetapi juga mendukung
          manajemen operasional tambak dan pencatatan produksi secara lebih rapi.
        </p>
      </div>

      <div className="cards">
        <div className="card">
          <div className="cardIcon"><FaWater /></div>
          <h3>pH Monitoring</h3>
          <p>Pemantauan tingkat keasaman air untuk menjaga stabilitas budidaya.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaWind /></div>
          <h3>DO Sensor</h3>
          <p>Monitoring dissolved oxygen untuk mendukung kesehatan udang dan ikan.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaThermometerHalf /></div>
          <h3>Suhu Air</h3>
          <p>Pencatatan suhu air secara berkala untuk kontrol lingkungan tambak.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaBroadcastTower /></div>
          <h3>LoRa Gateway</h3>
          <p>Komunikasi data sensor jarak jauh dengan konsumsi daya efisien.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaBell /></div>
          <h3>Early Warning</h3>
          <p>Notifikasi dini jika parameter kualitas air melebihi batas aman.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaClipboardList /></div>
          <h3>Manajemen Tambak</h3>
          <p>Pencatatan aktivitas tambak, kontrol operasional, dan monitoring kondisi lapangan.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaBoxes /></div>
          <h3>Manajemen Produksi</h3>
          <p>Pendataan panen, input produksi, hasil budidaya, dan evaluasi performa produksi.</p>
        </div>

        <div className="card">
          <div className="cardIcon"><FaBroadcastTower /></div>
          <h3>Dashboard Web</h3>
          <p>Visualisasi data monitoring agar mudah dibaca oleh petambak dan admin.</p>
        </div>
      </div>
    </section>
  );
}