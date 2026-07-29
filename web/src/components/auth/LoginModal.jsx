import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import gsap from "gsap";
import apiClient from "../../core/network/apiClient";
import { FaEye, FaEyeSlash, FaTint, FaWifi, FaBell, FaChartLine } from "react-icons/fa";
import { toast } from "../../core/utils/toast";

export default function LoginModal({ onClose }) {
  const navigate = useNavigate();
  const overlayRef = useRef(null);
  const modalRef = useRef(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    gsap.fromTo(
      overlayRef.current,
      { opacity: 0 },
      { opacity: 1, duration: 0.3, ease: "power2.out" }
    );
    gsap.fromTo(
      modalRef.current,
      { scale: 0.94, opacity: 0, y: 24 },
      { scale: 1, opacity: 1, y: 0, duration: 0.45, ease: "power3.out", delay: 0.08 }
    );
  }, []);

  const handleClose = () => {
    gsap.to(modalRef.current, { scale: 0.96, opacity: 0, y: 12, duration: 0.2, ease: "power2.in" });
    gsap.to(overlayRef.current, {
      opacity: 0,
      duration: 0.25,
      delay: 0.05,
      onComplete: onClose,
    });
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const response = await apiClient.post("/auth/login", { email, password });
      if (response.status === 200) {
        localStorage.setItem("token", response.data.access_token || response.data.token);
        navigate("/admin/dashboard");
      }
    } catch (err) {
      if (err.response && err.response.status === 401) {
        toast.error("Login gagal: Email atau password salah.");
      }
    } finally {
      setLoading(false);
    }
  };

  const features = [
    "Monitoring sensor IoT real-time",
    "Manajemen kolam & siklus produksi",
    "Notifikasi otomatis anomali air",
    "Laporan panen & analitik data",
  ];

  return (
    <div className="modalOverlay" ref={overlayRef} onClick={handleClose}>
      <div className="modal" ref={modalRef} onClick={(e) => e.stopPropagation()}>

        {/* ── Left Visual Panel ── */}
        <div className="modalVisual">
          <div className="modalBrand">
            <img src="/favicon.png" alt="Aquaculture Logo" />
            <span className="modalBrandText">
              Aqui<span className="modalBrandAccent">Tech</span>
            </span>
          </div>

          <div className="modalVisualContent">
            <p className="modalVisualTitle">
              Pantau Tambak Anda<br />
              <span>Secara Real-time</span>
            </p>
            <p className="modalVisualDesc">
              Platform IoT terpadu untuk monitoring kualitas air, manajemen produksi, dan analitik hasil panen tambak udang modern.
            </p>
            <ul className="modalVisualFeatures">
              {features.map((f, i) => (
                <li key={i}>{f}</li>
              ))}
            </ul>
          </div>

          <div style={{ fontSize: "12px", color: "rgba(255,255,255,0.25)", position: "relative", zIndex: 1 }}>
            © 2025 Tambak Udang Sampang
          </div>
        </div>

        {/* ── Right Form Panel ── */}
        <div className="modalForm">
          <button className="closeBtn" onClick={handleClose} aria-label="Close">
            &times;
          </button>

          <div className="modalFormHeader">
            <h2>Selamat Datang</h2>
            <p>Masuk ke dashboard admin Anda</p>
          </div>

          <form onSubmit={handleLogin}>
            <div className="formGroup">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                autoComplete="email"
              />
            </div>

            <div className="formGroup" style={{ position: "relative" }}>
              <label htmlFor="password">Password</label>
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Masukkan password"
                required
                style={{ paddingRight: "48px" }}
                autoComplete="current-password"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? "Sembunyikan password" : "Tampilkan password"}
                style={{
                  position: "absolute",
                  right: "14px",
                  top: "36px",
                  background: "none",
                  border: "none",
                  color: "#86868b",
                  cursor: "pointer",
                  padding: "4px",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: "16px",
                  transition: "color 0.2s",
                }}
              >
                {showPassword ? <FaEyeSlash /> : <FaEye />}
              </button>
            </div>

            <button className="loginBtn" type="submit" disabled={loading}>
              {loading ? "Memproses..." : "Sign In →"}
            </button>
          </form>
        </div>

      </div>
    </div>
  );
}
