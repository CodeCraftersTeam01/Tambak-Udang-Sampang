import { useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import apiClient from "../../core/network/apiClient";
import { motion } from "framer-motion";
import {
  FaHome,
  FaWater,
  FaUsers,
  FaSignOutAlt,
  FaSeedling,
  FaFish,
  FaBoxes,
  FaBroadcastTower,
  FaMicrochip,
  FaBars,
  FaTimes,
  FaSlidersH,
  FaUser,
} from "react-icons/fa";
import "../../styles/dashboard.css";

const navItems = [
  { path: "/admin/dashboard",  label: "Dashboard",  icon: <FaHome /> },
  { path: "/admin/monitoring", label: "Monitoring", icon: <FaBroadcastTower /> },
  { path: "/admin/devices",    label: "Devices",    icon: <FaMicrochip /> },
  { path: "/admin/kolam",      label: "Kolam",      icon: <FaWater /> },
  { path: "/admin/produksi",   label: "Produksi",   icon: <FaSeedling /> },
  { path: "/admin/panen",      label: "Panen",      icon: <FaFish /> },
  { path: "/admin/pakan",      label: "Pakan",      icon: <FaBoxes /> },
  { path: "/admin/thresholds", label: "Batas Sensor", icon: <FaSlidersH /> },
  { path: "/admin/users",      label: "Users",      icon: <FaUsers /> },
  { path: "/admin/profile",    label: "Profil Saya", icon: <FaUser /> },
];

export default function DashboardLayout({ children, title }) {
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const handleLogout = async () => {
    try {
      await apiClient.post("/auth/logout");
    } catch (e) {
      console.error("Logout error", e);
    } finally {
      localStorage.removeItem("token");
      navigate("/login");
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

  const handleNavClick = (path) => {
    setIsSidebarOpen(false);
    navigate(path);
  };

  return (
    <div className="dashRoot">
      {/* Sidebar Backdrop (mobile) */}
      {isSidebarOpen && (
        <div className="sidebarBackdrop" onClick={() => setIsSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <aside className={`dashSidebar${isSidebarOpen ? " open" : ""}`}>
        <div className="sidebarLogoContainer">
          <a href="/" className="sidebarLogo">
            <img src="/favicon.png" alt="Aquaculture Logo" />
            <span className="sidebarLogoText">
              Aqua<span className="sidebarLogoAccent">culture</span>
            </span>
          </a>
          <button className="sidebarCloseBtn" onClick={() => setIsSidebarOpen(false)} title="Close Sidebar">
            <FaTimes />
          </button>
        </div>

        <nav className="sidebarNav">
          <span className="sidebarSection">Menu</span>
          {navItems.map((item) => (
            <button
              key={item.path}
              className={`sidebarLink${location.pathname === item.path ? " active" : ""}`}
              onClick={() => handleNavClick(item.path)}
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
          <div className="dashHeaderLeft">
            <button className="sidebarToggle" onClick={() => setIsSidebarOpen(true)} title="Toggle Sidebar">
              <FaBars />
            </button>
            <span className="dashHeaderTitle">{title}</span>
          </div>
          <div className="dashHeaderRight">
            <div className="dashAvatar">{getInitials()}</div>
          </div>
        </header>

        {/* Content */}
        <main className="dashContent">
          <motion.div
            key={location.pathname}
            initial={{ opacity: 0, y: 15, filter: "blur(4px)" }}
            animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
            transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
            style={{ width: "100%", height: "100%", display: "flex", flexDirection: "column", flex: 1 }}
          >
            {children}
          </motion.div>
        </main>
      </div>
    </div>
  );
}
