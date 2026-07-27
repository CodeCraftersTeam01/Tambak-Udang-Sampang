import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function LoginModal({ onClose }) {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/login`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            email,
            password,
          }),
        }
      );

      const data = await response.json();

      if (response.ok) {
        localStorage.setItem("token", data.token);

        navigate("/admin/dashboard");
      } else {
        alert("Login gagal");
      }
    } catch (err) {
      alert("Server error");
    }
  };

  return (
    <div className="modalOverlay">
      <div className="modal">
        <button className="closeBtn" onClick={onClose}>
          ×
        </button>

        <h2>Login Dashboard</h2>

        <form onSubmit={handleLogin}>
          <div className="formGroup">
            <label>Email</label>

            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="formGroup">
            <label>Password</label>

            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <button className="btn loginBtn">
            Login
          </button>
        </form>
      </div>
    </div>
  );
}
