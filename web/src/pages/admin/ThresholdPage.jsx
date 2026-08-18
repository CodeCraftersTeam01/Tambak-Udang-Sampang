import { useState, useEffect, useCallback, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import {
  FaWater,
  FaPlus,
  FaEdit,
  FaTrash,
  FaPlay,
  FaStop,
  FaCalendarAlt,
  FaSync,
  FaExclamationTriangle,
  FaInfoCircle
} from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";
import { toast } from "react-hot-toast";

const SENSOR_TYPE_LABELS = {
  ph: "pH",
  do: "DO (Dissolved Oxygen)",
  temperature: "Suhu Air",
  tds: "TDS",
  water_level: "Ketinggian Air"
};

export default function ThresholdPage() {
  const [searchParams] = useSearchParams();
  const [ponds, setPonds] = useState([]);
  const [selectedPondId, setSelectedPondId] = useState(() => {
    return Number(searchParams.get("pond_id")) || "";
  });
  const [thresholds, setThresholds] = useState([]);
  const [loading, setLoading] = useState(false);

  // Cycle machine modals
  const [showStartModal, setShowStartModal] = useState(false);
  const [showEndModal, setShowEndModal] = useState(false);
  const [tanggalTebar, setTanggalTebar] = useState(() => {
    const today = new Date();
    return today.toISOString().split("T")[0];
  });

  // Threshold rule CRUD modals
  const [showRuleModal, setShowRuleModal] = useState(false);
  const [ruleModalMode, setRuleModalMode] = useState("add"); // add or edit
  const [currentRule, setCurrentRule] = useState({
    sensor_type: "ph",
    doc_start: 0,
    doc_end: "",
    min_value: "",
    max_value: ""
  });

  const selectedPond = useMemo(() => {
    return ponds.find((p) => Number(p.id) === Number(selectedPondId));
  }, [ponds, selectedPondId]);

  const showToast = (message, type = "success") => {
    if (type === "success") {
      toast.success(message);
    } else {
      toast.error(message);
    }
  };

  const loadPonds = useCallback(async () => {
    try {
      const res = await apiClient.get("/kolam");
      const data = res.data?.data || res.data;
      if (Array.isArray(data) && data.length > 0) {
        setPonds(data);
        if (!selectedPondId) {
          setSelectedPondId(data[0].id);
        }
      }
    } catch {
      showToast("Gagal memuat daftar kolam.", "error");
    }
  }, [selectedPondId]);

  const loadThresholds = useCallback(async (pondId = selectedPondId) => {
    if (!pondId) return;
    setLoading(true);
    try {
      const res = await apiClient.get(`/thresholds?pond_id=${pondId}`);
      const data = res.data?.data || res.data;
      if (Array.isArray(data)) {
        setThresholds(data);
      }
    } catch {
      showToast("Gagal memuat aturan ambang batas.", "error");
    } finally {
      setLoading(false);
    }
  }, [selectedPondId]);

  useEffect(() => {
    loadPonds();
  }, [loadPonds]);

  useEffect(() => {
    if (selectedPondId) {
      loadThresholds(selectedPondId);
    }
  }, [selectedPondId, loadThresholds]);

  // Start cycle API call
  const handleStartCycle = async (e) => {
    e.preventDefault();
    try {
      await apiClient.post(`/ponds/${selectedPondId}/start-cycle`, {
        tanggal_tebar: tanggalTebar
      });
      showToast("Siklus budidaya berhasil dimulai!", "success");
      setShowStartModal(false);
      loadPonds(); // reload list to get updated status_siklus / DOC
    } catch (err) {
      showToast(err.response?.data?.message || "Gagal memulai siklus.", "error");
    }
  };

  // End cycle API call
  const handleEndCycle = async () => {
    try {
      await apiClient.post(`/ponds/${selectedPondId}/end-cycle`);
      showToast("Siklus budidaya berhasil diakhiri.", "success");
      setShowEndModal(false);
      loadPonds();
    } catch (err) {
      showToast(err.response?.data?.message || "Gagal mengakhiri siklus.", "error");
    }
  };

  // Rule Save (Add/Edit) API call
  const handleSaveRule = async (e) => {
    e.preventDefault();
    const payload = {
      pond_id: Number(selectedPondId),
      sensor_type: currentRule.sensor_type,
      doc_start: Number(currentRule.doc_start),
      doc_end: currentRule.doc_end === "" ? null : Number(currentRule.doc_end),
      min_value: currentRule.min_value === "" ? null : Number(currentRule.min_value),
      max_value: currentRule.max_value === "" ? null : Number(currentRule.max_value)
    };

    try {
      if (ruleModalMode === "add") {
        await apiClient.post("/thresholds", payload);
        showToast("Aturan batas berhasil ditambahkan!", "success");
      } else {
        await apiClient.put(`/thresholds/${currentRule.id}`, payload);
        showToast("Aturan batas berhasil diperbarui!", "success");
      }
      setShowRuleModal(false);
      loadThresholds(selectedPondId);
    } catch (err) {
      showToast(err.response?.data?.message || "Gagal menyimpan aturan.", "error");
    }
  };

  // Rule Delete API call
  const handleDeleteRule = async (id) => {
    if (!window.confirm("Apakah Anda yakin ingin menghapus aturan batas parameter ini?")) return;
    try {
      await apiClient.delete(`/thresholds/${id}`);
      showToast("Aturan batas berhasil dihapus.", "success");
      loadThresholds(selectedPondId);
    } catch (err) {
      showToast("Gagal menghapus aturan.", "error");
    }
  };

  const openAddRuleModal = () => {
    setRuleModalMode("add");
    setCurrentRule({
      sensor_type: "ph",
      doc_start: 0,
      doc_end: "",
      min_value: "",
      max_value: ""
    });
    setShowRuleModal(true);
  };

  const openEditRuleModal = (rule) => {
    setRuleModalMode("edit");
    setCurrentRule({
      id: rule.id,
      sensor_type: rule.sensor_type,
      doc_start: rule.doc_start,
      doc_end: rule.doc_end ?? "",
      min_value: rule.min_value ?? "",
      max_value: rule.max_value ?? ""
    });
    setShowRuleModal(true);
  };

  return (
    <DashboardLayout title="Pengaturan Ambang Batas Sensor">

      <div className="dashPageHeader">
        <div>
          <h2 className="dashPageTitle">Batas Parameter & Fase Budidaya</h2>
          <p className="dashPageSubtitle">
            Atur batas peringatan sensor yang berubah dinamis mengikuti umur udang (DOC).
          </p>
        </div>

        <div style={{ display: "flex", gap: "12px", alignItems: "center" }}>
          <select
            value={selectedPondId}
            onChange={(e) => setSelectedPondId(e.target.value)}
            className="pondSelect"
            style={{
              padding: "10px 14px",
              background: "rgba(255, 255, 255, 0.05)",
              border: "1px solid rgba(255, 255, 255, 0.08)",
              borderRadius: "10px",
              color: "#f5f5f7",
              outline: "none",
              cursor: "pointer",
            }}
          >
            {ponds.map((pond) => (
              <option key={pond.id} value={pond.id} style={{ background: "#0c0c12", color: "#f5f5f7" }}>
                {pond.nama_kolam || pond.name}
              </option>
            ))}
          </select>

          <button className="btnPrimary" onClick={openAddRuleModal} disabled={!selectedPondId}>
            <FaPlus /> Tambah Aturan Batas
          </button>
        </div>
      </div>

      {selectedPond && (
        <section className="monitoringMeta" style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "16px", marginBottom: "24px" }}>
          <div className="metaBox" style={{ background: "rgba(255, 255, 255, 0.02)", border: "1px solid rgba(255, 255, 255, 0.06)", padding: "16px", borderRadius: "12px" }}>
            <span style={{ fontSize: "12px", color: "#6e6e80" }}>Kolam</span>
            <strong style={{ fontSize: "18px", color: "#f5f5f7", display: "block", marginTop: "4px" }}>{selectedPond.nama_kolam || selectedPond.name}</strong>
          </div>

          <div className="metaBox" style={{ background: "rgba(255, 255, 255, 0.02)", border: "1px solid rgba(255, 255, 255, 0.06)", padding: "16px", borderRadius: "12px" }}>
            <span style={{ fontSize: "12px", color: "#6e6e80" }}>Status Siklus</span>
            <div style={{ display: "flex", alignItems: "center", gap: "8px", marginTop: "6px" }}>
              <span
                style={{
                  width: "10px",
                  height: "10px",
                  borderRadius: "50%",
                  background: selectedPond.status_siklus === "aktif" ? "#30d158" : "#8e8e93"
                }}
              />
              <strong style={{ fontSize: "16px", color: selectedPond.status_siklus === "aktif" ? "#30d158" : "#8e8e93", textTransform: "capitalize" }}>
                {selectedPond.status_siklus === "aktif" ? "Siklus Aktif" : "Persiapan / Kolam Kosong"}
              </strong>
            </div>
          </div>

          <div className="metaBox" style={{ background: "rgba(255, 255, 255, 0.02)", border: "1px solid rgba(255, 255, 255, 0.06)", padding: "16px", borderRadius: "12px" }}>
            <span style={{ fontSize: "12px", color: "#6e6e80" }}>Day Of Culture (DOC)</span>
            <strong style={{ fontSize: "18px", color: "#f5f5f7", display: "block", marginTop: "4px" }}>
              {selectedPond.status_siklus === "aktif" ? `${selectedPond.doc ?? 0} Hari` : "Tidak Aktif"}
            </strong>
          </div>

          <div className="metaBox" style={{ background: "rgba(255, 255, 255, 0.02)", border: "1px solid rgba(255, 255, 255, 0.06)", padding: "16px", borderRadius: "12px", display: "flex", alignItems: "center", justifyContent: "center" }}>
            {selectedPond.status_siklus === "aktif" ? (
              <button
                onClick={() => setShowEndModal(true)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "10px 18px",
                  borderRadius: "10px",
                  border: "none",
                  background: "#ff453a",
                  color: "#fff",
                  fontWeight: "bold",
                  cursor: "pointer"
                }}
              >
                <FaStop /> Akhiri Siklus Budidaya
              </button>
            ) : (
              <button
                onClick={() => setShowStartModal(true)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "10px 18px",
                  borderRadius: "10px",
                  border: "none",
                  background: "#30d158",
                  color: "#fff",
                  fontWeight: "bold",
                  cursor: "pointer"
                }}
              >
                <FaPlay /> Mulai Siklus Budidaya
              </button>
            )}
          </div>
        </section>
      )}

      {selectedPond && selectedPond.status_siklus !== "aktif" && (
        <div style={{ display: "flex", gap: "12px", padding: "16px", background: "rgba(255, 159, 10, 0.1)", border: "1px solid rgba(255, 159, 10, 0.2)", borderRadius: "12px", color: "#ff9f0a", marginBottom: "24px" }}>
          <FaInfoCircle style={{ fontSize: "20px", flexShrink: 0 }} />
          <span><strong>Informasi:</strong> Siklus budidaya kolam saat ini tidak aktif. Seluruh notifikasi bahaya / peringatan sensor untuk kolam ini akan dinonaktifkan secara otomatis hingga siklus baru dimulai.</span>
        </div>
      )}

      <div className="adminPanel" style={{ marginTop: "12px" }}>
        <h2>Aturan Batas Parameter Sensor Aktif</h2>
        {loading ? (
          <div className="emptyState" style={{ padding: "40px" }}><FaSync className="spinIcon" /> Memuat aturan...</div>
        ) : thresholds.length === 0 ? (
          <div className="emptyState" style={{ padding: "40px 20px" }}>
            <FaExclamationTriangle style={{ color: "#ff9f0a", fontSize: "28px" }} />
            <p style={{ marginTop: "12px", color: "#6e6e80" }}>Belum ada aturan ambang batas dinamis yang diatur untuk kolam ini. Sensor akan menggunakan batas aman default.</p>
          </div>
        ) : (
          <div className="tableWrapper">
            <table className="monitoringTable">
              <thead>
                <tr>
                  <th>Parameter Sensor</th>
                  <th>Mulai DOC</th>
                  <th>Hingga DOC</th>
                  <th>Batas Minimum (Min)</th>
                  <th>Batas Maksimum (Max)</th>
                  <th>Tindakan</th>
                </tr>
              </thead>
              <tbody>
                {thresholds.map((rule) => (
                  <tr key={rule.id}>
                    <td style={{ fontWeight: "600" }}>{SENSOR_TYPE_LABELS[rule.sensor_type] || rule.sensor_type}</td>
                    <td>{rule.doc_start} Hari</td>
                    <td>{rule.doc_end === null ? "Infinity (Hingga Panen)" : `${rule.doc_end} Hari`}</td>
                    <td style={{ color: rule.min_value === null ? "#6e6e80" : "#ff453a", fontWeight: rule.min_value === null ? "normal" : "600" }}>
                      {rule.min_value === null ? "Tidak Dibatasi" : rule.min_value}
                    </td>
                    <td style={{ color: rule.max_value === null ? "#6e6e80" : "#ff453a", fontWeight: rule.max_value === null ? "normal" : "600" }}>
                      {rule.max_value === null ? "Tidak Dibatasi" : rule.max_value}
                    </td>
                    <td>
                      <div style={{ display: "flex", gap: "8px" }}>
                        <button
                          onClick={() => openEditRuleModal(rule)}
                          style={{ background: "none", border: "none", color: "#0a84ff", cursor: "pointer", padding: "6px" }}
                          title="Edit Aturan"
                        >
                          <FaEdit />
                        </button>
                        <button
                          onClick={() => handleDeleteRule(rule.id)}
                          style={{ background: "none", border: "none", color: "#ff453a", cursor: "pointer", padding: "6px" }}
                          title="Hapus Aturan"
                        >
                          <FaTrash />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Start Cycle Modal */}
      {showStartModal && (
        <div className="dashModalOverlay" onClick={() => setShowStartModal(false)}>
          <div className="dashModal" onClick={(e) => e.stopPropagation()}>
            <div className="dashModalHeader">
              <h3 className="dashModalTitle">Mulai Siklus Budidaya</h3>
              <button className="dashModalClose" onClick={() => setShowStartModal(false)}>&times;</button>
            </div>
            <form onSubmit={handleStartCycle}>
              <div className="dashFormGroup">
                <label>Tanggal Tebar Benur</label>
                <input
                  type="date"
                  value={tanggalTebar}
                  onChange={(e) => setTanggalTebar(e.target.value)}
                  required
                  style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                />
              </div>
              <div className="dashFormActions" style={{ marginTop: "24px" }}>
                <button type="button" className="btnCancel" onClick={() => setShowStartModal(false)}>Batal</button>
                <button type="submit" className="btnSubmit" style={{ background: "#30d158" }}>Mulai Sekarang</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* End Cycle Modal */}
      {showEndModal && (
        <div className="dashModalOverlay" onClick={() => setShowEndModal(false)}>
          <div className="confirmDialog" onClick={(e) => e.stopPropagation()}>
            <div className="confirmIcon" style={{ color: "#ff453a" }}>⚠️</div>
            <h3 className="confirmTitle">Akhiri Siklus Budidaya?</h3>
            <p className="confirmDesc">
              Apakah Anda yakin ingin menyelesaikan siklus budidaya pada kolam ini? Pengakhiran siklus akan menonaktifkan alert sensor dan mereset DOC kembali ke persiapan.
            </p>
            <div className="confirmActions" style={{ display: "flex", gap: "12px", justifyContent: "center", marginTop: "24px" }}>
              <button className="btnCancel" onClick={() => setShowEndModal(false)}>Batal</button>
              <button className="btnSubmit" style={{ background: "#ff453a" }} onClick={handleEndCycle}>Akhiri Siklus</button>
            </div>
          </div>
        </div>
      )}

      {/* Rule Add/Edit Modal */}
      {showRuleModal && (
        <div className="dashModalOverlay" onClick={() => setShowRuleModal(false)}>
          <div className="dashModal" onClick={(e) => e.stopPropagation()}>
            <div className="dashModalHeader">
              <h3 className="dashModalTitle">{ruleModalMode === "add" ? "Tambah Aturan Batas" : "Edit Aturan Batas"}</h3>
              <button className="dashModalClose" onClick={() => setShowRuleModal(false)}>&times;</button>
            </div>
            <form onSubmit={handleSaveRule}>
              <div className="dashFormGroup">
                <label>Parameter Sensor</label>
                <select
                  disabled={ruleModalMode === "edit"}
                  value={currentRule.sensor_type}
                  onChange={(e) => setCurrentRule({ ...currentRule, sensor_type: e.target.value })}
                  style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                >
                  <option value="ph" style={{ background: "#0c0c12" }}>pH</option>
                  <option value="do" style={{ background: "#0c0c12" }}>DO (Dissolved Oxygen)</option>
                  <option value="temperature" style={{ background: "#0c0c12" }}>Suhu Air</option>
                  <option value="tds" style={{ background: "#0c0c12" }}>TDS</option>
                  <option value="water_level" style={{ background: "#0c0c12" }}>Ketinggian Air</option>
                </select>
              </div>

              <div className="dashFormRow" style={{ marginTop: "16px" }}>
                <div className="dashFormGroup">
                  <label>Mulai DOC (Hari)</label>
                  <input
                    type="number"
                    min="0"
                    value={currentRule.doc_start}
                    onChange={(e) => setCurrentRule({ ...currentRule, doc_start: e.target.value })}
                    required
                    style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                  />
                </div>
                <div className="dashFormGroup">
                  <label>Hingga DOC (Kosongkan jika Tanpa Batas Akhir)</label>
                  <input
                    type="number"
                    min={currentRule.doc_start}
                    value={currentRule.doc_end}
                    onChange={(e) => setCurrentRule({ ...currentRule, doc_end: e.target.value })}
                    placeholder="Infinity / Sampai Panen"
                    style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                  />
                </div>
              </div>

              <div className="dashFormRow" style={{ marginTop: "16px" }}>
                <div className="dashFormGroup">
                  <label>Nilai Minimum Peringatan (Min)</label>
                  <input
                    type="number"
                    step="0.01"
                    value={currentRule.min_value}
                    onChange={(e) => setCurrentRule({ ...currentRule, min_value: e.target.value })}
                    placeholder="Kosongkan jika tiada batas minimum"
                    style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                  />
                </div>
                <div className="dashFormGroup">
                  <label>Nilai Maksimum Peringatan (Max)</label>
                  <input
                    type="number"
                    step="0.01"
                    value={currentRule.max_value}
                    onChange={(e) => setCurrentRule({ ...currentRule, max_value: e.target.value })}
                    placeholder="Kosongkan jika tiada batas maksimum"
                    style={{ width: "100%", padding: "10px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "8px", color: "#fff" }}
                  />
                </div>
              </div>

              <div className="dashFormActions" style={{ marginTop: "32px" }}>
                <button type="button" className="btnCancel" onClick={() => setShowRuleModal(false)}>Batal</button>
                <button type="submit" className="btnSubmit">Simpan Aturan</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}
