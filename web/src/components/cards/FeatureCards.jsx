import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import {
  FaWater,
  FaThermometerHalf,
  FaBroadcastTower,
  FaBell,
  FaWind,
  FaClipboardList,
  FaBoxes,
  FaChartBar,
} from "react-icons/fa";

gsap.registerPlugin(ScrollTrigger);

const features = [
  { icon: <FaWater />, title: "pH Monitoring", desc: "Pemantauan tingkat keasaman air secara real-time untuk menjaga stabilitas budidaya." },
  { icon: <FaWind />, title: "DO Sensor", desc: "Monitoring dissolved oxygen untuk mendukung kesehatan udang dan ikan." },
  { icon: <FaThermometerHalf />, title: "Suhu Air", desc: "Pencatatan suhu air secara berkala untuk kontrol lingkungan tambak." },
  { icon: <FaBroadcastTower />, title: "LoRa Gateway", desc: "Komunikasi data sensor jarak jauh dengan konsumsi daya yang efisien." },
  { icon: <FaBell />, title: "Early Warning", desc: "Notifikasi dini jika parameter kualitas air melebihi batas aman." },
  { icon: <FaClipboardList />, title: "Manajemen Tambak", desc: "Pencatatan aktivitas dan kontrol operasional tambak harian." },
  { icon: <FaBoxes />, title: "Manajemen Produksi", desc: "Pendataan panen, input produksi, dan evaluasi performa budidaya." },
  { icon: <FaChartBar />, title: "Dashboard Web", desc: "Visualisasi data monitoring yang mudah dibaca oleh petambak dan admin." },
];

export default function FeatureCards() {
  const sectionRef = useRef(null);
  const gridRef = useRef(null);

  useEffect(() => {
    const cards = gridRef.current.children;
    gsap.fromTo(
      cards,
      { y: 60, opacity: 0 },
      {
        y: 0,
        opacity: 1,
        duration: 0.8,
        ease: "power3.out",
        stagger: 0.08,
        scrollTrigger: {
          trigger: sectionRef.current,
          start: "top 80%",
          end: "top 40%",
          toggleActions: "play none none reverse",
        },
      }
    );
  }, []);

  return (
    <section id="features" className="section sectionAlt" ref={sectionRef}>
      <div className="sectionHeader">
        <p className="sectionEyebrow">Core Features</p>
        <h2 className="sectionTitle">Solusi Monitoring & Manajemen Tambak</h2>
        <p className="sectionSubtitle">
          Sistem terintegrasi untuk memantau kualitas air, mengelola produksi,
          dan mengoptimalkan hasil panen udang.
        </p>
      </div>

      <div className="featureGrid" ref={gridRef}>
        {features.map((f, i) => (
          <div className="featureCard" key={i}>
            <div className="featureIcon">{f.icon}</div>
            <h3>{f.title}</h3>
            <p>{f.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
