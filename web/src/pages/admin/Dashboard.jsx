import "../../styles/admin.css";
import {
  FaTachometerAlt,
  FaMicrochip,
  FaUsers,
  FaBroadcastTower,
  FaTint,
  FaThermometerHalf,
  FaBell,
  FaWater,
  FaWind,
  FaClipboardList,
  FaBoxes,
  FaSignOutAlt,
} from "react-icons/fa";

export default function Dashboard() {
  const handleLogout = () => {
    localStorage.removeItem("token");
    window.location.href = "/";
  };

  return (
    <div className="adminPage">
      <aside className="sidebar">
        <div className="sidebarBrand">
          <h2>AquaTech</h2>
          <p>Monitoring System</p>
        </div>

        <nav className="sidebarNav">
          <a href="#" className="active"><FaTachometerAlt /> Dashboard</a>
          <a href="#"><FaBroadcastTower /> Monitoring</a>
          <a href="#"><FaMicrochip /> Devices</a>
          <a href="#"><FaClipboardList /> Manajemen Tambak</a>
          <a href="#"><FaBoxes /> Manajemen Produksi</a>
          <a href="#"><FaUsers /> Users</a>
        </nav>

        <button className="logoutBtn" onClick={handleLogout}>
          <FaSignOutAlt /> Logout
        </button>
      </aside>

      <main className="adminContent">
        <div className="adminHeader">
          <div>
            <h1>Dashboard Monitoring Tambak</h1>
            <p>Pantau kualitas air dan kondisi perangkat secara real-time.</p>
          </div>

          <div className="adminUser">
            <div className="userAvatar">A</div>
            <div>
              <strong>Admin</strong>
              <p>Super Admin</p>
            </div>
          </div>
        </div>

        <section className="adminCards">
          <div className="adminCard statCard">
            <div className="statIcon"><FaTint /></div>
            <div>
              <h3>pH</h3>
              <p>7.2</p>
              <span>Status normal</span>
            </div>
          </div>

          <div className="adminCard statCard">
            <div className="statIcon"><FaWater /></div>
            <div>
              <h3>TDS</h3>
              <p>920 ppm</p>
              <span>Stabil</span>
            </div>
          </div>

          <div className="adminCard statCard">
            <div className="statIcon"><FaWind /></div>
            <div>
              <h3>DO</h3>
              <p>6.1 mg/L</p>
              <span>Aman</span>
            </div>
          </div>

          <div className="adminCard statCard">
            <div className="statIcon"><FaThermometerHalf /></div>
            <div>
              <h3>Suhu</h3>
              <p>29°C</p>
              <span>Optimal</span>
            </div>
          </div>
        </section>

        <section className="adminGrid">
          <div className="adminPanel">
            <h2>Ringkasan Monitoring</h2>
            <ul className="summaryList">
              <li><FaBroadcastTower /> 2 Node sensor aktif</li>
              <li><FaMicrochip /> 1 Gateway LoRaWAN online</li>
              <li><FaBell /> Tidak ada alert kritis</li>
              <li><FaUsers /> 2 pengguna aktif</li>
            </ul>
          </div>

          <div className="adminPanel">
            <h2>Status Sistem</h2>
            <div className="statusBoxWrap">
              <div className="statusBox ok">
                <strong>Online</strong>
                <span>Gateway terhubung</span>
              </div>
              <div className="statusBox warning">
                <strong>Warning</strong>
                <span>Perlu cek kalibrasi sensor TDS</span>
              </div>
            </div>
          </div>
        </section>

        <section className="adminGrid">
          <div className="adminPanel">
            <h2>Manajemen Tambak</h2>
            <ul className="summaryList">
              <li><FaClipboardList /> Jadwal pengecekan kolam</li>
              <li><FaClipboardList /> Aktivitas operasional harian</li>
              <li><FaClipboardList /> Catatan perawatan perangkat</li>
            </ul>
          </div>

          <div className="adminPanel">
            <h2>Manajemen Produksi</h2>
            <ul className="summaryList">
              <li><FaBoxes /> Data tebar benur / bibit</li>
              <li><FaBoxes /> Pencatatan pakan dan kebutuhan produksi</li>
              <li><FaBoxes /> Data panen dan hasil produksi</li>
            </ul>
          </div>
        </section>
      </main>
    </div>
  );
}