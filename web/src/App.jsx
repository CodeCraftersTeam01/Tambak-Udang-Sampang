import { useState, useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import LandingPage from "./pages/LandingPage";
import Dashboard from "./pages/admin/Dashboard";
import KolamPage from "./pages/admin/KolamPage";
import UsersPage from "./pages/admin/UsersPage";
import ProduksiPage from "./pages/admin/ProduksiPage";
import PanenPage from "./pages/admin/PanenPage";
import PakanPage from "./pages/admin/PakanPage";
import Monitoring from "./pages/admin/Monitoring";
import Devices from "./pages/admin/Devices";
import ThresholdPage from "./pages/admin/ThresholdPage";
import ProfilePage from "./pages/admin/ProfilePage";
import ToastContainer from "./components/common/ToastContainer";

function ProtectedRoute({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem("token"));
  const [loading, setLoading] = useState(!token);

  useEffect(() => {
    if (token) return;

    const isWebView = navigator.userAgent.includes("TambakAppWebView");
    if (!isWebView) {
      setLoading(false);
      return;
    }

    // Check for token injection periodically (max 1s, checking every 50ms)
    let checks = 0;
    const interval = setInterval(() => {
      const storedToken = localStorage.getItem("token");
      checks++;
      if (storedToken) {
        setToken(storedToken);
        setLoading(false);
        clearInterval(interval);
      } else if (checks >= 20) {
        setLoading(false);
        clearInterval(interval);
      }
    }, 50);

    return () => clearInterval(interval);
  }, [token]);

  if (loading) {
    return (
      <div style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        height: "100vh",
        background: "#0B1326",
        color: "#fff"
      }}>
        <div style={{
          border: "4px solid rgba(255, 255, 255, 0.1)",
          borderTop: "4px solid #38bdf8",
          borderRadius: "50%",
          width: "40px",
          height: "40px",
          animation: "spin 1s linear infinite"
        }} />
        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  if (!token) return <Navigate to="/" replace />;
  return children;
}

import { Toaster } from "react-hot-toast";

export default function App() {
  return (
    <BrowserRouter>
      <Toaster position="top-right" toastOptions={{ className: 'dark:bg-gray-800 dark:text-white' }} />
      <ToastContainer />
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/admin/dashboard"  element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        <Route path="/admin/kolam"      element={<ProtectedRoute><KolamPage /></ProtectedRoute>} />
        <Route path="/admin/users"      element={<ProtectedRoute><UsersPage /></ProtectedRoute>} />
        <Route path="/admin/produksi"   element={<ProtectedRoute><ProduksiPage /></ProtectedRoute>} />
        <Route path="/admin/sampling"   element={<ProtectedRoute><ProduksiPage /></ProtectedRoute>} />
        <Route path="/admin/panen"      element={<ProtectedRoute><PanenPage /></ProtectedRoute>} />
        <Route path="/admin/pakan"      element={<ProtectedRoute><PakanPage /></ProtectedRoute>} />
        <Route path="/admin/monitoring" element={<ProtectedRoute><Monitoring /></ProtectedRoute>} />
        <Route path="/admin/devices"    element={<ProtectedRoute><Devices /></ProtectedRoute>} />
        <Route path="/admin/thresholds" element={<ProtectedRoute><ThresholdPage /></ProtectedRoute>} />
        <Route path="/admin/profile"    element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
        <Route path="/login"            element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}