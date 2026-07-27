# TASK TRACKER: WEB DASHBOARD (REACT)
(AGENT DIRECTIVE: Audit the existing UI code first. Inject Axios/State logic directly into existing components. Change `[ ]` to `[x]` ONLY when the React feature successfully communicates with the API).

## 1. Authentication Layer (Priority)
- [x] Install Axios. Create `apiClient.js` with interceptors to inject `localStorage` JWT token.
- [x] Audit the existing Login Page component. Bind Email/Password inputs to React State.
- [x] Wire the existing "Sign In" button to `POST /login` and store token. Redirect to Dashboard.
- [x] Implement Protected Routes (redirect to login if token is missing).

## 2. Dashboard Aggregation & Sync
- [x] Audit Dashboard UI. Fetch summary metrics from the Laravel API aggregation endpoint.
- [x] Bind existing data cards and charts to show real production data from the database.

## 3. CRUD Kolam & Log Produksi
- [x] Audit "Data Kolam" UI. Sync `GET /kolam` to populate the existing data table.
- [x] Connect the existing Add/Edit Modal forms to `POST /kolam`.
- [x] Wire the "Log Harian" input forms to `POST /produksi/log` (ensure strict `tds` key mapping).

## 4. CRUD Pakan & Panen
- [x] Audit "Manajemen Pakan" UI. Connect table and form submission to the API.
- [x] Audit "Manajemen Panen" UI. Connect table and form submission to the API.

## 5. User Management & Session Security
- [x] Audit/Build "Manajemen Pengguna" Page to manage admins/operators (`GET` & `POST` `/users`).
- [x] Connect the existing Logout button in the Topbar/Sidebar to `POST /logout` and flush `localStorage`.