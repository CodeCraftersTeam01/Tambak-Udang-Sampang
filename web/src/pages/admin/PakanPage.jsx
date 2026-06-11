import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaBoxes, FaEdit, FaTrash } from "react-icons/fa";
import {
  Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend
} from "chart.js";
import { Bar } from "react-chartjs-2";

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);
import DashboardLayout from "../../components/admin/DashboardLayout";
import API_URL from "../../services/api";

const empty = { nama_pakan: "", jumlah_perminggu_kg: "", kolam_id: "" };

function Toast({ message, type, onHide }) {
  useEffect(() => { const t = setTimeout(onHide, 3000); return () => clearTimeout(t); }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
}

function PakanModal({ mode, data, kolams, onClose, onSaved }) {
  const [form, setForm] = useState(
    data ? { nama_pakan: data.nama_pakan, jumlah_perminggu_kg: data.jumlah_perminggu_kg, kolam_id: String(data.kolam_id) } : empty
  );
  const [saving, setSaving] = useState(false);
  const token = localStorage.getItem("token");

  const handleSubmit = async (e) => {
    e.preventDefault(); setSaving(true);
    try {
      const url = mode === "edit" ? `${API_URL}/api/pakan/${data.id}` : `${API_URL}/api/pakan`;
      const res = await fetch(url, { method: mode === "edit" ? "PUT" : "POST", headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}`, Accept: "application/json" }, body: JSON.stringify(form) });
      if (!res.ok) throw new Error();
      onSaved(mode === "edit" ? "Pakan diperbarui!" : "Pakan ditambahkan!"); onClose();
    } catch { onSaved("Terjadi kesalahan.", "error"); } finally { setSaving(false); }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit Pakan" : "Tambah Pakan"}</h3>
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
          <div className="dashFormGroup">
            <label>Nama Pakan</label>
            <input value={form.nama_pakan} onChange={(e) => setForm({ ...form, nama_pakan: e.target.value })} placeholder="cth: Pakan Komersil A" required />
          </div>
          <div className="dashFormGroup">
            <label>Jumlah per Minggu (kg)</label>
            <input type="number" step="0.01" value={form.jumlah_perminggu_kg} onChange={(e) => setForm({ ...form, jumlah_perminggu_kg: e.target.value })} placeholder="0.00" required />
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

export default function PakanPage() {
  const [data, setData] = useState([]);
  const [kolams, setKolams] = useState([]);
  const [statistik, setStatistik] = useState(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);
  const token = localStorage.getItem("token");
  const headers = { Authorization: `Bearer ${token}`, Accept: "application/json" };

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const [pakanRes, kolamRes, statRes] = await Promise.all([
        fetch(`${API_URL}/api/pakan`, { headers }).then((r) => r.json()),
        fetch(`${API_URL}/api/kolam`, { headers }).then((r) => r.json()),
        fetch(`${API_URL}/api/pakan/statistik`, { headers }).then((r) => r.json()),
      ]);
      setData(pakanRes.data || []);
      setKolams(kolamRes.data || []);
      setStatistik(statRes.data || null);
    } catch { showToast("Gagal memuat data.", "error"); } finally { setLoading(false); }
  }, [token]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const showToast = (msg, type = "success") => setToast({ message: msg, type });

  const handleDelete = async () => {
    try {
      await fetch(`${API_URL}/api/pakan/${confirmDelete.id}`, { method: "DELETE", headers });
      showToast("Data dihapus!"); fetchData();
    } catch { showToast("Gagal menghapus.", "error"); } finally { setConfirmDelete(null); }
  };

  const chartData = {
    labels: (statistik?.per_kolam || []).map((k) => k.nama_kolam),
    datasets: [
      {
        label: "Konsumsi (kg/minggu)",
        data: (statistik?.per_kolam || []).map((k) => parseFloat(k.total_kg)),
        backgroundColor: "#ff9f0a",
        borderRadius: 4,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { color: "rgba(255,255,255,0.05)" }, ticks: { color: "#6e6e80" } },
      y: { grid: { color: "rgba(255,255,255,0.05)" }, ticks: { color: "#6e6e80" } },
    },
  };

  const filtered = data.filter((d) =>
    (d.kolam?.nama_kolam || "").toLowerCase().includes(search.toLowerCase()) ||
    d.nama_pakan?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <DashboardLayout title="Pakan">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Manajemen Pakan</h1>
          <p className="dashPageSubtitle">{data.length} jenis pakan terdaftar</p>
        </div>
        <button className="btnPrimary" onClick={() => setModal({ mode: "add", data: null })}>
          <FaPlus /> Tambah Pakan
        </button>
      </div>

      {/* Stat + Chart */}
      <div style={{ display: "grid", gridTemplateColumns: "220px 1fr", gap: 16, marginBottom: 24 }}>
        <div className="statCard" style={{ alignSelf: "start" }}>
          <div className="statCardIcon orange"><FaBoxes /></div>
          <div className="statCardValue">{statistik?.total_perminggu_kg?.toFixed(1) ?? "..."} kg</div>
          <div className="statCardLabel">Total Konsumsi / Minggu</div>
        </div>
        {chartData.labels && chartData.labels.length > 0 && (
          <div className="tableCard" style={{ padding: 24 }}>
            <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 20 }}>📊 Konsumsi Pakan per Kolam (kg/minggu)</h3>
            <div style={{ width: "100%", height: 200 }}>
              <Bar data={chartData} options={chartOptions} />
            </div>
          </div>
        )}
      </div>

      {/* Table */}
      <div className="tableCard">
        <div className="tableCardHeader">
          <span className="tableCardTitle">Data Pakan</span>
          <input className="tableSearch" placeholder="Cari kolam atau nama pakan..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <div className="tableWrapper">
          {loading ? <div className="loadingSpinner">Memuat data...</div> : filtered.length === 0 ? (
            <div className="emptyState"><FaBoxes /><p>Belum ada data pakan.</p></div>
          ) : (
            <table>
              <thead><tr><th>#</th><th>Kolam</th><th>Nama Pakan</th><th>Jumlah / Minggu</th><th>Aksi</th></tr></thead>
              <tbody>
                {filtered.map((d, i) => (
                  <tr key={d.id}>
                    <td className="tdMuted">{i + 1}</td>
                    <td style={{ fontWeight: 600 }}>{d.kolam?.nama_kolam || "-"}</td>
                    <td>{d.nama_pakan}</td>
                    <td style={{ fontWeight: 700, color: "#ff9f0a" }}>{parseFloat(d.jumlah_perminggu_kg).toFixed(2)} kg</td>
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

      {modal && <PakanModal mode={modal.mode} data={modal.data} kolams={kolams} onClose={() => setModal(null)} onSaved={(msg, type) => { showToast(msg, type); fetchData(); }} />}
      {confirmDelete && (
        <div className="dashModalOverlay" onClick={() => setConfirmDelete(null)}>
          <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
            <div className="confirmIcon">🗑️</div>
            <h3 className="confirmTitle">Hapus Data Pakan?</h3>
            <p className="confirmDesc">Pakan <strong>"{confirmDelete.nama_pakan}"</strong> akan dihapus permanen.</p>
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
