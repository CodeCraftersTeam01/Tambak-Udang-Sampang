# SYSTEM ARCHITECTURE BLUEPRINT: CENTRALIZED TAMBAK SYSTEM

## 1. System Topology & Data Flow
This system utilizes a Centralized Hub architecture where the Backend serves as the Single Source of Truth.

- **Backend (Laravel/PHP)**: Manages the SQL Database and exposes the REST API.
- **Web Client (React)**: Consumes the REST API for the Admin dashboard.
- **Mobile Client (Flutter)**: Consumes the exact same REST API endpoints as the Web Client.
- **IoT Layer (NodeMCU/ESP)**: Transmits sensor data (Temperature, pH) via MQTT protocol to the MQTT Broker.
- **Data Integration**: The Mobile Client subscribes to the MQTT Broker for real-time monitoring, parses the MQTT payload, and transmits it (manually or automatically) to the Backend REST API as Production Data / Daily Logs.

## 2. Mobile Directory Structure (Flutter)
Strictly implement Clean Architecture to separate Transactional data pipelines (REST API) from Real-time data pipelines (MQTT).

lib/
├── core/
│   ├── constants/ (api_endpoints.dart, mqtt_topics.dart, app_colors.dart)
│   ├── network/
│   │   ├── api_client.dart (HTTP Configuration + JWT Interceptor)
│   │   └── mqtt_manager.dart (Broker connection management)
│   └── security/ (Local token management)
├── data/
│   ├── datasources/ (auth_remote, kolam_remote, mqtt_sensor_stream)
│   ├── models/ (JSON Parsing for API and MQTT payloads)
│   └── repositories/
├── domain/
│   └── usecases/ (Pure business logic)
└── presentation/
    ├── bloc/ (State management)
    └── ui/ (Dashboard screens, input forms, and authentication)