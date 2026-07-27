# TASK TRACKER & PIPELINE: TAMBAK PROJECT V3
(AGENT DIRECTIVE: For every task, audit the codebase first. Mark `[x]` ONLY when a task is fully functional and verified).

## 1. Authentication & Security Layer
- [x] Backend: Create REST API for Login & Register (Laravel Sanctum/JWT).
- [x] Mobile: Build Flutter Login UI (Clean, minimalist, and accessible style).
- [x] Mobile: Implement Secure Storage & Dio Interceptor.

## 2. Pond (Kolam) Management Module
- [x] Backend: Create CRUD API for Pond Data.
- [x] Mobile: Build UI for Active Ponds List and Cycle History.
- [x] Mobile: Integrate UI with the Fetch Ponds API.

## 3. Production Management & Real IoT Integration
- [x] Backend: Create API for Daily Production Log input.
- [x] Mobile: Build Log Input Form UI with IoT Auto-Fill & Daily Progress Chart.
- [x] Mobile IoT: Connect `mqtt_client` to `m-tech.fun` (port 1883).
- [x] Mobile IoT: Multi-topic subscription & parsing (Suhu, pH, TDS, DO).

## 4. Feed & Harvest Management Module
- [x] Backend: Create CRUD API for Feed Stock & Harvest Recording.
- [x] Mobile Pakan: Build UI for Feed Stock CRUD.
- [x] Mobile Panen: Build Harvest Form UI.

## 5. Export & Reporting Module
- [x] Backend & Mobile: Aggregation API and PDF Generation.

## 6. Early Warning System & Automation
- [x] Backend & Mobile: FCM Push Notifications & threshold logic.

## 7. Profile & Session Management
- [x] Mobile: ProfileScreen and Secure Logout.

## 8. Database Parity: Ekspansi Kolam (PRIORITY)
- [x] Backend (`api/`): Create Laravel migration adding `luas_kolam` (decimal), `detail_udang` (string), and `jumlah_kincir` (integer) to `kolams` table.
- [x] Backend (`api/`): Update `KolamController.php` (Store & Update methods) to validate and save the new fields.
- [x] Mobile (`apk_tambak/`): Update `api_contract.md` to reflect the new payload requirements for `POST /kolam`.

## 9. UI Revamp & Multi-Relay IoT Control
- [ ] Mobile UI: Apply "Navy Blue to White" global gradient theme natively. Eradicate legacy Teal backgrounds.
- [ ] Mobile UI Bugfix: Fix the unconstrained Layout Boundary Error (Giant Button) on the "Input Log Harian" / Detail Kolam screen.
- [ ] Mobile: Add Lottie/Rive (or Implicit) animations to sensor indicators in `PondDetailScreen`.
- [ ] Mobile: Refactor `AddKolamScreen` form to include Luas, Detail Udang, and Jumlah Kincir inputs.
- [ ] Mobile: Inject a dynamic Relay Grid in `PondDetailScreen` rendering individual aerator controls based on `jumlah_kincir`.
- [ ] Mobile IoT: Implement Master Switch (Turn All ON / Turn All OFF) MQTT broadcast logic.