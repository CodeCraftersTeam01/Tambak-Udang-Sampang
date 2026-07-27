import { useEffect, useMemo, useState, useCallback } from "react";
import {
  FaBroadcastTower,
  FaCamera,
  FaCheckCircle,
  FaExclamationTriangle,
  FaFan,
  FaMicrochip,
  FaSave,
  FaSlidersH,
  FaSyncAlt,
  FaTools,
  FaWifi,
} from "react-icons/fa";
import DashboardLayout from "../../components/admin/DashboardLayout";
import apiClient from "../../core/network/apiClient";

const defaultCalibration = {
  ph_slope: 3.5,
  ph_offset: 1.9,
  do_scale: 0.5,
  do_offset: 0,
  tds_scale: 1,
  tds_offset: 0,
  suhu_offset: 0,
  revision: 1,
};

function getDeviceIcon(type) {
  switch (type) {
    case "gateway":
      return <FaBroadcastTower />;
    case "sensor_node":
      return <FaMicrochip />;
    case "camera":
      return <FaCamera />;
    case "aerator":
      return <FaFan />;
    default:
      return <FaWifi />;
  }
}

function getStatusClass(status) {
  if (status === "online" || status === "active") return "normal";
  if (status === "maintenance" || status === "warning") return "warning";
  return "critical";
}

function getStatusLabel(status) {
  if (!status) return "-";

  const map = {
    online: "Online",
    offline: "Offline",
    active: "Active",
    inactive: "Inactive",
    maintenance: "Maintenance",
  };

  return map[status] || status;
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

function normalizeArrayResponse(payload, key) {
  const data = payload?.data?.data || payload?.data || payload;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.[key])) return data[key];

  return [];
}

function normalizeCalibration(payload) {
  const data = payload?.data?.data || payload?.data || payload || {};

  return {
    ph_slope: Number(data.ph_slope ?? defaultCalibration.ph_slope),
    ph_offset: Number(data.ph_offset ?? defaultCalibration.ph_offset),
    do_scale: Number(data.do_scale ?? defaultCalibration.do_scale),
    do_offset: Number(data.do_offset ?? defaultCalibration.do_offset),
    tds_scale: Number(data.tds_scale ?? defaultCalibration.tds_scale),
    tds_offset: Number(data.tds_offset ?? defaultCalibration.tds_offset),
    suhu_offset: Number(data.suhu_offset ?? defaultCalibration.suhu_offset),
    revision: Number(data.revision ?? defaultCalibration.revision),
  };
}

function validateCalibration(payload) {
  if (Math.abs(payload.ph_slope) < 0.0001 || payload.ph_slope < -20 || payload.ph_slope > 20) {
    return "pH slope tidak valid.";
  }

  if (payload.ph_offset < -20 || payload.ph_offset > 20) {
    return "pH offset tidak valid.";
  }

  if (payload.do_scale <= 0 || payload.do_scale > 10) {
    return "DO scale harus lebih dari 0 dan maksimal 10.";
  }

  if (payload.do_offset < -20 || payload.do_offset > 20) {
    return "DO offset tidak valid.";
  }

  if (payload.tds_scale <= 0 || payload.tds_scale > 10) {
    return "TDS scale harus lebih dari 0 dan maksimal 10.";
  }

  if (payload.tds_offset < -5000 || payload.tds_offset > 5000) {
    return "TDS offset tidak valid.";
  }

  if (payload.suhu_offset < -10 || payload.suhu_offset > 10) {
    return "Offset suhu tidak valid.";
  }

  return "";
}

export default function Devices() {
  const [devices, setDevices] = useState([]);
  const [selectedDeviceId, setSelectedDeviceId] = useState("");
  const [selectedDeviceDetail, setSelectedDeviceDetail] = useState(null);
  const [sensors, setSensors] = useState([]);
  const [calibration, setCalibration] = useState(defaultCalibration);

  const [loadingDevices, setLoadingDevices] = useState(false);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [savingCalibration, setSavingCalibration] = useState(false);

  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  const selectedDevice = useMemo(() => {
    return (
      selectedDeviceDetail ||
      devices.find((device) => Number(device.id) === Number(selectedDeviceId)) ||
      null
    );
  }, [devices, selectedDeviceId, selectedDeviceDetail]);

  const canCalibrate = selectedDevice?.device_type === "sensor_node";

  const loadDevices = useCallback(async () => {
    try {
      setLoadingDevices(true);
      setError("");
      setMessage("");

      const response = await apiClient.get("/devices");
      const list = normalizeArrayResponse(response, "devices");

      setDevices(list);

      if (list.length > 0) {
        const sensorNode = list.find((item) => item.device_type === "sensor_node");
        setSelectedDeviceId((sensorNode || list[0]).id);
      }
    } catch (err) {
      setError(err.response?.data?.message || err.message || "Gagal memuat data perangkat.");
      setDevices([]);
    } finally {
      setLoadingDevices(false);
    }
  }, []);

  const loadDeviceData = useCallback(async (deviceId) => {
    if (!deviceId) return;

    try {
      setLoadingDetail(true);
      setError("");
      setMessage("");

      const [detailRes, sensorRes, calibrationRes] = await Promise.allSettled([
        apiClient.get(`/devices/${deviceId}`),
        apiClient.get(`/devices/${deviceId}/sensors`),
        apiClient.get(`/devices/${deviceId}/calibration`),
      ]);

      if (detailRes.status === "fulfilled") {
        setSelectedDeviceDetail(detailRes.value.data?.data || detailRes.value.data);
      } else {
        setSelectedDeviceDetail(null);
      }

      if (sensorRes.status === "fulfilled") {
        setSensors(normalizeArrayResponse(sensorRes.value, "sensors"));
      } else {
        setSensors([]);
      }

      if (calibrationRes.status === "fulfilled") {
        setCalibration(normalizeCalibration(calibrationRes.value));
      } else {
        setCalibration(defaultCalibration);
      }
    } catch (err) {
      setError(err.message || "Gagal memuat detail perangkat.");
    } finally {
      setLoadingDetail(false);
    }
  }, []);

  function handleCalibrationChange(field, value) {
    setCalibration((current) => ({
      ...current,
      [field]: value,
    }));
  }

  async function saveCalibration() {
    if (!selectedDevice) return;

    const payload = {
      ph_slope: Number(calibration.ph_slope),
      ph_offset: Number(calibration.ph_offset),
      do_scale: Number(calibration.do_scale),
      do_offset: Number(calibration.do_offset),
      tds_scale: Number(calibration.tds_scale),
      tds_offset: Number(calibration.tds_offset),
      suhu_offset: Number(calibration.suhu_offset),
    };

    const validationError = validateCalibration(payload);

    if (validationError) {
      setError(validationError);
      setMessage("");
      return;
    }

    try {
      setSavingCalibration(true);
      setError("");
      setMessage("");

      const response = await apiClient.put(`/devices/${selectedDevice.id}/calibration`, payload);
      const data = response.data?.data || response.data;
      const updatedCalibration = normalizeCalibration(response);

      setCalibration(updatedCalibration);

      const mqttInfo = data?.mqtt;
      const mqttStatus = mqttInfo?.published
        ? ` MQTT terkirim ke ${mqttInfo.topic}.`
        : " Data tersimpan, tetapi status publish MQTT perlu dicek.";

      setMessage(`Kalibrasi berhasil diperbarui.${mqttStatus}`);
    } catch (err) {
      setError(err.response?.data?.message || err.message || "Gagal menyimpan kalibrasi.");
    } finally {
      setSavingCalibration(false);
    }
  }

  useEffect(() => {
    Promise.resolve().then(() => {
      loadDevices();
    });
  }, [loadDevices]);

  useEffect(() => {
    if (selectedDeviceId) {
      Promise.resolve().then(() => {
        loadDeviceData(selectedDeviceId);
      });
    }
  }, [selectedDeviceId, loadDeviceData]);

  return (
    <DashboardLayout title="Perangkat IoT & Sensor">
      <div className="dashPageHeader">
        <div>
          <h2 className="dashPageTitle">Devices</h2>
          <p className="dashPageSubtitle">
            Kelola perangkat IoT, sensor, MQTT topic, status koneksi, dan konfigurasi kalibrasi.
          </p>
        </div>

        <div>
          <button
            className="btnPrimary"
            onClick={loadDevices}
            disabled={loadingDevices}
          >
            <FaSyncAlt className={loadingDevices ? "spinIcon" : ""} />
            Refresh
          </button>
        </div>
      </div>

      <section className="monitoringMeta">
        <div className="metaBox">
          <span>Total perangkat</span>
          <strong>{devices.length}</strong>
        </div>

        <div className="metaBox">
          <span>Online</span>
          <strong>
            {devices.filter((device) => device.status === "online").length}
          </strong>
        </div>

        <div className="metaBox">
          <span>Device aktif</span>
          <strong>{selectedDevice?.device_code || "-"}</strong>
        </div>

        <div className="metaBox">
          <span>Revision kalibrasi</span>
          <strong>{calibration.revision || "-"}</strong>
        </div>
      </section>

      {error && (
        <div className="monitoringAlert">
          <FaExclamationTriangle />
          <span>{error}</span>
        </div>
      )}

      {message && (
        <div className="deviceSuccess">
          <FaCheckCircle />
          <span>{message}</span>
        </div>
      )}

      <section className="deviceLayout">
        <div className="adminPanel">
          <h2>Daftar Perangkat</h2>

          {devices.length === 0 ? (
            <p className="emptyText">Belum ada data perangkat dari API.</p>
          ) : (
            <div className="deviceList">
              {devices.map((device) => {
                const active = Number(device.id) === Number(selectedDeviceId);

                return (
                  <button
                    key={device.id}
                    className={`deviceItem ${active ? "active" : ""}`}
                    onClick={() => setSelectedDeviceId(device.id)}
                  >
                    <div className="deviceIcon">
                      {getDeviceIcon(device.device_type)}
                    </div>

                    <div className="deviceInfo">
                      <strong>{device.name}</strong>
                      <span>{device.device_code}</span>
                      <small>{device.device_type}</small>
                    </div>

                    <span className={`deviceStatus ${getStatusClass(device.status)}`}>
                      {getStatusLabel(device.status)}
                    </span>
                  </button>
                );
              })}
            </div>
          )}
        </div>

        <div className="adminPanel">
          <h2>Detail Perangkat</h2>

          {loadingDetail ? (
            <p className="loadingText">Memuat detail perangkat...</p>
          ) : selectedDevice ? (
            <div className="deviceDetailGrid">
              <div>
                <span>Device Code</span>
                <strong>{selectedDevice.device_code || "-"}</strong>
              </div>

              <div>
                <span>Nama</span>
                <strong>{selectedDevice.name || "-"}</strong>
              </div>

              <div>
                <span>Tipe</span>
                <strong>{selectedDevice.device_type || "-"}</strong>
              </div>

              <div>
                <span>Kolam</span>
                <strong>
                  {selectedDevice.pond_code
                    ? `${selectedDevice.pond_code} - ${selectedDevice.pond_name}`
                    : selectedDevice.pond_name || "-"}
                </strong>
              </div>

              <div>
                <span>Brand / Model</span>
                <strong>
                  {selectedDevice.brand || "-"} / {selectedDevice.model || "-"}
                </strong>
              </div>

              <div>
                <span>Status</span>
                <strong className={`textStatus ${getStatusClass(selectedDevice.status)}`}>
                  {getStatusLabel(selectedDevice.status)}
                </strong>
              </div>

              <div>
                <span>Last Seen</span>
                <strong>{formatDateTime(selectedDevice.last_seen_at)}</strong>
              </div>

              <div>
                <span>Installed At</span>
                <strong>{formatDateTime(selectedDevice.installed_at)}</strong>
              </div>

              <div className="fullWidth">
                <span>MQTT Topic</span>
                <strong className="mqttTopic">
                  {selectedDevice.mqtt_topic || "-"}
                </strong>
              </div>
            </div>
          ) : (
            <p className="emptyText">Pilih perangkat terlebih dahulu.</p>
          )}
        </div>
      </section>

      <section className="adminGrid">
        <div className="adminPanel">
          <h2>Sensor dalam Perangkat</h2>

          {sensors.length === 0 ? (
            <p className="emptyText">Tidak ada sensor terdaftar pada perangkat ini.</p>
          ) : (
            <div className="sensorMiniList">
              {sensors.map((sensor) => (
                <div className="sensorMiniItem" key={sensor.id}>
                  <div>
                    <strong>{sensor.name}</strong>
                    <span>{sensor.sensor_code}</span>
                  </div>

                  <div>
                    <small>
                      {sensor.type_code || sensor.code} / {sensor.unit || "-"}
                    </small>
                    <span className={`miniStatus ${sensor.status}`}>
                      {sensor.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="adminPanel">
          <div className="panelTitleRow">
            <h2>Remote Calibration</h2>
            <FaSlidersH />
          </div>

          {!selectedDevice ? (
            <p className="emptyText">Pilih perangkat sensor terlebih dahulu.</p>
          ) : !canCalibrate ? (
            <div className="calibrationDisabled">
              <FaTools />
              <p>Kalibrasi hanya tersedia untuk device bertipe sensor_node.</p>
            </div>
          ) : (
            <>
              <div className="calibrationNote">
                <strong>Publish topic:</strong>{" "}
                {selectedDevice.mqtt_topic
                  ? `${selectedDevice.mqtt_topic}/calibration/set`
                  : "-"}
              </div>

              <div className="calibrationGrid">
                <label>
                  <span>pH Slope</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.ph_slope}
                    onChange={(event) =>
                      handleCalibrationChange("ph_slope", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>pH Offset</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.ph_offset}
                    onChange={(event) =>
                      handleCalibrationChange("ph_offset", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>DO Scale</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.do_scale}
                    onChange={(event) =>
                      handleCalibrationChange("do_scale", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>DO Offset</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.do_offset}
                    onChange={(event) =>
                      handleCalibrationChange("do_offset", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>TDS Scale</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.tds_scale}
                    onChange={(event) =>
                      handleCalibrationChange("tds_scale", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>TDS Offset</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.tds_offset}
                    onChange={(event) =>
                      handleCalibrationChange("tds_offset", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>Suhu Offset</span>
                  <input
                    type="number"
                    step="0.000001"
                    value={calibration.suhu_offset}
                    onChange={(event) =>
                      handleCalibrationChange("suhu_offset", event.target.value)
                    }
                  />
                </label>

                <label>
                  <span>Revision</span>
                  <input value={calibration.revision} disabled />
                </label>
              </div>

              <button
                className="saveCalibrationBtn"
                onClick={saveCalibration}
                disabled={savingCalibration}
              >
                <FaSave />
                {savingCalibration ? "Menyimpan..." : "Simpan Kalibrasi"}
              </button>
            </>
          )}
        </div>
      </section>
    </DashboardLayout>
  );
}
