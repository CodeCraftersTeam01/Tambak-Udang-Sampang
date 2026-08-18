import { useEffect, useMemo, useState, useCallback } from "react";
import {
  FaTint,
  FaWater,
  FaWind,
  FaThermometerHalf,
  FaRulerVertical,
  FaSyncAlt,
  FaExclamationTriangle,
  FaCheckCircle,
  FaClock,
} from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";

const fallbackPonds = [
  {
    id: 1,
    nama_kolam: "Kolam 1",
  },
  {
    id: 2,
    nama_kolam: "Kolam 2",
  },
];

const fallbackSensors = [
  {
    code: "ph",
    name: "pH",
    value: 7.2,
    unit: "pH",
    min: 6.5,
    max: 8.5,
    recorded_at: "2026-05-09 14:46:01",
  },
  {
    code: "tds",
    name: "TDS",
    value: 920,
    unit: "ppm",
    min: 500,
    max: 1500,
    recorded_at: "2026-05-09 14:46:01",
  },
  {
    code: "do",
    name: "Dissolved Oxygen",
    value: 6.1,
    unit: "mg/L",
    min: 4,
    max: 8,
    recorded_at: "2026-05-09 14:46:01",
  },
  {
    code: "temperature",
    name: "Suhu Air",
    value: 29,
    unit: "\u00B0C",
    min: 26,
    max: 32,
    recorded_at: "2026-05-09 14:46:01",
  },
  {
    code: "water_level",
    name: "Ketinggian Air",
    value: 120,
    unit: "cm",
    min: 80,
    max: 150,
    recorded_at: "2026-05-09 14:46:01",
  },
];

function getSensorIcon(code) {
  switch (code) {
    case "ph":
      return <FaTint />;
    case "tds":
      return <FaWater />;
    case "do":
      return <FaWind />;
    case "temperature":
      return <FaThermometerHalf />;
    case "water_level":
      return <FaRulerVertical />;
    default:
      return <FaWater />;
  }
}

function getStatus(sensor) {
  const value = Number(sensor.value);
  const min = Number(sensor.min);
  const max = Number(sensor.max);

  if (Number.isNaN(value)) {
    return {
      label: "Error",
      className: "critical",
    };
  }

  if (value < min || value > max) {
    return {
      label: "Critical",
      className: "critical",
    };
  }

  const range = max - min;
  const lowerWarning = min + range * 0.15;
  const upperWarning = max - range * 0.15;

  if (value <= lowerWarning || value >= upperWarning) {
    return {
      label: "Warning",
      className: "warning",
    };
  }

  return {
    label: "Normal",
    className: "normal",
  };
}

function getProgress(sensor) {
  const value = Number(sensor.value);
  const min = Number(sensor.min);
  const max = Number(sensor.max);

  if (Number.isNaN(value) || max <= min) return 0;

  const percent = ((value - min) / (max - min)) * 100;
  return Math.max(0, Math.min(100, percent));
}

function normalizeLatestResponse(payload) {
  if (!payload) return fallbackSensors;

  const data = payload.data?.data || payload.data || payload;

  if (Array.isArray(data)) {
    return data;
  }

  if (Array.isArray(data.sensors)) {
    return data.sensors;
  }

  if (Array.isArray(data.readings)) {
    return data.readings;
  }

  if (Array.isArray(data.latest)) {
    return data.latest;
  }

  return fallbackSensors;
}

function formatDateTime(value) {
  if (!value) return "-";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleString("id-ID", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

export default function Monitoring() {
  const [ponds, setPonds] = useState(fallbackPonds);
  const [selectedPondId, setSelectedPondId] = useState(1);
  const [sensors, setSensors] = useState(fallbackSensors);
  const [relays, setRelays] = useState([]);
  const [loading, setLoading] = useState(false);
  const [apiMode, setApiMode] = useState("sample");
  const [error, setError] = useState("");

  const selectedPond = useMemo(() => {
    return ponds.find((pond) => Number(pond.id) === Number(selectedPondId));
  }, [ponds, selectedPondId]);

  const latestRecordedAt = useMemo(() => {
    if (!sensors.length) return "-";

    return sensors
      .map((sensor) => sensor.recorded_at)
      .filter(Boolean)
      .sort()
      .reverse()[0];
  }, [sensors]);

  const abnormalSensors = useMemo(() => {
    return sensors.filter((sensor) => getStatus(sensor).className !== "normal");
  }, [sensors]);

  const loadPonds = useCallback(async () => {
    try {
      const response = await apiClient.get("/kolam");
      const data = response.data?.data || response.data;

      if (Array.isArray(data) && data.length > 0) {
        setPonds(data);
        setSelectedPondId(data[0].id);
      }
    } catch {
      setPonds(fallbackPonds);
    }
  }, []);

  const loadLatest = useCallback(async (pondId = selectedPondId) => {
    try {
      setLoading(true);
      setError("");

      const response = await apiClient.get(`/monitoring/latest?pond_id=${pondId}`);
      const normalized = normalizeLatestResponse(response);

      setSensors(normalized);
      setApiMode("api");
    } catch (err) {
      setSensors(fallbackSensors);
      setApiMode("sample");
      setError(
         err.response?.data?.message ||
        "API monitoring belum tersedia atau belum mengembalikan format data yang sesuai."
      );
    } finally {
      setLoading(false);
    }
  }, [selectedPondId]);

  const loadRelays = useCallback(async (pondId = selectedPondId) => {
    try {
      const response = await apiClient.get(`/relay/status?pond_id=${pondId}`);
      const data = response.data?.data || response.data;
      if (Array.isArray(data)) {
        setRelays(data);
      } else {
        setRelays([]);
      }
    } catch {
      setRelays([]);
    }
  }, [selectedPondId]);

  useEffect(() => {
    Promise.resolve().then(() => {
      loadPonds();
    });
  }, [loadPonds]);

  useEffect(() => {
    Promise.resolve().then(() => {
      loadLatest(selectedPondId);
      loadRelays(selectedPondId);
    });

    const intervalId = setInterval(() => {
      loadLatest(selectedPondId);
      loadRelays(selectedPondId);
    }, 10000); // refresh every 10 seconds

    return () => clearInterval(intervalId);
  }, [selectedPondId, loadLatest, loadRelays]);

  return (
    <DashboardLayout title="Monitoring Sensor Real-Time">
      <div className="dashPageHeader">
        <div>
          <h2 className="dashPageTitle">Monitoring Sensor</h2>
          <p className="dashPageSubtitle">
            Pantau data pH, TDS, DO, suhu, dan ketinggian air secara berkala.
          </p>
        </div>

        <div className="monitoringActions" style={{ display: "flex", gap: "12px", alignItems: "center" }}>
          <select
            value={selectedPondId}
            onChange={(event) => setSelectedPondId(event.target.value)}
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

          <button
            className="btnPrimary"
            onClick={() => {
              loadLatest(selectedPondId);
              loadRelays(selectedPondId);
            }}
            disabled={loading}
          >
            <FaSyncAlt className={loading ? "spinIcon" : ""} />
            Refresh
          </button>
        </div>
      </div>

      <section className="monitoringMeta">
        <div className="metaBox">
          <span>Kolam aktif</span>
          <strong>{selectedPond?.nama_kolam || selectedPond?.name || "Kolam"}</strong>
        </div>

        <div className="metaBox">
          <span>Sumber data</span>
          <strong>{apiMode === "api" ? "API Lumen" : "Data contoh"}</strong>
        </div>

        <div className="metaBox">
          <span>Update terakhir</span>
          <strong>
            <FaClock style={{ marginRight: "6px" }} /> {formatDateTime(latestRecordedAt)}
          </strong>
        </div>

        <div className="metaBox">
          <span>Status</span>
          <strong className={abnormalSensors.length ? "textWarning" : "textOk"}>
            {abnormalSensors.length ? "Perlu perhatian" : "Normal"}
          </strong>
        </div>
      </section>

      {error && (
        <div className="monitoringAlert">
          <FaExclamationTriangle />
          <span>{error}</span>
        </div>
      )}

      <section className="sensorCards">
        {sensors.map((sensor) => {
          const status = getStatus(sensor);
          const progress = getProgress(sensor);

          return (
            <div
              key={sensor.code || sensor.sensor_code || sensor.id}
              className={`sensorCard ${status.className}`}
            >
              <div className="sensorCardHeader">
                <div className="sensorIcon">{getSensorIcon(sensor.code)}</div>

                <div>
                  <h3>{sensor.name}</h3>
                  <span className={`sensorStatus ${status.className}`}>
                    {status.className === "normal" ? (
                      <FaCheckCircle />
                    ) : (
                      <FaExclamationTriangle />
                    )}
                    {status.label}
                  </span>
                </div>
              </div>

              <div className="sensorValue">
                <strong>{Number(sensor.value).toLocaleString("id-ID")}</strong>
                <span>{sensor.unit}</span>
              </div>

              <div className="sensorRange">
                <span>
                  Batas aman: {sensor.min} - {sensor.max} {sensor.unit}
                </span>
              </div>

              <div className="rangeBar">
                <div
                  className={`rangeFill ${status.className}`}
                  style={{ width: `${progress}%` }}
                />
              </div>

              <div className="sensorTime">
                Update: {formatDateTime(sensor.recorded_at)}
              </div>
            </div>
          );
        })}
      </section>

      <section className="adminGrid">
        <div className="adminPanel">
          <h2>Ringkasan Kondisi Sensor</h2>

          {abnormalSensors.length === 0 ? (
            <div className="emptyState">
              <FaCheckCircle style={{ color: "#30d158" }} />
              <p>Semua parameter berada dalam batas aman.</p>
            </div>
          ) : (
            <ul className="summaryList">
              {abnormalSensors.map((sensor) => {
                const status = getStatus(sensor);

                return (
                  <li key={sensor.code || sensor.id} style={{ display: "flex", gap: "8px", alignItems: "center" }}>
                    <FaExclamationTriangle style={{ color: "#ff9f0a" }} />
                    <span>
                      {sensor.name} bernilai <strong>{sensor.value} {sensor.unit}</strong> - status <strong>{status.label}</strong>
                    </span>
                  </li>
                );
              })}
            </ul>
          )}
        </div>

        <div className="adminPanel">
          <h2>Status Kincir Air (Relay)</h2>
          {relays.length === 0 ? (
            <div className="emptyState" style={{ padding: "20px 0", textAlign: "center", color: "#6e6e80" }}>
              <p>Tidak ada data relay kincir air untuk kolam ini.</p>
            </div>
          ) : (
            <div className="relayListGrid" style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(130px, 1fr))", gap: "12px", marginTop: "12px" }}>
              {relays.map((relay) => (
                <div
                  key={relay.id}
                  style={{
                    padding: "12px",
                    background: "rgba(255, 255, 255, 0.03)",
                    border: "1px solid rgba(255, 255, 255, 0.08)",
                    borderRadius: "10px",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    gap: "6px",
                  }}
                >
                  <span style={{ fontWeight: "600", fontSize: "13px", color: "#6e6e80", textAlign: "center" }}>{relay.nama_relay}</span>
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "6px",
                      padding: "4px 10px",
                      borderRadius: "20px",
                      background: relay.is_on ? "rgba(48, 209, 88, 0.15)" : "rgba(110, 110, 128, 0.15)",
                      color: relay.is_on ? "#30d158" : "#6e6e80",
                      fontSize: "11px",
                      fontWeight: "bold",
                    }}
                  >
                    <span
                      style={{
                        width: "6px",
                        height: "6px",
                        borderRadius: "50%",
                        background: relay.is_on ? "#30d158" : "#6e6e80",
                      }}
                    />
                    {relay.status}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="adminPanel">
          <h2>Catatan Teknis</h2>
          <ul className="summaryList">
            <li style={{ display: "flex", gap: "8px", alignItems: "center" }}>
              <FaSyncAlt /> <span>Data diperbarui otomatis setiap 10 detik.</span>
            </li>
            <li style={{ display: "flex", gap: "8px", alignItems: "center" }}>
              <FaWater /> <span>Nilai dibandingkan dengan batas normal dari database.</span>
            </li>
            <li style={{ display: "flex", gap: "8px", alignItems: "center" }}>
              <FaExclamationTriangle /> <span>Status warning muncul saat nilai mendekati batas aman.</span>
            </li>
          </ul>
        </div>
      </section>

      <section className="adminPanel" style={{ marginTop: "24px" }}>
        <h2>Data Pembacaan Terbaru</h2>

        <div className="tableWrapper">
          <table className="monitoringTable">
            <thead>
              <tr>
                <th>Sensor</th>
                <th>Nilai</th>
                <th>Unit</th>
                <th>Batas Aman</th>
                <th>Status</th>
                <th>Waktu</th>
              </tr>
            </thead>

            <tbody>
              {sensors.map((sensor) => {
                const status = getStatus(sensor);

                return (
                  <tr key={`row-${sensor.code || sensor.id}`}>
                    <td style={{ fontWeight: "600" }}>{sensor.name}</td>
                    <td>{sensor.value}</td>
                    <td>{sensor.unit}</td>
                    <td style={{ color: "#6e6e80" }}>
                      {sensor.min} - {sensor.max}
                    </td>
                    <td>
                      <span className={`tableStatus ${status.className}`}>
                        {status.label}
                      </span>
                    </td>
                    <td>{formatDateTime(sensor.recorded_at)}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>
    </DashboardLayout>
  );
}
