import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaSeedling, FaEdit, FaTrash } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import API_URL from "../../services/api";

const empty = { tanggal_pemasangan_benor: "", ukuran_benor: "", kolam_id: "" };

function Toast({ message, type, onHide }) {
  useEffect(() => { const t = setTimeout(onHide, 3000); return () => clearTimeout(t); }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
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
      const url = mode === "edit" ? `${API_URL}/api/produksi/${data.id}` : `${API_URL}/api/produksi`;
      const res = await fetch(url, { method: mode === "edit" ? "PUT" : "POST", headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}`, Accept: "application/json" }, body: JSON.stringify(form) });
      if (!res.ok) throw new Error();
      onSaved(mode === "edit" ? "Produksi diperbarui!" : "Produksi ditambahkan!"); onClose();
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
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);
  const token = localStorage.getItem("token");
  const headers = { Authorization: `Bearer ${token}`, Accept: "application/json" };

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const [prodRes, kolamRes] = await Promise.all([
        fetch(`${API_URL}/api/produksi`, { headers }).then((r) => r.json()),
        fetch(`${API_URL}/api/kolam`, { headers }).then((r) => r.json()),
      ]);
      setData(prodRes.data || []);
      setKolams(kolamRes.data || []);
    } catch { showToast("Gagal memuat data.", "error"); } finally { setLoading(false); }
  }, [token]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const showToast = (message, type = "success") => setToast({ message, type });

  const handleDelete = async () => {
    try {
      await fetch(`${API_URL}/api/produksi/${confirmDelete.id}`, { method: "DELETE", headers });
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
      {confirmDelete && <ConfirmDelete item={confirmDelete} label={`${confirmDelete.ukuran_benor} - ${confirmDelete.kolam?.nama_kolam}`} onCancel={() => setConfirmDelete(null)} onConfirm={handleDelete} />}
      {toast && <Toast message={toast.message} type={toast.type} onHide={() => setToast(null)} />}
    </DashboardLayout>
  );
}
