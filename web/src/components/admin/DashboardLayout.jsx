import { useNavigate, useLocation } from "react-router-dom";
import apiClient from "../../core/network/apiClient";
import {
  FaHome,
  FaWater,
  FaUsers,
  FaSignOutAlt,
  FaSeedling,
  FaFish,
  FaBoxes,
} from "react-icons/fa";
import "../../styles/dashboard.css";

const navItems = [
  { path: "/admin/dashboard", label: "Dashboard", icon: <FaHome /> },
  { path: "/admin/kolam",     label: "Kolam",      icon: <FaWater /> },
  { path: "/admin/produksi",  label: "Produksi",   icon: <FaSeedling /> },
  { path: "/admin/panen",     label: "Panen",      icon: <FaFish /> },
  { path: "/admin/pakan",     label: "Pakan",      icon: <FaBoxes /> },
  { path: "/admin/users",     label: "Users",      icon: <FaUsers /> },
];

export default function DashboardLayout({ children, title }) {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    try {
      await apiClient.post("/auth/logout");
    } catch (e) {
      console.error("Logout error", e);
    } finally {
      localStorage.removeItem("token");
      navigate("/");
    }
  };

  const getInitials = () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) return "A";
      const payload = JSON.parse(atob(token.split(".")[1]));
      return (payload?.name || "Admin").charAt(0).toUpperCase();
    } catch {
      return "A";
    }
  };

  return (
    <div className="dashRoot">
      {/* Sidebar */}
      <aside className="dashSidebar">
        <a href="/" className="sidebarLogo">
          <img src="/favicon.png" alt="AquiTech Logo" />
          <span className="sidebarLogoText">
            Aqui<span className="sidebarLogoAccent">Tech</span>
          </span>
        </a>

        <nav className="sidebarNav">
          <span className="sidebarSection">Menu</span>
          {navItems.map((item) => (
            <button
              key={item.path}
              className={`sidebarLink${location.pathname === item.path ? " active" : ""}`}
              onClick={() => navigate(item.path)}
            >
              {item.icon}
              {item.label}
            </button>
          ))}
        </nav>

        <div className="sidebarFooter">
          <button className="sidebarLogout" onClick={handleLogout}>
            <FaSignOutAlt />
            Keluar
          </button>
        </div>
      </aside>

      {/* Main */}
      <div className="dashMain">
        {/* Header */}
        <header className="dashHeader">
          <span className="dashHeaderTitle">{title}</span>
          <div className="dashHeaderRight">
            <div className="dashAvatar">{getInitials()}</div>
          </div>
        </header>

        {/* Content */}
        <main className="dashContent">{children}</main>
      </div>
    </div>
  );
}
