# REST API CONTRACT (SINGLE SOURCE OF TRUTH)

**Backend Base URL:** `{{BASE_URL}}/api`
**Global Headers:**
- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer <TOKEN>` *(Mandatory for all endpoints except Authentication)*

## A. Authentication
- `POST /auth/login`
  - Payload: `{ "email": "...", "password": "..." }`
  - Response: `{ "token": "...", "user": { "role": "admin|operator" } }`

- `POST /auth/register`
  - Payload: `{ "name": "...", "email": "...", "password": "...", "role_id": 2 }`
  - Response: `{ "status": "success", "message": "User registered successfully", "data": { ... } }`

## B. Pond (Kolam) Management
- `GET /kolam` -> Fetch all active ponds.
- `POST /kolam` -> Create a new pond.
- `GET /kolam/{id}` -> Fetch specific pond details (including MQTT Topic mapping).

## C. Production Management (Daily Logs)
- `POST /produksi/log`
  - Payload format:
    ```json
    {
      "kolam_id": 1,
      "suhu": 28.5,
      "ph": 7.8,
      "do": 6.5,
      "tds": 12,
      "pakan_gram": 500,
      "kematian": 2
    }
    ```

### D. Pakan (Feed Stock) API
**POST** `/api/pakan`
**Headers:** `Authorization: Bearer {token}`, `Accept: application/json`
**Request Body (JSON):**
{
  "kolam_id": 1, // Integer (Unsigned)
  "nama_pakan": "Nama Merk Pakan", // String (Max 255)
  "jumlah_perminggu_kg": 100.50 // Decimal (8,2)
}

### E. Panen (Harvest) API
**POST** `/api/panen`
**Headers:** `Authorization: Bearer {token}`, `Accept: application/json`
**Request Body (JSON):**
{
  "kolam_id": 1, // Integer (Unsigned)
  "tanggal_panen": "2026-06-16", // Date format YYYY-MM-DD
  "jumlah_panen_kg": 500.00, // Decimal (10,2)
  "jenis_panen": "total", // Enum ('parsial', 'total')
  "shrimp_size": "40", // String
  "sale_price": 60000.00 // Decimal (12,2)
}
    ```

### F. Laporan (Report) API
**GET** `/api/laporan/{kolam_id}`
**Headers:** `Authorization: Bearer {token}`, `Accept: application/json`
**Response (200 OK):**
```json
{
  "message": "Success",
  "data": {
    "kolam": {
      "nama_kolam": "Kolam A1",
      "target_panen": "100 Hari"
    },
    "summary": {
      "total_pakan_kg": 1500.5,
      "total_panen_kg": 2500.0,
      "latest_mbw_gram": 12.5
    },
    "history": [
      {
        "tanggal": "2026-06-15",
        "suhu": 28.5,
        "ph": 7.8,
        "do": 6.5,
        "tds": 12,
        "mbw_gram": 12.5
      }
    ]
  }
}
```

*(Agent Directive: This contract is foundational. If you require additional endpoints during the execution of `tasks.md`, you MUST document them in this file FIRST before writing any Laravel backend code).*