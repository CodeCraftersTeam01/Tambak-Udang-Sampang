import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaWater, FaUsers, FaCheckCircle, FaFish,
  FaBoxes, FaSeedling, FaMapMarkerAlt, FaArrowRight,
  FaHandSparkles, FaSwimmingPool
} from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import KolamDetailModal from "../../components/admin/KolamDetailModal";
import apiClient from "../../core/network/apiClient";

export default function Dashboard() {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    kolam: 0, users: 0, totalPanen: 0, totalPakan: 0, produksi: 0, kolams: [],
  });
  const [loading, setLoading] = useState(true);
  const [detailModal, setDetailModal] = useState(null);
  useEffect(() => {
    const fetchDashboardData = () => {
      Promise.all([
        apiClient.get('/kolam'),
        apiClient.get('/panen/statistik'),
        apiClient.get('/pakan/statistik'),
        apiClient.get('/produksi'),
      ])
        .then(([kolamRes, panenStat, pakanStat, produksiRes]) => {
          const kolams = kolamRes.data.data || [];
          const activeKolam = kolams.filter(k => k.status === 'aktif' || k.status == 1).length;
          const produksis = produksiRes.data.data || [];
          const avgUsia = produksis.length ? Math.round(produksis.reduce((sum, p) => sum + (p.usia_benur || 0), 0) / produksis.length) : 0;
          
          setStats({
            kolam: activeKolam,
            totalPanen: panenStat.data.data?.total_kg || 0,
            totalPakan: pakanStat.data.data?.total_perminggu_kg || 0,
            usiaBenur: avgUsia,
            kolams,
          });
        })
        .catch((err) => {
          console.error("Dashboard Fetch Error:", err);
        })
        .finally(() => setLoading(false));
    };

    fetchDashboardData();
    const intervalId = setInterval(fetchDashboardData, 60000);
    return () => clearInterval(intervalId);
  }, []);

  const cards = [
    { icon: <FaSwimmingPool />, value: stats.kolam, label: "Active Ponds", color: "blue", path: "/admin/kolam" },
    { icon: <FaBoxes />, value: `${parseFloat(stats.totalPakan).toFixed(1)} kg`, label: "Total Pakan", color: "red", path: "/admin/pakan" },
    { icon: <FaFish />, value: `${parseFloat(stats.totalPanen).toFixed(1)} kg`, label: "Total Panen", color: "orange", path: "/admin/panen" },
    { icon: <FaSeedling />, value: `${stats.usiaBenur} hari`, label: "Rata-rata Usia Benur", color: "green", path: "/admin/produksi" },
  ];

  return (
    <DashboardLayout title="Dashboard">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Selamat Datang <FaHandSparkles style={{ color: "#ff9f0a" }} /></h1>
          <p className="dashPageSubtitle">Ringkasan kondisi sistem tambak Anda hari ini.</p>
        </div>
      </div>

      {loading ? (
        <div className="loadingSpinner">Memuat data...</div>
      ) : (
        <>
          {/* Stat Cards */}
          <div className="statGrid">
            {cards.map((c, i) => (
              <div className="statCard" key={i} style={{ cursor: "pointer" }} onClick={() => navigate(c.path)}>
                <div className={`statCardIcon ${c.color}`}>{c.icon}</div>
                <div className="statCardValue">{c.value}</div>
                <div className="statCardLabel">{c.label}</div>
              </div>
            ))}
          </div>

          {/* Kolam Info Grid */}
          <div style={{ marginTop: 32 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 16 }}>
              <h2 style={{ fontSize: 16, fontWeight: 700, display: "flex", alignItems: "center", gap: 8 }}><FaSwimmingPool color="#0071e3" /> Informasi Kolam</h2>
              <button
                onClick={() => navigate("/admin/kolam")}
                style={{ display: "flex", alignItems: "center", gap: 6, background: "none", border: "none", color: "var(--dash-accent)", fontSize: 13, cursor: "pointer", fontWeight: 600 }}
              >
                Lihat Semua <FaArrowRight />
              </button>
            </div>

            {stats.kolams.length === 0 ? (
              <div className="emptyState">
                <FaWater />
                <p>Belum ada data kolam. <button onClick={() => navigate("/admin/kolam")} style={{ color: "var(--dash-accent)", background: "none", border: "none", cursor: "pointer", fontWeight: 600 }}>Tambah sekarang</button></p>
              </div>
            ) : (
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 14 }}>
                {stats.kolams.map((k) => (
                  <div
                    key={k.id}
                    className="statCard"
                    style={{ cursor: "pointer", padding: 20 }}
                    onClick={() => setDetailModal(k)}
                  >
                    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
                      <span style={{ fontWeight: 700, fontSize: 15 }}>{k.nama_kolam}</span>
                      <span className={`tableBadge ${k.status == 1 || k.status === "aktif" ? "active" : "inactive"}`}>
                        {k.status == 1 || k.status === "aktif" ? "Aktif" : "Non-Aktif"}
                      </span>
                    </div>
                    {k.lat && k.long && (
                      <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 12, color: "var(--dash-muted)" }}>
                        <FaMapMarkerAlt style={{ color: "var(--dash-accent)", fontSize: 11 }} />
                        {parseFloat(k.lat).toFixed(5)}, {parseFloat(k.long).toFixed(5)}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </>
      )}

      <KolamDetailModal 
        open={!!detailModal} 
        kolam={detailModal} 
        onClose={() => setDetailModal(null)} 
      />
    </DashboardLayout>
  );
}