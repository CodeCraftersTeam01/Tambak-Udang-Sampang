import { useState, useEffect } from "react";
import API_URL from "../../services/api";
import { FaWater, FaSeedling, FaCalendarAlt } from "react-icons/fa";

export default function UsiaBenurSection() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`${API_URL}/api/public/usia-benur`)
      .then((res) => res.json())
      .then((json) => {
        setData(json.data || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Gagal mengambil data usia benur:", err);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <section className="section">
        <div className="sectionContainer">
          <h2 className="sectionTitle">Memuat Data Benur...</h2>
        </div>
      </section>
    );
  }

  if (data.length === 0) return null;

  return (
    <section id="benur" className="section" style={{ background: "rgba(0,0,0,0.4)", position: "relative", zIndex: 10 }}>
      <div className="sectionContainer">
        <h2 className="sectionTitle" style={{ textAlign: "center", marginBottom: "3rem" }}>
          Status Produksi Terkini
        </h2>
        
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))", gap: "2rem" }}>
          {data.map((item, idx) => (
            <div key={idx} style={{
              background: "rgba(255, 255, 255, 0.05)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
              borderRadius: "20px",
              padding: "2rem",
              backdropFilter: "blur(10px)",
              transition: "transform 0.3s ease",
            }}
            onMouseEnter={(e) => e.currentTarget.style.transform = "translateY(-5px)"}
            onMouseLeave={(e) => e.currentTarget.style.transform = "translateY(0)"}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "1.5rem" }}>
                <div style={{ width: "40px", height: "40px", borderRadius: "50%", background: "rgba(0, 113, 227, 0.2)", display: "flex", alignItems: "center", justifyContent: "center", color: "#0071e3" }}>
                  <FaWater size={20} />
                </div>
                <h3 style={{ fontSize: "1.2rem", fontWeight: "600", color: "#fff", margin: 0 }}>
                  {item.kolam}
                </h3>
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#86868b" }}>
                    <FaCalendarAlt />
                    <span>Usia Benur</span>
                  </div>
                  <span style={{ fontSize: "1.5rem", fontWeight: "700", color: "#30d158" }}>
                    {item.usia_benur} <span style={{ fontSize: "0.9rem", color: "#86868b", fontWeight: "400" }}>Hari</span>
                  </span>
                </div>
                
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#86868b" }}>
                    <FaSeedling />
                    <span>Ukuran Penebaran</span>
                  </div>
                  <span style={{ fontWeight: "600", color: "#f5f5f7" }}>
                    {item.ukuran_benor}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
