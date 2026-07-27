import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import gsap from "gsap";
import apiClient from "../../core/network/apiClient";
import { FaEye, FaEyeSlash } from "react-icons/fa";

export default function LoginModal({ onClose }) {
  const navigate = useNavigate();
  const overlayRef = useRef(null);
  const modalRef = useRef(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    gsap.fromTo(
      overlayRef.current,
      { opacity: 0 },
      { opacity: 1, duration: 0.3, ease: "power2.out" }
    );
    gsap.fromTo(
      modalRef.current,
      { scale: 0.95, opacity: 0, y: 20 },
      { scale: 1, opacity: 1, y: 0, duration: 0.4, ease: "power3.out", delay: 0.1 }
    );
  }, []);

  const handleClose = () => {
    gsap.to(overlayRef.current, {
      opacity: 0,
      duration: 0.2,
      onComplete: onClose,
    });
  };

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      const response = await apiClient.post("/auth/login", { email, password });
      
      if (response.status === 200) {
        localStorage.setItem("token", response.data.access_token || response.data.token);
        navigate("/admin/dashboard");
      }
    } catch (err) {
      if (err.response && err.response.status === 401) {
        alert("Login gagal: Email atau password salah.");
      }
      // other errors are handled by interceptor
    }
  };

  return (
    <div className="modalOverlay" ref={overlayRef} onClick={handleClose}>
      <div className="modal" ref={modalRef} onClick={(e) => e.stopPropagation()}>
        <button className="closeBtn" onClick={handleClose}>
          &times;
        </button>

        <h2>Welcome Back</h2>
        <p>Sign in to your dashboard</p>

        <form onSubmit={handleLogin}>
          <div className="formGroup">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="your@email.com"
              required
            />
          </div>

          <div className="formGroup" style={{ position: "relative" }}>
            <label>Password</label>
            <input
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
              style={{ paddingRight: "40px" }}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              style={{
                position: "absolute",
                right: "12px",
                top: "38px",
                background: "none",
                border: "none",
                color: "#86868b",
                cursor: "pointer",
                padding: "4px"
              }}
            >
              {showPassword ? <FaEyeSlash /> : <FaEye />}
            </button>
          </div>

          <button className="loginBtn">Sign In</button>
        </form>
      </div>
    </div>
  );
}
