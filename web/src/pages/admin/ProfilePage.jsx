import { useState, useEffect } from "react";
import { FaUser, FaLock, FaEnvelope, FaPhone, FaMapMarkerAlt, FaBell } from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";
import { toast } from "react-hot-toast";

export default function ProfilePage() {
  const [profileForm, setProfileForm] = useState({
    name: "",
    email: "",
    nomor_hp: "",
    alamat: "",
  });

  const [passwordForm, setPasswordForm] = useState({
    current_password: "",
    new_password: "",
    new_password_confirmation: "",
  });

  const [alertsEnabled, setAlertsEnabled] = useState(true);
  const [roleName, setRoleName] = useState("");
  const [loading, setLoading] = useState(true);
  
  const [savingProfile, setSavingProfile] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);

  useEffect(() => {
    apiClient.get("/profile")
      .then((res) => {
        const u = res.data.data;
        setProfileForm({
          name: u.name || "",
          email: u.email || "",
          nomor_hp: u.nomor_hp || "",
          alamat: u.alamat || "",
        });
        setRoleName(u.role?.name || "petambak");
        setAlertsEnabled(u.alerts_enabled === true || u.alerts_enabled === 1);
        setLoading(false);
      })
      .catch(() => {
        toast.error("Gagal memuat profil");
        setLoading(false);
      });
  }, []);

  const handleProfileChange = (e) => {
    setProfileForm({ ...profileForm, [e.target.name]: e.target.value });
  };

  const handlePasswordChange = (e) => {
    setPasswordForm({ ...passwordForm, [e.target.name]: e.target.value });
  };

  const handleProfileSubmit = async (e) => {
    e.preventDefault();
    setSavingProfile(true);
    try {
      const res = await apiClient.put("/profile", profileForm);
      const updatedUser = res.data.data;
      setProfileForm({
        name: updatedUser.name || "",
        email: updatedUser.email || "",
        nomor_hp: updatedUser.nomor_hp || "",
        alamat: updatedUser.alamat || "",
      });
      toast.success("Profil berhasil diperbarui!");
    } catch (err) {
      const msg = err.response?.data?.message || "Gagal memperbarui profil";
      toast.error(msg);
    } finally {
      setSavingProfile(false);
    }
  };

  const handlePasswordSubmit = async (e) => {
    e.preventDefault();
    setSavingPassword(true);
    try {
      await apiClient.put("/profile/change-password", passwordForm);
      setPasswordForm({
        current_password: "",
        new_password: "",
        new_password_confirmation: "",
      });
      toast.success("Password berhasil diperbarui!");
    } catch (err) {
      const msg = err.response?.data?.message || "Gagal memperbarui password";
      toast.error(msg);
    } finally {
      setSavingPassword(false);
    }
  };

  const handleAlertsToggle = async () => {
    const originalValue = alertsEnabled;
    setAlertsEnabled(!originalValue);
    try {
      const res = await apiClient.post("/profile/toggle-alerts");
      const returnedValue = res.data.data.alerts_enabled;
      setAlertsEnabled(returnedValue);
      toast.success(res.data.message || "Pengaturan notifikasi berhasil diperbarui");
    } catch (err) {
      setAlertsEnabled(originalValue);
      toast.error("Gagal memperbarui pengaturan notifikasi");
    }
  };

  return (
    <DashboardLayout title="Pengaturan">
      <div className="dashPageHeader">
        <div>
          <h1 className="dashPageTitle">Pengaturan</h1>
          <p className="dashPageSubtitle">Kelola detail akun, preferensi notifikasi, dan keamanan Anda</p>
        </div>
      </div>

      <div style={{ maxWidth: "700px", margin: "0 auto", display: "flex", flexDirection: "column", gap: "24px", paddingBottom: "40px" }}>
        {loading ? (
          <div className="tableCard" style={{ padding: "24px", textAlign: "center" }}>
            <div className="loadingSpinner">Memuat data...</div>
          </div>
        ) : (
          <>
            {/* SECTION 1: EDIT PROFILE */}
            <div className="tableCard" style={{ padding: "24px" }}>
              <h2 style={{ fontSize: "16px", color: "var(--dash-accent, #6cd3f7)", fontWeight: "bold", marginBottom: "16px", display: "flex", alignItems: "center", gap: "8px" }}>
                <FaUser /> Informasi Profil
              </h2>
              <form onSubmit={handleProfileSubmit} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                <div style={{ display: "flex", justifyContent: "center", marginBottom: "8px" }}>
                  <div style={{
                    padding: "16px",
                    background: "rgba(255, 255, 255, 0.05)",
                    borderRadius: "50%",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    border: "2px dashed rgba(255, 255, 255, 0.1)"
                  }}>
                    <FaUser size={36} style={{ color: "var(--dash-accent, #6cd3f7)" }} />
                  </div>
                </div>

                <div style={{ textAlign: "center", marginBottom: "12px" }}>
                  <span className="tableBadge active" style={{ textTransform: "uppercase", fontSize: "11px", fontWeight: "bold" }}>
                    {roleName}
                  </span>
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaUser size={10} /> Nama Lengkap
                  </label>
                  <input
                    name="name"
                    value={profileForm.name}
                    onChange={handleProfileChange}
                    placeholder="Nama Lengkap"
                    required
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaEnvelope size={10} /> Email
                  </label>
                  <input
                    name="email"
                    type="email"
                    value={profileForm.email}
                    onChange={handleProfileChange}
                    placeholder="alamat@email.com"
                    required
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaPhone size={10} /> Nomor WhatsApp / HP
                  </label>
                  <input
                    name="nomor_hp"
                    value={profileForm.nomor_hp}
                    onChange={handleProfileChange}
                    placeholder="Contoh: 08123456789"
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaMapMarkerAlt size={10} /> Alamat
                  </label>
                  <textarea
                    name="alamat"
                    value={profileForm.alamat}
                    onChange={handleProfileChange}
                    placeholder="Alamat Lengkap"
                    rows={2}
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff", resize: "none", fontFamily: "inherit" }}
                  />
                </div>

                <div style={{ marginTop: "8px" }}>
                  <button
                    type="submit"
                    className="btnSubmit"
                    disabled={savingProfile}
                    style={{ width: "100%", padding: "10px", fontSize: "13px", fontWeight: "bold" }}
                  >
                    {savingProfile ? "Menyimpan..." : "Simpan Perubahan"}
                  </button>
                </div>
              </form>
            </div>

            {/* SECTION 2: PREFERENSI NOTIFIKASI */}
            <div className="tableCard" style={{ padding: "24px" }}>
              <h2 style={{ fontSize: "16px", color: "var(--dash-accent, #6cd3f7)", fontWeight: "bold", marginBottom: "16px", display: "flex", alignItems: "center", gap: "8px" }}>
                <FaBell /> Preferensi Notifikasi
              </h2>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px", background: "rgba(255,255,255,0.02)", borderRadius: "8px", border: "1px solid rgba(255,255,255,0.05)" }}>
                <div>
                  <h3 style={{ fontSize: "14px", fontWeight: "bold", margin: 0 }}>Notifikasi Peringatan</h3>
                  <p style={{ fontSize: "12px", color: "var(--text-muted, #94a3b8)", margin: "4px 0 0 0" }}>Terima peringatan sensor via push notification</p>
                </div>
                <div>
                  <label className="switch" style={{ position: "relative", display: "inline-block", width: "48px", height: "24px" }}>
                    <input
                      type="checkbox"
                      checked={alertsEnabled}
                      onChange={handleAlertsToggle}
                      style={{ opacity: 0, width: 0, height: 0 }}
                    />
                    <span className="slider round" style={{
                      position: "absolute",
                      cursor: "pointer",
                      top: 0, left: 0, right: 0, bottom: 0,
                      backgroundColor: alertsEnabled ? "var(--dash-accent, #6cd3f7)" : "rgba(255,255,255,0.1)",
                      transition: "0.3s",
                      borderRadius: "24px"
                    }}>
                      <span style={{
                        position: "absolute",
                        content: "",
                        height: "18px", width: "18px",
                        left: alertsEnabled ? "26px" : "3px",
                        bottom: "3px",
                        backgroundColor: "#fff",
                        transition: "0.3s",
                        borderRadius: "50%"
                      }} />
                    </span>
                  </label>
                </div>
              </div>
            </div>

            {/* SECTION 3: UBAH PASSWORD */}
            <div className="tableCard" style={{ padding: "24px" }}>
              <h2 style={{ fontSize: "16px", color: "var(--dash-accent, #6cd3f7)", fontWeight: "bold", marginBottom: "16px", display: "flex", alignItems: "center", gap: "8px" }}>
                <FaLock /> Ubah Password
              </h2>
              <form onSubmit={handlePasswordSubmit} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaLock size={10} /> Password Lama
                  </label>
                  <input
                    name="current_password"
                    type="password"
                    value={passwordForm.current_password}
                    onChange={handlePasswordChange}
                    placeholder="Password saat ini"
                    required
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaLock size={10} /> Password Baru
                  </label>
                  <input
                    name="new_password"
                    type="password"
                    value={passwordForm.new_password}
                    onChange={handlePasswordChange}
                    placeholder="Password baru (minimal 6 karakter)"
                    required
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div className="dashFormGroup">
                  <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px" }}>
                    <FaLock size={10} /> Konfirmasi Password Baru
                  </label>
                  <input
                    name="new_password_confirmation"
                    type="password"
                    value={passwordForm.new_password_confirmation}
                    onChange={handlePasswordChange}
                    placeholder="Ketik ulang password baru"
                    required
                    style={{ padding: "10px 12px", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: "6px", color: "#fff" }}
                  />
                </div>

                <div style={{ marginTop: "8px" }}>
                  <button
                    type="submit"
                    className="btnSubmit"
                    disabled={savingPassword}
                    style={{ width: "100%", padding: "10px", fontSize: "13px", fontWeight: "bold" }}
                  >
                    {savingPassword ? "Memperbarui..." : "Ubah Password"}
                  </button>
                </div>
              </form>
            </div>
          </>
        )}
      </div>
    </DashboardLayout>
  );
}
