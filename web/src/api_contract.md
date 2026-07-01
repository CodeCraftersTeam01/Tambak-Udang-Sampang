# API BASE URL: http://localhost:8000/api

## 1. Auth & Session
- POST `/login` -> Body: `email`, `password`. Returns `token`.
- POST `/logout` -> Requires Bearer Token.

## 2. Kolam (Pond Management)
- GET `/kolam`
- POST `/kolam` -> Body: `nama_kolam`, `lokasi`, `target_panen_kg`.

## 3. Produksi (Daily Logs)
- POST `/produksi/log` -> Body: `kolam_id`, `pakan_harian_kg`, `mbw_gram`, `kematian_ekor`, `suhu`, `ph`, `do`, `tds`. (Ensure 'tds' is used, not 'kekeruhan').

## 4. Pakan & Panen
- POST `/pakan` -> Body: `nama_pakan`, `jumlah_perminggu_kg`.
- POST `/panen` -> Body: `kolam_id`, `tanggal_panen`, `jumlah_panen_kg`, `jenis_panen` (parsial/total).

## 5. Reporting & Summary
- GET `/laporan/{kolam_id}` -> Returns aggregated JSON for PDF/Web reporting.

## 6. Users (Admin Web Specific)
- GET `/users`
- POST `/users` -> Body: `name`, `email`, `password`, `role`.