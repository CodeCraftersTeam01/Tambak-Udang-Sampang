import { useState, useEffect } from "react";
import API_URL from "../../services/api";
import {
  FaSwimmingPool,
  FaFish,
  FaBoxes,
  FaWater,
  FaThermometerHalf,
  FaWind,
  FaEye,
} from "react-icons/fa";

export default function LiveStatsSection() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`${API_URL}/api/public/stats`)
      .then((res) => res.json())
      .then((json) => {
        if (json.status === "success") {
          setStats(json.data);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error("Gagal memuat data statistik landing page:", err);
        setLoading(false);
      });
  }, []);

  if (loading || !stats) {
    return (
      <section className="section" style={{ background: "var(--bg-secondary)", position: "relative", zIndex: 10 }}>
        <div className="sectionContainer" style={{ textAlign: "center", padding: "4rem 2rem" }}>
          <h2 className="sectionTitle">Memuat Data Real-Time...</h2>
        </div>
      </section>
    );
  }

  // Helper to resolve icon based on sensor code
  const getSensorIcon = (code) => {
    switch (code) {
      case "ph":
        return <FaWater size={18} />;
      case "temperature":
        return <FaThermometerHalf size={18} />;
      case "do":
        return <FaWind size={18} />;
      case "tds":
        return <FaEye size={18} />;
      case "water_level":
        return <FaSwimmingPool size={18} />;
      default:
        return <FaWater size={18} />;
    }
  };

  return (
    <section id="stats" className="section" style={{ background: "var(--bg-secondary)", position: "relative", zIndex: 10, borderTop: "1px solid var(--border)", borderBottom: "1px solid var(--border)" }}>
      <div className="sectionContainer">
        <div className="sectionHeader" style={{ textAlign: "center", marginBottom: "4rem" }}>
          <p className="sectionEyebrow">Live Operations</p>
          <h2 className="sectionTitle">Data Produksi & IoT Real-Time</h2>
          <p className="sectionSubtitle">
            Informasi akurat langsung dari sistem sensor LoRaWAN dan pembukuan tambak kami.
          </p>
        </div>

        {/* Dynamic Aggregated Counter Grid */}
        <div style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "24px",
          marginBottom: "60px"
        }}>
          <div style={{
            background: "var(--bg-card)",
            border: "1px solid var(--border)",
            borderRadius: "20px",
            padding: "24px 32px",
            display: "flex",
            alignItems: "center",
            gap: "20px",
            backdropFilter: "blur(10px)"
          }}>
            <div style={{ width: "56px", height: "56px", borderRadius: "16px", background: "rgba(0, 113, 227, 0.15)", display: "flex", alignItems: "center", justifySelf: "center", justifyContent: "center", color: "var(--accent)" }}>
              <FaSwimmingPool size={26} />
            </div>
            <div>
              <span style={{ display: "block", fontSize: "14px", color: "var(--text-secondary)", marginBottom: "4px" }}>Kolam Aktif</span>
              <strong style={{ fontSize: "28px", fontWeight: "800", color: "var(--text-primary)" }}>{stats.total_kolam} <span style={{ fontSize: "16px", fontWeight: "500", color: "var(--text-secondary)" }}>Kolam</span></strong>
            </div>
          </div>

          <div style={{
            background: "var(--bg-card)",
            border: "1px solid var(--border)",
            borderRadius: "20px",
            padding: "24px 32px",
            display: "flex",
            alignItems: "center",
            gap: "20px",
            backdropFilter: "blur(10px)"
          }}>
            <div style={{ width: "56px", height: "56px", borderRadius: "16px", background: "rgba(48, 209, 88, 0.15)", display: "flex", alignItems: "center", justifyContent: "center", color: "#30d158" }}>
              <FaFish size={26} />
            </div>
            <div>
              <span style={{ display: "block", fontSize: "14px", color: "var(--text-secondary)", marginBottom: "4px" }}>Hasil Panen Akumulatif</span>
              <strong style={{ fontSize: "28px", fontWeight: "800", color: "var(--text-primary)" }}>{stats.total_panen_kg.toLocaleString("id-ID")} <span style={{ fontSize: "16px", fontWeight: "500", color: "var(--text-secondary)" }}>kg</span></strong>
            </div>
          </div>

          <div style={{
            background: "var(--bg-card)",
            border: "1px solid var(--border)",
            borderRadius: "20px",
            padding: "24px 32px",
            display: "flex",
            alignItems: "center",
            gap: "20px",
            backdropFilter: "blur(10px)"
          }}>
            <div style={{ width: "56px", height: "56px", borderRadius: "16px", background: "rgba(255, 159, 10, 0.15)", display: "flex", alignItems: "center", justifyContent: "center", color: "#ff9f0a" }}>
              <FaBoxes size={26} />
            </div>
            <div>
              <span style={{ display: "block", fontSize: "14px", color: "var(--text-secondary)", marginBottom: "4px" }}>Pakan Didistribusikan</span>
              <strong style={{ fontSize: "28px", fontWeight: "800", color: "var(--text-primary)" }}>{stats.total_pakan_kg.toLocaleString("id-ID")} <span style={{ fontSize: "16px", fontWeight: "500", color: "var(--text-secondary)" }}>kg</span></strong>
            </div>
          </div>
        </div>

        {/* Live Device Monitor Showcase */}
        {stats.latest_readings && stats.latest_readings.length > 0 && (
          <div style={{
            background: "var(--bg-card)",
            border: "1px solid var(--border)",
            borderRadius: "24px",
            padding: "36px",
            backdropFilter: "blur(10px)",
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px", borderBottom: "1px solid var(--border)", paddingBottom: "20px", marginBottom: "30px" }}>
              <div>
                <h3 style={{ fontSize: "1.35rem", fontWeight: "700", color: "var(--text-primary)", margin: "0 0 6px 0" }}>
                  Live Monitor: {stats.monitoring_pond_name}
                </h3>
                <p style={{ margin: 0, fontSize: "13px", color: "var(--text-secondary)" }}>
                  Data sensor terkirim langsung dari node IoT di lapangan.
                </p>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: "8px", background: "rgba(0, 113, 227, 0.1)", border: "1px solid var(--accent)", borderRadius: "30px", padding: "6px 16px", fontSize: "13px", color: "var(--accent-2)" }}>
                <span className="liveDot" style={{ width: "8px", height: "8px", borderRadius: "50%", background: "#30d158", display: "inline-block", boxShadow: "0 0 10px #30d158", animation: "pulse 1.8s infinite" }}></span>
                <strong>Live Terhubung</strong>
              </div>
            </div>

            <div style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
              gap: "20px"
            }}>
              {stats.latest_readings.map((r, i) => (
                <div key={i} style={{
                  background: "rgba(255,255,255,0.02)",
                  border: "1px solid var(--border)",
                  borderRadius: "16px",
                  padding: "20px",
                  textAlign: "center"
                }}>
                  <div style={{ width: "36px", height: "36px", borderRadius: "50%", background: "rgba(255,255,255,0.05)", display: "flex", alignItems: "center", justifyContent: "center", color: "var(--text-secondary)", margin: "0 auto 12px auto" }}>
                    {getSensorIcon(r.code)}
                  </div>
                  <span style={{ display: "block", fontSize: "12px", color: "var(--text-secondary)", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: "6px" }}>
                    {r.name}
                  </span>
                  <strong style={{ fontSize: "22px", fontWeight: "700", color: "var(--text-primary)" }}>
                    {r.value} <span style={{ fontSize: "13px", fontWeight: "400", color: "var(--text-secondary)" }}>{r.unit}</span>
                  </strong>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </section>
  );
}
