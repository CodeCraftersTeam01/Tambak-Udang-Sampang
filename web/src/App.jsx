import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import LandingPage from "./pages/LandingPage";
import Dashboard from "./pages/admin/Dashboard";
import KolamPage from "./pages/admin/KolamPage";
import UsersPage from "./pages/admin/UsersPage";
import ProduksiPage from "./pages/admin/ProduksiPage";
import PanenPage from "./pages/admin/PanenPage";
import PakanPage from "./pages/admin/PakanPage";

function ProtectedRoute({ children }) {
  const token = localStorage.getItem("token");
  if (!token) return <Navigate to="/" replace />;
  return children;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/admin/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        <Route path="/admin/kolam"     element={<ProtectedRoute><KolamPage /></ProtectedRoute>} />
        <Route path="/admin/users"     element={<ProtectedRoute><UsersPage /></ProtectedRoute>} />
        <Route path="/admin/produksi"  element={<ProtectedRoute><ProduksiPage /></ProtectedRoute>} />
        <Route path="/admin/panen"     element={<ProtectedRoute><PanenPage /></ProtectedRoute>} />
        <Route path="/admin/pakan"     element={<ProtectedRoute><PakanPage /></ProtectedRoute>} />
      </Routes>
    </BrowserRouter>
  );
}