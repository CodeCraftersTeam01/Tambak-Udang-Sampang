import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaWater, FaEdit, FaTrash, FaMapMarkerAlt, FaEye } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import KolamDetailModal from "../../components/admin/KolamDetailModal";
import apiClient from "../../core/network/apiClient";

const emptyForm = { pemilik: "", nama_kolam: "", lat: "", long: "", status: "aktif", target_panen_kg: "" };

function Toast({ message, type, onHide }) {
  useEffect(() => {
    const t = setTimeout(onHide, 3000);
    return () => clearTimeout(t);
  }, [onHide]);
  return <div className={`toast ${type}`}>{message}</div>;
}

function KolamModal({ mode, data, onClose, onSaved }) {
  const [form, setForm] = useState(data || emptyForm);
  const [saving, setSaving] = useState(false);
  const token = localStorage.getItem("token");

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = { ...form, target_panen_kg: Number(form.target_panen_kg) };
      if (mode === "edit") {
        await apiClient.put(`/kolam/${form.id}`, payload);
        onSaved("Kolam berhasil diperbarui!", "success");
      } else {
        await apiClient.post(`/kolam`, payload);
        onSaved("Kolam berhasil ditambahkan!", "success");
      }
      onClose();
    } catch (err) {
      onSaved("Terjadi kesalahan.", "error");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal" onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit Kolam" : "Tambah Kolam"}</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Nama Kolam</label>
              <input name="nama_kolam" value={form.nama_kolam} onChange={handleChange} placeholder="Kolam A" required />
            </div>
            <div className="dashFormGroup">
              <label>Target Panen (kg)</label>
              <input name="target_panen_kg" type="number" step="0.01" value={form.target_panen_kg} onChange={handleChange} placeholder="0.00" required />
            </div>
          </div>
          <div className="dashFormGroup">
            <label>Pemilik</label>
            <input name="pemilik" value={form.pemilik} onChange={handleChange} placeholder="Nama pemilik" required />
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Latitude</label>
              <input name="lat" value={form.lat} onChange={handleChange} placeholder="-7.123" required />
            </div>
            <div className="dashFormGroup">
              <label>Longitude</label>
              <input name="long" value={form.long} onChange={handleChange} placeholder="112.456" required />
            </div>
          </div>
          <div className="dashFormGroup">
            <label>Status</label>
            <select name="status" value={form.status} onChange={handleChange}>
              <option value="aktif">Aktif</option>
              <option value="non-aktif">Non-Aktif</option>
            </select>
          </div>
          <div className="dashFormActions">
            <button type="button" className="btnCancel" onClick={onClose}>Batal</button>
            <button type="submit" className="btnSubmit" disabled={saving}>
              {saving ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function ConfirmDelete({ kolam, onCancel, onConfirm }) {
  return (
    <div className="dashModalOverlay" onClick={onCancel}>
      <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
        <div className="confirmIcon">🗑️</div>
        <h3 className="confirmTitle">Hapus Kolam?</h3>
        <p className="confirmDesc">
          Kolam <strong>&ldquo;{kolam.nama_kolam}&rdquo;</strong> akan dihapus secara permanen dan tidak dapat dikembalikan.
        </p>
        <div className="confirmActions">
          <button className="btnCancel" onClick={onCancel}>Batal</button>
          <button className="btnDanger" onClick={onConfirm}>Ya, Hapus</button>
        </div>
      </div>
    </div>
  );
}

export default function KolamPage() {
  const [kolams, setKolams] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null); // { mode: "add"|"edit", data: {} }
  const [detailModal, setDetailModal] = useState(null); // stores kolam object
  const [confirmDelete, setConfirmDelete] = useState(null);
  const [toast, setToast] = useState(null);
  const token = localStorage.getItem("token");

  const fetchKolam = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/kolam');
      setKolams(res.data.data || []);
    } catch (err) {
      showToast("Gagal memuat data kolam.", "error");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchKolam(); }, [fetchKolam]);

  const showToast = (message, type = "success") => {
    setToast({ message, type });
  };

  const handleDelete = async () => {
    if (!confirmDelete) return;
    try {
      await apiClient.delete(`/kolam/${confirmDelete.id}`);
      showToast("Kolam berhasil dihapus!");
      fetchKolam();
    } catch (err) {
      showToast("Gagal menghapus kolam.", "error");
    } finally {
      setConfirmDelete(null);
    }
  };

  const filtered = kolams.filter(
    (k) =>
      k.nama_kolam?.toLowerCase().includes(search.toLowerCase()) ||
      k.pemilik?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <DashboardLayout title="Manajemen Kolam">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Manajemen Kolam</h1>
          <p className="dashPageSubtitle">{kolams.length} kolam terdaftar dalam sistem</p>
        </div>
        <button className="btnPrimary" onClick={() => setModal({ mode: "add", data: null })}>
          <FaPlus /> Tambah Kolam
        </button>
      </div>

      <div className="tableCard">
        <div className="tableCardHeader">
          <span className="tableCardTitle">Daftar Kolam</span>
          <input
            className="tableSearch"
            placeholder="Cari nama atau pemilik..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="tableWrapper">
          {loading ? (
            <div className="loadingSpinner">Memuat data...</div>
          ) : filtered.length === 0 ? (
            <div className="emptyState">
              <FaWater />
              <p>Belum ada data kolam.</p>
            </div>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Nama Kolam</th>
                  <th>Pemilik</th>
                  <th>Koordinat</th>
                  <th>Status</th>
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((k, i) => (
                  <tr key={k.id}>
                    <td className="tdMuted">{i + 1}</td>
                    <td style={{ fontWeight: 600 }}>{k.nama_kolam}</td>
                    <td>{k.pemilik}</td>
                    <td>
                      <span className="tdMuted" style={{ display: "flex", alignItems: "center", gap: 6 }}>
                        <FaMapMarkerAlt style={{ color: "var(--dash-accent)", fontSize: 12 }} />
                        {k.lat}, {k.long}
                      </span>
                    </td>
                    <td>
                      <span className={`tableBadge ${k.status === "aktif" ? "active" : "inactive"}`}>
                        {k.status}
                      </span>
                    </td>
                    <td>
                      <div className="tableActions">
                        <button className="btnDetail" onClick={() => setDetailModal(k)} style={{ background: "transparent", color: "var(--dash-accent)", border: "1px solid var(--dash-accent)", padding: "4px 8px", borderRadius: "4px", cursor: "pointer", display: "flex", alignItems: "center", fontSize: "12px", fontWeight: "600" }}>
                          <FaEye style={{ marginRight: 4 }} /> Detail
                        </button>
                        <button className="btnEdit" onClick={() => setModal({ mode: "edit", data: k })}>
                          <FaEdit style={{ marginRight: 4 }} /> Edit
                        </button>
                        <button className="btnDelete" onClick={() => setConfirmDelete(k)}>
                          <FaTrash style={{ marginRight: 4 }} /> Hapus
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {modal && (
        <KolamModal
          mode={modal.mode}
          data={modal.data}
          onClose={() => setModal(null)}
          onSaved={(msg, type) => { showToast(msg, type); fetchKolam(); }}
        />
      )}

      {confirmDelete && (
        <ConfirmDelete
          kolam={confirmDelete}
          onCancel={() => setConfirmDelete(null)}
          onConfirm={handleDelete}
        />
      )}

      {/* MUI Detail Modal with Map */}
      <KolamDetailModal 
        open={!!detailModal} 
        kolam={detailModal} 
        onClose={() => setDetailModal(null)} 
      />

      {toast && (
        <Toast message={toast.message} type={toast.type} onHide={() => setToast(null)} />
      )}
    </DashboardLayout>
  );
}
