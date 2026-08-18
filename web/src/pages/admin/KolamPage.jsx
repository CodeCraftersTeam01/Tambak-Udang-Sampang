import { useState, useEffect, useCallback } from "react";
import { FaPlus, FaWater, FaEdit, FaTrash, FaMapMarkerAlt, FaEye } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import KolamDetailModal from "../../components/admin/KolamDetailModal";
import apiClient from "../../core/network/apiClient";
import { toast } from "react-hot-toast";
import { MapContainer, TileLayer, Marker, useMapEvents } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import icon from "leaflet/dist/images/marker-icon.png";
import iconShadow from "leaflet/dist/images/marker-shadow.png";

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = DefaultIcon;

function ChangeMapState({ center, onClick }) {
  const map = useMapEvents({
    click(e) {
      onClick(e.latlng.lat, e.latlng.lng);
    },
  });
  useEffect(() => {
    if (center && center[0] && center[1]) {
      map.setView(center, map.getZoom());
    }
  }, [center, map]);
  return null;
}

const emptyForm = {
  pemilik: "1",
  nama_kolam: "",
  lat: "",
  long: "",
  status: "aktif",
  id_mqtt: "",
  luas: "",
  detail_udang: "",
  kincir: "0",
  relays: []
};

function KolamModal({ mode, data, onClose, onSaved }) {
  const [form, setForm] = useState(() => {
    if (data) {
      return {
        ...emptyForm,
        ...data,
        id_mqtt: data.mqtt_id || "",
        luas: data.luas_kolam || "",
        kincir: data.relays ? data.relays.length.toString() : "0",
        relays: data.relays ? data.relays.map((r) => r.nama_relay) : []
      };
    }
    return emptyForm;
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (mode === "add" && !form.lat && !form.long) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          setForm((prev) => ({
            ...prev,
            lat: pos.coords.latitude.toFixed(7),
            long: pos.coords.longitude.toFixed(7)
          }));
        },
        (err) => {
          console.warn("Geolocation blocked/failed. Defaulting to Sampang.", err);
          setForm((prev) => ({
            ...prev,
            lat: "-7.1884",
            long: "113.2435"
          }));
        }
      );
    }
  }, [mode]);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleKincirChange = (e) => {
    const value = e.target.value;
    const numRelays = parseInt(value, 10) || 0;
    const newRelays = Array.from({ length: numRelays }, (_, idx) => {
      return form.relays[idx] || `Kincir ${idx + 1}`;
    });
    setForm((prev) => ({
      ...prev,
      kincir: value,
      relays: newRelays
    }));
  };

  const handleRelayNameChange = (index, value) => {
    const updatedRelays = [...form.relays];
    updatedRelays[index] = value;
    setForm((prev) => ({
      ...prev,
      relays: updatedRelays
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = { 
        ...form, 
        luas: Number(form.luas),
        status: form.status
      };
      if (mode === "edit") {
        await apiClient.put(`/ponds/${form.id}`, payload);
        onSaved("Kolam berhasil diperbarui!", "success");
      } else {
        await apiClient.post(`/ponds`, payload);
        onSaved("Kolam berhasil ditambahkan!", "success");
      }
      onClose();
    } catch {
      onSaved("Terjadi kesalahan.", "error");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="dashModalOverlay" onClick={onClose}>
      <div className="dashModal max-h-[85vh] overflow-y-auto" style={{ maxHeight: "85vh", overflowY: "auto" }} onClick={(e) => e.stopPropagation()}>
        <div className="dashModalHeader">
          <h3 className="dashModalTitle">{mode === "edit" ? "Edit Kolam" : "Tambah Kolam"}</h3>
          <button className="dashModalClose" onClick={onClose}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dashFormGroup" style={{ marginBottom: "16px" }}>
            <label>Nama Kolam</label>
            <input name="nama_kolam" value={form.nama_kolam} onChange={handleChange} placeholder="Kolam A" required />
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>ID MQTT</label>
              <input name="id_mqtt" value={form.id_mqtt} onChange={handleChange} placeholder="Contoh: t01" required />
            </div>
            <div className="dashFormGroup">
              <label>Luas (m²)</label>
              <input name="luas" type="number" step="0.1" value={form.luas} onChange={handleChange} placeholder="Contoh: 1000" required />
            </div>
          </div>
          <div className="dashFormRow">
            <div className="dashFormGroup">
              <label>Detail Udang</label>
              <input name="detail_udang" value={form.detail_udang} onChange={handleChange} placeholder="Contoh: Vannamei" required />
            </div>
            <div className="dashFormGroup">
              <label>Jumlah Kincir (Relay)</label>
              <input name="kincir" type="number" min="0" value={form.kincir} onChange={handleKincirChange} placeholder="Contoh: 4" required />
            </div>
          </div>

          {form.relays.length > 0 && (
            <div className="dashFormGroup" style={{ marginTop: "12px", marginBottom: "16px" }}>
              <label style={{ fontWeight: "bold", color: "#6cd3f7" }}>Nama-Nama Kincir (Relay)</label>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: "10px", marginTop: "8px" }}>
                {form.relays.map((relayName, index) => (
                  <div key={index} style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
                    <label style={{ fontSize: "12px", color: "#a0aec0" }}>Kincir {index + 1}</label>
                    <input
                      type="text"
                      value={relayName}
                      onChange={(e) => handleRelayNameChange(index, e.target.value)}
                      placeholder={`Nama Kincir ${index + 1}`}
                      required
                      style={{ padding: "8px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                    />
                  </div>
                ))}
              </div>
            </div>
          )}


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

          <div style={{ height: "200px", marginBottom: "16px", borderRadius: "8px", overflow: "hidden", border: "1px solid rgba(255,255,255,0.1)" }}>
            <MapContainer
              center={
                form.lat && form.long
                  ? [Number(form.lat), Number(form.long)]
                  : [-7.1884, 113.2435]
              }
              zoom={13}
              style={{ height: "100%", width: "100%", zIndex: 1 }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <ChangeMapState
                center={
                  form.lat && form.long
                    ? [Number(form.lat), Number(form.long)]
                    : null
                }
                onClick={(lat, lng) => setForm((prev) => ({ ...prev, lat: lat.toFixed(7), long: lng.toFixed(7) }))}
              />
              {form.lat && form.long && (
                <Marker position={[Number(form.lat), Number(form.long)]} />
              )}
            </MapContainer>
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

  const showToast = useCallback((message, type = "success") => {
    if (type === "success") {
      toast.success(message);
    } else {
      toast.error(message);
    }
  }, []);

  const fetchKolam = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/kolam');
      setKolams(res.data.data || []);
    } catch {
      showToast("Gagal memuat data kolam.", "error");
    } finally {
      setLoading(false);
    }
  }, [showToast]);

  useEffect(() => {
    fetchKolam();
    const intervalId = setInterval(fetchKolam, 60000);
    return () => clearInterval(intervalId);
  }, [fetchKolam]);

  const handleDelete = async () => {
    if (!confirmDelete) return;
    try {
      await apiClient.delete(`/kolam/${confirmDelete.id}`);
      showToast("Kolam berhasil dihapus!");
      fetchKolam();
    } catch {
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
    </DashboardLayout>
  );
}
