# TASK TRACKER & PIPELINE: TAMBAK PROJECT
(AGENT DIRECTIVE: For every Backend task, audit the Laravel codebase first. If the feature exists, mark `[x]` immediately. If missing, build it safely. Change `[ ]` to `[x]` ONLY when a task is completed/verified).

## 1. Authentication & Security Layer
- [x] Backend: Create REST API for Login & Register (Laravel Sanctum/JWT).
- [x] Mobile: Build Flutter Login UI (Clean, minimalist, and accessible style).
- [x] Mobile: Implement Secure Storage to save the Bearer Token.
- [x] Mobile: Create HTTP/Dio Interceptor to inject the token into every request header.

## 2. Pond (Kolam) Management Module
- [x] Backend: Create CRUD API for Pond Data (Name, Location, Status, Target).
- [x] Mobile: Build UI for Active Ponds List and Cycle History.
- [x] Mobile: Integrate UI with the Fetch Ponds API.
- [x] IoT/Mobile: Map Pond IDs to corresponding MQTT Topics for sensor data subscription.

## 3. Production Management & Real IoT Integration Module
- [x] Backend: Create API for Daily Production Log input (Feed, MBW, Mortality).
- [x] Mobile: Build Log Input Form UI with IoT Auto-Fill.
- [x] Mobile: Build Daily Progress Chart UI (Native CustomPainter) & History List.
- [x] Mobile IoT: Remove MockMqttManager. Install `mqtt_client` and connect to the live academic broker (`m-tech.fun`, port 1883).
- [x] Mobile IoT: Refactor Pond Detail UI. Change "Kekeruhan (NTU)" to "TDS". 
- [x] Mobile IoT: Implement multi-topic subscription (`pkm2026/t01/#`) and parse raw String payloads (not JSON) for Suhu, pH, TDS, and DO.
- [x] Mobile IoT: Implement Aerator Control logic (Publish to `aerator/control`, sync UI state from `aerator/status`).

## 4. Feed & Harvest Management Module
- [x] Backend: Create CRUD API for Feed Stock & Harvest Recording.
- [x] Mobile Bugfix: Fix the 422 Validation Error on Pakan submission by ensuring the Dio payload strictly follows `api_contract.md`.
- [x] Mobile Pakan: Build UI for Feed Stock CRUD. 
      -> DETAIL: Input MUST strictly map to `nama_pakan` (String) and `jumlah_perminggu_kg` (Decimal).
- [x] Mobile Panen: Build Harvest Form UI.
      -> DETAIL: Input mapped to `tanggal_panen` (Date), `jumlah_panen_kg` (Decimal), and `jenis_panen` (Enum: parsial/total).

## 5. Export & Reporting Module (Ekspansi 1)
- [x] Backend: Create API endpoint to aggregate full cycle summary (Kolam, Logs, Pakan, Panen).
- [x] Mobile: Implement PDF generation (using `pdf` package) to export the cycle summary report.

## 6. Early Warning System & Automation (Ekspansi 2)
- [x] Backend: (Optional) Create Laravel MQTT listener daemon if server-side logging of raw sensor data is needed.
- [x] Backend: Implement threshold logic (e.g., pH < 7.5 or Suhu > 32°C).
- [x] Backend: Integrate Firebase Cloud Messaging (FCM) to trigger Push Notifications.
- [x] Mobile: Integrate the `firebase_messaging` package to handle Push Notifications.

## 7. Profile & Session Management (Ekspansi 3)
- [x] Mobile: Build `ProfileScreen` accessible from an AppBar action or BottomNav.
- [x] Mobile: Implement secure Logout logic (clear SecureStorage JWT and push/remove route to LoginScreen).