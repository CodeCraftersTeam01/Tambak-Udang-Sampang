import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaFish, FaEdit, FaTrash, FaChartBar } from "react-icons/fa";
import {
  Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement
} from "chart.js";
import { Bar, Pie } from "react-chartjs-2";

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement);
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";

const empty = { tanggal_panen: "", jumlah_panen_kg: "", jenis_panen: "parsial", kolam_id: "", shrimp_size: "", sale_price: "" };
const COLORS = ["#0071e3", "#30d158", "#ff9f0a", "#ff3b30", "#5e5ce6"];

function Toast({ message, type, onHide }) {
  useEffect(() => { const t = setTimeout(onHide, 3000); return () => clearTimeout(t); }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
}

function PanenModal({ mode, data, kolams, onClose, onSaved }) {
  const [form, setForm] = useState(
    data ? { 
      tanggal_panen: data.tanggal_panen?.slice(0, 10) || "", 
      jumlah_panen_kg: data.jumlah_panen_kg, 
      jenis_panen: data.jenis_panen, 
      kolam_id: String(data.kolam_id),
      shrimp_size: data.shrimp_size || "",
      sale_price: data.sale_price || ""
    } : empty
  );
  const [saving, setSaving] = useState(false);
  const handleSubmit = async (e) => {
    e.preventDefault(); setSaving(true);
    try {
      if (mode === "edit") {
        await apiClient.put(`/panen/${data.id}`, form);
        onSaved("Panen diperbarui!");
      } else {
        await apiClient.post(`/panen`, form);
        onSaved("Panen ditambahkan!");
      }
      onClose();
    } catch (err) { 
      const msg = err.response?.data?.message || err.response?.data?.error || "Terjadi kesalahan.";
      onSaved(msg, "error"); 
    } finally { setSaving(false); }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit Panen" : "Catat Panen"}</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dashFormGroup">
            <label>Kolam</label>
            <select value={form.kolam_id} onChange={(e) => setForm({ ...form, kolam_id: e.target.value })} required>
              <option value="">Pilih Kolam...</option>
              {kolams.map((k) => <option key={k.id} value={k.id}>{k.nama_kolam}</option>)}
            </select>
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Tanggal Panen</label>
              <input type="date" value={form.tanggal_panen} onChange={(e) => setForm({ ...form, tanggal_panen: e.target.value })} required />
            </div>
            <div className="dashFormGroup">
              <label>Jumlah (kg)</label>
              <input type="number" step="0.01" value={form.jumlah_panen_kg} onChange={(e) => setForm({ ...form, jumlah_panen_kg: e.target.value })} placeholder="0.00" required />
            </div>
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Ukuran Udang (Size)</label>
              <input value={form.shrimp_size} onChange={(e) => setForm({ ...form, shrimp_size: e.target.value })} placeholder="cth: 100, PL-10" required />
            </div>
            <div className="dashFormGroup">
              <label>Harga Jual (Rp/kg)</label>
              <input type="number" value={form.sale_price} onChange={(e) => setForm({ ...form, sale_price: e.target.value })} placeholder="Harga per kg" required />
            </div>
          </div>
          <div className="dashFormGroup">
            <label>Jenis Panen</label>
            <select value={form.jenis_panen} onChange={(e) => setForm({ ...form, jenis_panen: e.target.value })}>
              <option value="parsial">Parsial</option>
              <option value="total">Total</option>
            </select>
          </div>
          <div className="dashFormActions">
            <button type="button" className="btnCancel" onClick={onClose}>Batal</button>
            <button type="submit" className="btnSubmit" disabled={saving}>{saving ? "Menyimpan..." : "Simpan"}</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function PanenPage() {
  const [data, setData] = useState([]);
  const [kolams, setKolams] = useState([]);
  const [statistik, setStatistik] = useState(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);
  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const [panenRes, kolamRes, statRes] = await Promise.all([
        apiClient.get(`/panen`),
        apiClient.get(`/kolam`),
        apiClient.get(`/panen/statistik`),
      ]);
      setData(panenRes.data.data || []);
      setKolams(kolamRes.data.data || []);
      setStatistik(statRes.data.data || null);
    } catch { showToast("Gagal memuat data.", "error"); } finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const showToast = (msg, type = "success") => setToast({ message: msg, type });

  const handleDelete = async () => {
    try {
      await apiClient.delete(`/panen/${confirmDelete.id}`);
      showToast("Data dihapus!"); fetchData();
    } catch { showToast("Gagal menghapus.", "error"); } finally { setConfirmDelete(null); }
  };

  const filtered = data.filter((d) =>
    (d.kolam?.nama_kolam || "").toLowerCase().includes(search.toLowerCase()) ||
    (d.jenis_panen || "").toLowerCase().includes(search.toLowerCase())
  );

  const barChartData = {
    labels: (statistik?.per_bulan || []).map((b) => b.bulan),
    datasets: [
      {
        label: "Total Panen (kg)",
        data: (statistik?.per_bulan || []).map((b) => parseFloat(b.total_kg)),
        backgroundColor: "#0071e3",
        borderRadius: 4,
      },
    ],
  };

  const barChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { color: "rgba(255,255,255,0.05)" }, ticks: { color: "#6e6e80" } },
      y: { grid: { color: "rgba(255,255,255,0.05)" }, ticks: { color: "#6e6e80" } },
    },
  };

  const pieChartData = {
    labels: (statistik?.breakdown || []).map((b) => b.jenis_panen.charAt(0).toUpperCase() + b.jenis_panen.slice(1)),
    datasets: [
      {
        data: (statistik?.breakdown || []).map((b) => parseFloat(b.total_kg)),
        backgroundColor: COLORS,
        borderWidth: 0,
      },
    ],
  };

  const pieChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: "bottom", labels: { color: "#f5f5f7" } },
      tooltip: { callbacks: { label: (ctx) => ` ${ctx.raw.toFixed(1)} kg` } }
    },
  };

  return (
    <DashboardLayout title="Panen">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Manajemen Panen</h1>
          <p className="dashPageSubtitle">{data.length} catatan panen</p>
        </div>
        <button className="btnPrimary" onClick={() => setModal({ mode: "add", data: null })}>
          <FaPlus /> Catat Panen
        </button>
      </div>

      {/* Stat Cards */}
      {statistik && (
        <div className="statGrid" style={{ marginBottom: 24 }}>
          <div className="statCard">
            <div className="statCardIcon blue"><FaFish /></div>
            <div className="statCardValue">{statistik.total_kg?.toFixed(1)} kg</div>
            <div className="statCardLabel">Total Panen</div>
          </div>
          <div className="statCard">
            <div className="statCardIcon green"><FaChartBar /></div>
            <div className="statCardValue">{statistik.total_event}</div>
            <div className="statCardLabel">Total Event Panen</div>
          </div>
          {(statistik.breakdown || []).map((b, i) => (
            <div className="statCard" key={i}>
              <div className={`statCardIcon ${i === 0 ? "orange" : "red"}`}><FaFish /></div>
              <div className="statCardValue">{parseFloat(b.total_kg).toFixed(1)} kg</div>
              <div className="statCardLabel">Panen {b.jenis_panen.charAt(0).toUpperCase() + b.jenis_panen.slice(1)}</div>
            </div>
          ))}
        </div>
      )}

      {/* Charts Row */}
      {barChartData.labels.length > 0 && (
        <div style={{ display: "grid", gridTemplateColumns: "1fr 340px", gap: 16, marginBottom: 24 }}>
          <div className="tableCard" style={{ padding: 24 }}>
            <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 20 }}>📈 Panen per Bulan (12 Bulan Terakhir)</h3>
            <div style={{ width: "100%", height: 220 }}>
              <Bar data={barChartData} options={barChartOptions} />
            </div>
          </div>
          <div className="tableCard" style={{ padding: 24 }}>
            <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 20 }}>🥧 Parsial vs Total</h3>
            <div style={{ width: "100%", height: 220 }}>
              <Pie data={pieChartData} options={pieChartOptions} />
            </div>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="tableCard">
        <div className="tableCardHeader">
          <span className="tableCardTitle">Riwayat Panen</span>
          <input className="tableSearch" placeholder="Cari kolam atau jenis..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <div className="tableWrapper">
          {loading ? <div className="loadingSpinner">Memuat data...</div> : filtered.length === 0 ? (
            <div className="emptyState"><FaFish /><p>Belum ada catatan panen.</p></div>
          ) : (
            <table>
              <thead><tr><th>#</th><th>Kolam</th><th>Tanggal Panen</th><th>Jumlah (kg)</th><th>Jenis</th><th>Aksi</th></tr></thead>
              <tbody>
                {filtered.map((d, i) => (
                  <tr key={d.id}>
                    <td className="tdMuted">{i + 1}</td>
                    <td style={{ fontWeight: 600 }}>{d.kolam?.nama_kolam || "-"}</td>
                    <td>{d.tanggal_panen}</td>
                    <td style={{ fontWeight: 700 }}>{parseFloat(d.jumlah_panen_kg).toFixed(2)} kg</td>
                    <td><span className={`tableBadge ${d.jenis_panen === "parsial" ? "admin" : "active"}`}>{d.jenis_panen}</span></td>
                    <td>
                      <div className="tableActions">
                        <button className="btnEdit" onClick={() => setModal({ mode: "edit", data: d })}><FaEdit style={{ marginRight: 4 }} /> Edit</button>
                        <button className="btnDelete" onClick={() => setConfirmDelete(d)}><FaTrash style={{ marginRight: 4 }} /> Hapus</button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {modal && <PanenModal mode={modal.mode} data={modal.data} kolams={kolams} onClose={() => setModal(null)} onSaved={(msg, type) => { showToast(msg, type); fetchData(); }} />}
      {confirmDelete && (
        <div className="dashModalOverlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
            <div className="confirmIcon">🗑️</div>
            <h3 className="confirmTitle">Hapus Data Panen?</h3>
            <p className="confirmDesc">Data panen pada <strong>"{confirmDelete.kolam?.nama_kolam}"</strong> tanggal <strong>{confirmDelete.tanggal_panen}</strong> akan dihapus permanen.</p>
            <div className="confirmActions">
              <button className="btnCancel" onClick={() => setConfirmDelete(null)}>Batal</button>
              <button className="btnDanger" onClick={handleDelete}>Ya, Hapus</button>
            </div>
          </div>
        </div>
      )}
      {toast && <Toast message={toast.message} type={toast.type} onHide={() => setToast(null)} />}
    </DashboardLayout>
  );
}
