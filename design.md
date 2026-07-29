# SYSTEM ARCHITECTURE BLUEPRINT: CENTRALIZED TAMBAK SYSTEM

## 1. System Topology & Data Flow
This system utilizes a Centralized Hub architecture where the Backend serves as the Single Source of Truth.

- **Backend (Laravel/PHP)**: Manages the SQL Database and exposes the REST API.
- **Web Client (React)**: Consumes the REST API for the Admin dashboard.
- **Mobile Client (Flutter)**: Consumes the exact same REST API endpoints as the Web Client.
- **IoT Layer (NodeMCU/ESP)**: Transmits sensor data via MQTT protocol to the MQTT Broker.
- **Data Integration**: The Mobile Client subscribes to the MQTT Broker for real-time monitoring, parses the MQTT payload, and transmits it (manually or automatically) to the Backend REST API as Production Data / Daily Logs.

---

## 2. IoT Firmware & MQTT Topic Constraints
- **MQTT Broker**: `m-tech.fun:1883`
- **Base Topic Structure**: `pkm2026/{device_id}/...` (where `{device_id}` is the device/pond identifier, e.g., `t01`)
- **Sensor Topics**:
  - `pkm2026/{device_id}/suhu` -> DS18B20 Temperature sensor data.
  - `pkm2026/{device_id}/ph` -> ADS1115 pH sensor data.
  - `pkm2026/{device_id}/tds` -> Modbus TDS sensor data.
  - `pkm2026/{device_id}/do` -> Modbus Dissolved Oxygen sensor data.
- **Control Topics**:
  - `pkm2026/{device_id}/aerator_1/control` -> Publish control commands (`ON` / `OFF`).
  - `pkm2026/{device_id}/aerator_1/status` -> Subscribe to status responses.
- **Calibration Topics**:
  - `pkm2026/{device_id}/calibration/set` -> Publish calibration parameters.
  - `pkm2026/{device_id}/calibration/state` -> Monitor calibration state.
  - `pkm2026/{device_id}/calibration/ack` -> Receive acknowledgment signal.
- **Hardware Profile**:
  - MCU: **ESP32 S3**
  - Temperature Sensor: **DS18B20**
  - pH Sensor Converter: **ADS1115**
  - TDS & DO Sensors: **Modbus (RS485)**
  - Actuator Output: **Relay Active High**

---

## 3. Mobile Directory Structure (Flutter)
Strictly implement Clean Architecture to separate Transactional data pipelines (REST API) from Real-time data pipelines (MQTT).

```
lib/
├── core/
│   ├── constants/ (api_endpoints.dart, mqtt_topics.dart, app_colors.dart)
│   ├── network/
│   │   ├── api_client.dart (HTTP Configuration + JWT Interceptor)
│   │   └── mqtt_manager.dart (Broker connection management)
│   └── security/ (Local token management)
├── data/
│   ├── datasources/ (auth_remote, pond_remote, mqtt_sensor_stream)
│   ├── models/ (JSON Parsing for API and MQTT payloads)
│   └── repositories/
├── domain/
│   └── usecases/ (Pure business logic)
└── presentation/
    ├── bloc/ (State management)
    └── ui/ (Dashboard screens, input forms, and authentication)
```

---

## 4. UI/UX Design Language (Tailwind-Esque Natively)
- **Primary Palette**: Navy Blue (`Color(0xFF0F172A)`) to Pure White (`Colors.white`).
- **Backgrounds**: All main screens MUST implement a `LinearGradient` starting from Navy Blue at the `topCenter` transitioning to White at the `bottomCenter`.
- **Containers**: Forms, lists, and sensor cards must be wrapped in White `Container`s with `BorderRadius.circular(24)` and a soft `BoxShadow` (mimicking Tailwind's `shadow-lg` with `blurRadius: 10`, `color: Colors.black12`).
- **Buttons**: Action buttons must have constrained sizes (e.g., `height: 50`) and should not overflow or expand infinitely.