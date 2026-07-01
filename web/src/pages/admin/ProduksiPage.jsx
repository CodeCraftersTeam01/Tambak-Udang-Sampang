import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaSeedling, FaEdit, FaTrash, FaClipboardList } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";

const empty = { tanggal_pemasangan_benor: "", ukuran_benor: "", kolam_id: "" };

function Toast({ message, type, onHide }) {
  useEffect(() => { const t = setTimeout(onHide, 3000); return () => clearTimeout(t); }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
}

function LogHarianModal({ kolam_id, onClose, onSaved }) {
  const [form, setForm] = useState({
    kolam_id: String(kolam_id),
    pakan_harian_kg: "",
    mbw_gram: "",
    kematian_ekor: "",
    suhu: "",
    ph: "",
    do: "",
    tds: ""
  });
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await apiClient.post(`/produksi/log`, form);
      onSaved("Log harian berhasil dicatat!", "success");
      onClose();
    } catch (err) {
      onSaved("Gagal mencatat log harian.", "error");
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">Catat Log Harian</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px", marginBottom: "24px" }}>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>Pakan (kg)</label>
              <input name="pakan_harian_kg" type="number" step="0.01" value={form.pakan_harian_kg} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>Kematian (ekor)</label>
              <input name="kematian_ekor" type="number" value={form.kematian_ekor} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>MBW (gram)</label>
              <input name="mbw_gram" type="number" step="0.01" value={form.mbw_gram} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>Suhu (°C)</label>
              <input name="suhu" type="number" step="0.1" value={form.suhu} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>pH Air</label>
              <input name="ph" type="number" step="0.1" value={form.ph} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>DO (mg/L)</label>
              <input name="do" type="number" step="0.1" value={form.do} onChange={handleChange} required />
            </div>
            <div className="dashFormGroup" style={{ marginBottom: 0 }}>
              <label>TDS (ppm)</label>
              <input name="tds" type="number" step="1" value={form.tds} onChange={handleChange} required />
            </div>
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

function ProduksiModal({ mode, data, kolams, onClose, onSaved }) {
  const [form, setForm] = useState(
    data ? { tanggal_pemasangan_benor: data.tanggal_pemasangan_benor?.slice(0, 10) || "", ukuran_benor: data.ukuran_benor, kolam_id: String(data.kolam_id) } : empty
  );
  const [saving, setSaving] = useState(false);
  const token = localStorage.getItem("token");

  const handleSubmit = async (e) => {
    e.preventDefault(); setSaving(true);
    try {
      if (mode === "edit") {
        await apiClient.put(`/produksi/${data.id}`, form);
        onSaved("Produksi diperbarui!");
      } else {
        await apiClient.post(`/produksi`, form);
        onSaved("Produksi ditambahkan!");
      }
      onClose();
    } catch { onSaved("Terjadi kesalahan.", "error"); } finally { setSaving(false); }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit Produksi" : "Tambah Produksi"}</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dashFormGroup">
            <label>Kolam</label>
            <select name="kolam_id" value={form.kolam_id} onChange={(e) => setForm({ ...form, kolam_id: e.target.value })} required>
              <option value="">Pilih Kolam...</option>
              {kolams.map((k) => <option key={k.id} value={k.id}>{k.nama_kolam}</option>)}
            </select>
          </div>
          <div className="dashFormGroup">
            <label>Tanggal Pemasangan Benur</label>
            <input type="date" value={form.tanggal_pemasangan_benor} onChange={(e) => setForm({ ...form, tanggal_pemasangan_benor: e.target.value })} required />
          </div>
          <div className="dashFormGroup">
            <label>Ukuran Benur</label>
            <input value={form.ukuran_benor} onChange={(e) => setForm({ ...form, ukuran_benor: e.target.value })} placeholder="cth: PL-10, PL-12" required />
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

function ConfirmDelete({ item, label, onCancel, onConfirm }) {
  return (
    <div className="dashModalOverlay" onClick={onCancel}>
      <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
        <div className="confirmIcon">🗑️</div>
        <h3 className="confirmTitle">Hapus Data?</h3>
        <p className="confirmDesc">Data <strong>"{label}"</strong> akan dihapus permanen.</p>
        <div className="confirmActions">
          <button className="btnCancel" onClick={onCancel}>Batal</button>
          <button className="btnDanger" onClick={onConfirm}>Ya, Hapus</button>
        </div>
      </div>
    </div>
  );
}

export default function ProduksiPage() {
  const [data, setData] = useState([]);
  const [kolams, setKolams] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null);
  const [logModal, setLogModal] = useState(null); // stores kolam_id for the log modal
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const [prodRes, kolamRes] = await Promise.all([
        apiClient.get(`/produksi`),
        apiClient.get(`/kolam`),
      ]);
      setData(prodRes.data.data || []);
      setKolams(kolamRes.data.data || []);
    } catch { showToast("Gagal memuat data.", "error"); } finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const showToast = (message, type = "success") => setToast({ message, type });

  const handleDelete = async () => {
    try {
      await apiClient.delete(`/produksi/${confirmDelete.id}`);
      showToast("Data dihapus!"); fetchData();
    } catch { showToast("Gagal menghapus.", "error"); } finally { setConfirmDelete(null); }
  };

  const filtered = data.filter((d) =>
    (d.kolam?.nama_kolam || "").toLowerCase().includes(search.toLowerCase()) ||
    d.ukuran_benor?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <DashboardLayout title="Produksi">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Manajemen Produksi</h1>
          <p className="dashPageSubtitle">{data.length} siklus produksi terdaftar</p>
        </div>
        <button className="btnPrimary" onClick={() => setModal({ mode: "add", data: null })}>
          <FaPlus /> Tambah Produksi
        </button>
      </div>

      <div className="tableCard">
        <div className="tableCardHeader">
          <span className="tableCardTitle">Data Produksi Benur</span>
          <input className="tableSearch" placeholder="Cari kolam atau ukuran..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <div className="tableWrapper">
          {loading ? <div className="loadingSpinner">Memuat data...</div> : filtered.length === 0 ? (
            <div className="emptyState"><FaSeedling /><p>Belum ada data produksi.</p></div>
          ) : (
            <table>
              <thead><tr><th>#</th><th>Kolam</th><th>Tgl. Pemasangan Benur</th><th>Ukuran Benur</th><th>Usia Benur</th><th>Aksi</th></tr></thead>
              <tbody>
                {filtered.map((d, i) => (
                  <tr key={d.id}>
                    <td className="tdMuted">{i + 1}</td>
                    <td style={{ fontWeight: 600 }}>{d.kolam?.nama_kolam || "-"}</td>
                    <td>{d.tanggal_pemasangan_benor}</td>
                    <td><span className="tableBadge admin">{d.ukuran_benor}</span></td>
                    <td>
                      <span className="tableBadge active">
                        {d.usia_benur ?? "?"} hari
                      </span>
                    </td>
                    <td>
                      <div className="tableActions">
                        <button className="btnDetail" onClick={() => setLogModal(d.kolam_id)} style={{ background: "transparent", color: "var(--dash-accent)", border: "1px solid var(--dash-accent)", padding: "4px 8px", borderRadius: "4px", cursor: "pointer", display: "flex", alignItems: "center", fontSize: "12px", fontWeight: "600", marginRight: "8px" }}>
                          <FaClipboardList style={{ marginRight: 4 }} /> Catat Log
                        </button>
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

      {modal && <ProduksiModal mode={modal.mode} data={modal.data} kolams={kolams} onClose={() => setModal(null)} onSaved={(msg, type) => { showToast(msg, type); fetchData(); }} />}
      {logModal && <LogHarianModal kolam_id={logModal} onClose={() => setLogModal(null)} onSaved={(msg, type) => { showToast(msg, type); fetchData(); }} />}
      {confirmDelete && <ConfirmDelete item={confirmDelete} label={`${confirmDelete.ukuran_benor} - ${confirmDelete.kolam?.nama_kolam}`} onCancel={() => setConfirmDelete(null)} onConfirm={handleDelete} />}
      {toast && <Toast message={toast.message} type={toast.type} onHide={() => setToast(null)} />}
    </DashboardLayout>
  );
}
