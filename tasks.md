# TASK TRACKER & PIPELINE (LECTURER Master Specification Sync)

This pipeline has been updated to strictly align with the Lecturer's Master Specification and the Mobile Minimum Priority list.

---

## 1. Phase 1: Mobile Minimum Priority Integration (Flutter)
- [x] **Mobile: POST `/login` Integration**
  - Update `AuthRemoteDatasource` and `ApiEndpoints` from `/auth/login` to `/login`.
  - Validate request payload and JWT token storage.
- [x] **Mobile: GET `/ponds` Integration**
  - Update `KolamRemoteDatasource` and `ApiEndpoints` from `/kolam` to `/ponds`.
  - Update models/schemas to parse pond information (e.g. `area` instead of `luas_kolam`).
- [ ] **Mobile: GET `/monitoring/latest?pond_id={id}` Integration**
  - Build UI and datasource to fetch the latest real-time sensor metrics for the dashboard.
- [ ] **Mobile: GET `/devices` Integration**
  - Build data models, repository, and UI to display connected IoT devices.
- [ ] **Mobile: GET `/farm-management/summary` Integration**
  - Implement summary/dashboard cards showing farm overview and statistics.
- [ ] **Mobile: GET `/production-management/summary` Integration**
  - Build UI for production metrics overview, average daily gain (ADG), and survival rate (SR).
- [ ] **Mobile: GET `/production-cycles` Integration**
  - Fetch active and historical cycles for display in the app.
- [ ] **Mobile: GET `/production-cycles/{id}` Integration**
  - Display the detail view for a specific production cycle.

---

## 2. Phase 2: Production Details & Activities (Flutter)
- [ ] **Mobile: Daily Feeding & Logs (`/production-cycles/{id}/feeding`)**
  - Implement form submission to POST daily feed logs.
- [ ] **Mobile: Stocking Details (`/production-cycles/{id}/stocking`)**
  - Form to display and record fry stocking events.
- [ ] **Mobile: Treatments Logs (`/production-cycles/{id}/treatments`)**
  - Form to record probiotics/chemicals application.
- [ ] **Mobile: Harvest Recording (`/production-cycles/{id}/harvests`)**
  - Re-align harvest screen to POST cycle harvests.
- [ ] **Mobile: Operational Costs (`/production-cycles/{id}/costs`)**
  - UI to add and view operational cost logs.
- [ ] **Mobile: Activities Logging (`/ponds/{id}/activities`)**
  - Display and log general farm activities.

---

## 3. Phase 3: IoT Calibration & Multi-Relay Control (Flutter)
- [ ] **Mobile: Device Calibration (`/devices/{id}/calibration`)**
  - UI screen to retrieve calibration coefficients and PUT calibration requests.
- [x] **Mobile MQTT: Multi-topic Subscription (`pkm2026/t01/...`)**
  - Configure `mqtt_manager.dart` to subscribe to `/suhu`, `/ph`, `/tds`, `/do`.
  - Implement parsing for real-time sensor widgets in `PondDetailScreen`.
- [x] **Mobile MQTT: Control and Status (`/aerator_1/control`, `/aerator_1/status`)**
  - Implement toggles for individual relay/aerator controls.
- [ ] **Mobile MQTT: Calibration Over-The-Air**
  - Handle topic subscriptions: `/calibration/set`, `/calibration/state`, `/calibration/ack`.

---

## 4. Phase 4: UI/UX & Style Polish
- [ ] **Global Colors Override**: Enforce the Navy Blue to White theme natively.
- [ ] **Visual Gauge Overhaul**:
  - [x] temperature vertical progress liquid fill.
  - [x] pH horizontal gradient spectrum bar with dynamic thumb interpolation.
  - [x] TDS graduated cylinder beaker with dynamic particle flow.
  - [ ] Dissolved Oxygen radial half-arc gauge.
- [ ] **Layout Bugfix**: Ensure no unconstrained layout overflow issues in detail screens.

---

## 5. Phase 5: Backend API Alignment (Laravel)
*(Note: Auditing routes and controller structures first before making code updates)*
- [x] **Backend: Auth Route Alignment**
  - Move/Alias `/auth/login` to `POST /login`.
- [x] **Backend: Monitoring Routes**
  - Implement `/monitoring/latest` returning the latest record from sensor history.
- [x] **Backend: Devices & Calibration**
  - Ensure `/devices` routes and calibration storage/PUT logic are present.
- [x] **Backend: Farm & Pond Management**
  - Sync routes `/farms` and `/ponds` to standard REST resource patterns.
- [ ] **Backend: Activities Resource**
  - Group `/ponds/{id}/activities` and `/farm-activities` in controller.
- [x] **Backend: Production Cycles & Details**
  - Create tables/models and routes for `production_cycles`.
  - Create endpoints for cycle sub-details: stocking, feeding, treatments, harvests, costs.
- [ ] **Backend: User Management summary and CRUD**
  - Implement `/user-management/summary` and `/users` routes/controllers.