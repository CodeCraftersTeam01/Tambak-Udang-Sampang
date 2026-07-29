# REST API CONTRACT (LECTURER MASTER SPECIFICATION)

**Base URL:** `https://api.aquaculture.m-tech.fun`
**Global Headers:**
- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer <TOKEN>` *(Mandatory for all endpoints except Authentication)*

---

## 1. Auth
- **POST `/login`**
  - Payload:
    ```json
    {
      "email": "user@example.com",
      "password": "password"
    }
    ```
  - Response (200 OK):
    ```json
    {
      "token": "bearer_token_here",
      "user": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com",
        "role": "admin"
      }
    }
    ```

---

## 2. Monitoring
- **GET `/ponds`**
  - Response (200 OK): List of all ponds with their status.
- **GET `/monitoring/latest?pond_id={id}`**
  - Response (200 OK): Latest real-time sensor metrics (suhu, ph, tds, do).

---

## 3. Devices
- **GET `/devices`**
  - Response (200 OK): List of registered IoT devices.
- **GET `/devices/{id}`**
  - Response (200 OK): Detail of specific device.
- **GET `/devices/{id}/sensors`**
  - Response (200 OK): List of sensors attached to the device.
- **GET `/devices/{id}/calibration`**
  - Response (200 OK): Calibration coefficients for device sensors.
- **PUT `/devices/{id}/calibration`**
  - Payload: Calibration parameter settings.
  - Response (200 OK): Success status.

---

## 4. Farm Management
- **GET `/farm-management/summary`**
  - Response (200 OK): Overview summary of farms.
- **GET `/farms`**
  - Response (200 OK): List of all farms.
- **POST `/farms`**
  - Payload: `{ "name": "...", "location": "..." }`
- **GET `/farms/{id}`**
- **PUT `/farms/{id}`**
- **DELETE `/farms/{id}`**
- **GET `/farms/{id}/ponds`**
  - Response (200 OK): Ponds belonging to a specific farm.

---

## 5. Ponds
- **GET `/ponds`**
- **POST `/ponds`**
  - Payload:
    ```json
    {
      "farm_id": 1,
      "name": "Pond A1",
      "device_id": 1,
      "latitude": 1.23,
      "longitude": 100.12,
      "area": 1000.5,
      "status": "active"
    }
    ```
- **GET `/ponds/{id}`**
- **PUT `/ponds/{id}`**
- **DELETE `/ponds/{id}`**

---

## 6. Activities
- **GET `/ponds/{id}/activities`**
  - Response (200 OK): Activity logs for the pond.
- **POST `/ponds/{id}/activities`**
  - Payload: `{ "activity_type": "...", "notes": "..." }`
- **PUT `/farm-activities/{id}`**
- **DELETE `/farm-activities/{id}`**

---

## 7. Production Mgmt
- **GET `/production-management/summary`**
  - Response (200 OK): Production analytics and MBW summary.
- **GET `/production-cycles`**
  - Response (200 OK): Active and past cycles.
- **POST `/production-cycles`**
  - Payload: `{ "pond_id": 1, "start_date": "YYYY-MM-DD", "shrimp_species": "...", "initial_density": 100 }`
- **GET `/production-cycles/{id}`**
- **PUT `/production-cycles/{id}`**
- **POST `/production-cycles/{id}/close`**
  - Payload: `{ "end_date": "YYYY-MM-DD", "reason": "..." }`

---

## 8. Production Details
- **GET `/production-cycles/{id}/stocking`** / **POST `/production-cycles/{id}/stocking`**
  - Manage fry stocking details.
- **GET `/production-cycles/{id}/feeding`** / **POST `/production-cycles/{id}/feeding`**
  - Manage daily feeding logs.
- **GET `/production-cycles/{id}/treatments`** / **POST `/production-cycles/{id}/treatments`**
  - Manage chemical/probiotic treatment records.
- **GET `/production-cycles/{id}/harvests`** / **POST `/production-cycles/{id}/harvests`**
  - Manage cycle harvests (partial or total).
- **GET `/production-cycles/{id}/costs`** / **POST `/production-cycles/{id}/costs`**
  - Manage production operational costs.

---

## 9. Users
- **GET `/user-management/summary`**
- **GET `/roles`**
- **GET `/users`**
- **POST `/users`**
- **GET `/users/{id}`**
- **PUT `/users/{id}`**
- **PUT `/users/{id}/password`**
- **PUT `/users/{id}/status`**
- **DELETE `/users/{id}`**