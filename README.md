
<p align="center">
  <img src="web/public/favicon.svg" alt="Tambak Udang Sampang" width="120" />
</p>

<h1 align="center">🦐 Tambak Udang Sampang</h1>

<p align="center">
  <strong>Sistem Monitoring & Manajemen Tambak Udang Berbasis IoT</strong>
  <br />
  Platform terpadu untuk memantau kualitas air, mengelola produksi, pakan, panen, dan perangkat IoT pada tambak udang secara real-time.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/React-19-61DAFB?logo=react" alt="React 19" />
  <img src="https://img.shields.io/badge/Laravel_Lumen-10-F4645F?logo=laravel" alt="Lumen 10" />
  <img src="https://img.shields.io/badge/Vite-8-646CFF?logo=vite" alt="Vite 8" />
  <img src="https://img.shields.io/badge/MQTT-Real--Time-660066?logo=mqtt" alt="MQTT" />
  <img src="https://img.shields.io/badge/Three.js-3D-000000?logo=three.js" alt="Three.js" />
  <img src="https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql" alt="MySQL" />
  <img src="https://img.shields.io/badge/JWT-Auth-000000?logo=jsonwebtokens" alt="JWT" />
</p>

---

## 📋 Daftar Isi

- [Tentang Project](#tentang-project)
- [Fitur Unggulan](#fitur-unggulan)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Tech Stack](#tech-stack)
- [Struktur Project](#struktur-project)
- [Prerequisites](#prerequisites)
- [Instalasi & Setup](#instalasi--setup)
  - [1. API (Backend)](#1-api-backend)
  - [2. Web (Frontend)](#2-web-frontend)
- [Konfigurasi Environment](#konfigurasi-environment)
- [API Documentation](#api-documentation)
- [Screenshots](#screenshots)
- [Penggunaan](#penggunaan)
- [Roadmap](#roadmap)
- [Kontribusi](#kontribusi)
- [Lisensi](#lisensi)

---

## 🎯 Tentang Project

**Tambak Udang Sampang** adalah sistem manajemen tambak udang modern yang mengintegrasikan **perangkat IoT**, **monitoring real-time**, dan **dashboard manajemen** berbasis web. Dibangun untuk membantu para petambak udang dalam:

- 📊 **Memantau kualitas air** (suhu, pH, DO, TDS) secara real-time dari sensor IoT
- 📈 **Mengelola siklus produksi** dari penebaran benur hingga panen
- 🧮 **Menghitung kebutuhan pakan** dan mencatat riwayat pemberian pakan
- 🏷️ **Mencatat hasil panen** (parsial/total) dengan detail ukuran dan harga
- 🔔 **Mendapatkan notifikasi** jika parameter air melebihi ambang batas
- 🌐 **Mengelola kolam, perangkat, dan pengguna** dalam satu platform

Proyek ini terdiri dari dua bagian utama:
- **Backend API** — RESTful API berbasis Laravel Lumen dengan JWT authentication
- **Frontend Web** — Single Page Application (SPA) React dengan visualisasi 3D interaktif dan animasi modern

---

## ✨ Fitur Unggulan

### 🖥️ Frontend Web
| Fitur | Deskripsi |
|-------|-----------|
| **Landing Page Interaktif** | Halaman utama dengan animasi 3D (Three.js), parallax, smooth scrolling, dan live stats |
| **Dashboard Admin** | Ringkasan produksi, status kolam, dan grafik perkembangan |
| **Manajemen Kolam** | CRUD kolam dengan peta interaktif (Leaflet) dan detail luas, kincir, status |
| **Monitoring Real-time** | Data sensor IoT (suhu, pH, DO, TDS) diperbarui langsung via MQTT |
| **Produksi & Log** | Catat siklus produksi, log harian (pakan, MBW, kematian, kualitas air) |
| **Manajemen Pakan** | Catat pemberian pakan per minggu dengan statistik |
| **Manajemen Panen** | Catat hasil panen parsial/total dengan ukuran dan harga |
| **Manajemen Perangkat** | Kelola perangkat IoT dan relay otomatisasi |
| **Manajemen Pengguna** | CRUD pengguna dengan role-based access (Super Admin, Admin) |
| **Sistem Auth JWT** | Login/register aman dengan token-based authentication |

### ⚙️ Backend API
| Fitur | Deskripsi |
|-------|-----------|
| **RESTful API** | Endpoint lengkap untuk semua fitur manajemen |
| **JWT Authentication** | Auth aman menggunakan `tymon/jwt-auth` |
| **Role-Based Access** | Middleware untuk Super Admin, Admin, dan User biasa |
| **MQTT Integration** | Subscribe & publish data sensor IoT secara real-time |
| **Firebase Push Notification** | Kirim notifikasi ke perangkat mobile jika ada anomali |
| **Rate Limiting** | Proteksi endpoint dengan throttle |
| **CORS Middleware** | Aman untuk koneksi cross-origin |
| **Input Sanitization** | Perlindungan dari XSS dan injection |

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────┐
│                    IoT Devices (ESP32)                       │
│                Sensor Suhu, pH, DO, TDS                      │
└───────────┬─────────────────────────────────────┬───────────┘
            │                                     │
            │ MQTT (wss://broker.m-tech.fun:8084)  │
            ▼                                     ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│     MQTT Broker         │ ◄─────► │   MQTT Listener Daemon  │
│   (Mosquitto Cloud)     │         │  (Laravel Command)      │
└───────────┬─────────────┘         └───────────┬─────────────┘
            │                                   │
            │                                   │ Subscribe &
            │                                   │ Process Data
            ▼                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend API (Lumen 10)                       │
│  • Auth (JWT)     • Kolam CRUD     • Produksi & Log          │
│  • Pakan          • Panen          • Laporan                 │
│  • Devices        • Monitoring     • Users (RBAC)            │
└───────────┬─────────────────────────────────────┬───────────┘
            │                                     │
            │ HTTP/JSON (REST)                    │ Firebase
            ▼                                     ▼
┌─────────────────────────┐         ┌─────────────────────────┐
│   Frontend Web (React)  │         │   Firebase Cloud        │
│   • Landing Page 3D     │         │   Messaging (Push Notif)│
│   • Dashboard Admin     │         └─────────────────────────┘
│   • Monitoring Real-time│
│   • Management Panel    │
│   • MQTT Client (WS)    │
└─────────────────────────┘
```

---

## 🛠️ Tech Stack

### Backend (API)
| Teknologi | Kegunaan |
|-----------|----------|
| **Laravel Lumen 10** | Micro-framework PHP untuk REST API |
| **MySQL** | Database relasional |
| **JWT Auth** | Authentication via `tymon/jwt-auth` |
| **MQTT Client** | Koneksi IoT real-time via `php-mqtt/client` |
| **Firebase PHP** | Push notification via `kreait/firebase-php` |
| **Doctrine DBAL** | Migrasi database lanjutan |

### Frontend (Web)
| Teknologi | Kegunaan |
|-----------|----------|
| **React 19** | Library UI modern |
| **Vite 8** | Build tool cepat |
| **React Router 7** | Routing SPA |
| **MUI (Material UI)** | Komponen UI siap pakai |
| **Axios** | HTTP client untuk API calls |
| **MQTT.js** | WebSocket MQTT client untuk data real-time |
| **Three.js / @react-three/fiber** | Visualisasi 3D interaktif |
| **GSAP** | Animasi performa tinggi |
| **Lenis / Locomotive Scroll** | Smooth scrolling |
| **Chart.js / react-chartjs-2** | Grafik dan chart interaktif |
| **Leaflet / react-leaflet** | Peta interaktif untuk lokasi kolam |
| **React Icons** | Icons library |

---

## 📁 Struktur Project

```
Tambak-Udang-Sampang/
├── api/                              # Backend Laravel Lumen
│   ├── app/
│   │   ├── Console/Commands/         # MQTT Listener Daemon
│   │   ├── Events/                   # Event classes
│   │   ├── Exceptions/               # Error handlers
│   │   ├── Http/
│   │   │   ├── Controllers/          # API Controllers
│   │   │   │   ├── AuthController    # Login/Register/Logout
│   │   │   │   ├── KolamController   # Manajemen kolam
│   │   │   │   ├── ProduksiController # Siklus produksi
│   │   │   │   ├── PakanController   # Manajemen pakan
│   │   │   │   ├── PanenController   # Manajemen panen
│   │   │   │   ├── MonitoringController # Data monitoring
│   │   │   │   ├── DeviceController  # Perangkat IoT
│   │   │   │   ├── RelayController   # Kontrol relay
│   │   │   │   ├── UserController    # Manajemen user
│   │   │   │   ├── LaporanController # Laporan & agregasi
│   │   │   │   └── PublicStatsController # Public API
│   │   │   ├── Middleware/           # JWT, CORS, Role, RateLimit
│   │   │   └── Requests/             # Form request validation
│   │   ├── Jobs/                     # Queue jobs
│   │   ├── Listeners/                # Event listeners
│   │   ├── Models/                   # Eloquent Models
│   │   └── Services/                 # Firebase push service
│   ├── config/                       # Config files (auth, jwt)
│   ├── database/
│   │   ├── migrations/               # Database migrations
│   │   ├── schema/                   # Full SQL schema
│   │   └── seeders/                  # Database seeders
│   ├── routes/
│   │   └── api.php                   # API route definitions
│   └── storage/                      # Firebase credentials
│
├── web/                              # Frontend React SPA
│   ├── src/
│   │   ├── components/
│   │   │   ├── admin/                # Dashboard layout, modal
│   │   │   ├── auth/                 # Login modal
│   │   │   ├── cards/                # Feature cards
│   │   │   ├── hero/                 # Hero section
│   │   │   ├── landing/              # Live stats, usia benur
│   │   │   └── layout/               # Navbar, Footer, Topbar
│   │   ├── pages/
│   │   │   ├── admin/                # Admin pages (Dashboard,
│   │   │   │                         # Kolam, Produksi, Pakan,
│   │   │   │                         # Panen, Monitoring, Devices,
│   │   │   │                         # Users)
│   │   │   └── LandingPage.jsx       # Public landing page
│   │   ├── services/                 # API & MQTT clients
│   │   ├── styles/                   # CSS files per section
│   │   └── core/network/             # Axios instance
│   ├── index.html
│   └── package.json
│
├── .gitignore
└── README.md                         # ✨ This file
```

---

## 📋 Prerequisites

Sebelum memulai, pastikan environment Anda memiliki:

| Requirement | Versi Minimal |
|-------------|---------------|
| **PHP** | ^8.1 |
| **Composer** | 2.x |
| **Node.js** | ^18 / ^20 |
| **npm** | 9+ / 10+ |
| **MySQL** | 5.7+ / 8.0 |
| **OpenSSL** | Untuk generate JWT key |

---

## 🔧 Instalasi & Setup

### 1. API (Backend)

```bash
# Clone repository
git clone https://github.com/your-username/Tambak-Udang-Sampang.git
cd Tambak-Udang-Sampang/api

# Install PHP dependencies
composer install

# Copy environment config
cp .env.example .env

# Generate application key & JWT secret
php artisan key:generate
php artisan jwt:secret

# Setup database
# 1. Buat database MySQL baru (misal: tambak_udang)
# 2. Sesuaikan konfigurasi di .env (DB_DATABASE, DB_USERNAME, DB_PASSWORD)

# Jalankan migrasi dan seeder
php artisan migrate --seed

# Jalankan development server
php -S localhost:8000 -t public
```

Server API akan berjalan di `http://localhost:8000`.

### 2. Web (Frontend)

```bash
cd ../web

# Install Node.js dependencies
npm install

# Copy environment config
cp .env.example .env
# Edit .env: atur VITE_API_URL=http://localhost:8000/api

# Jalankan development server
npm run dev
```

Frontend akan berjalan di `http://localhost:5173`.

---

## ⚙️ Konfigurasi Environment

### API (`api/.env`)

```env
APP_NAME=Tambak Udang Sampang
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tambak_udang
DB_USERNAME=root
DB_PASSWORD=

JWT_SECRET=<generated-by-php-artisan-jwt-secret>
JWT_TTL=3600

MQTT_HOST=broker.m-tech.fun
MQTT_PORT=1883

FIREBASE_CREDENTIALS=storage/firebase/credentials.json
```

### Web (`web/.env`)

```env
VITE_API_URL=http://localhost:8000/api
```

---

## 📚 API Documentation

### Public Endpoints

| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/api/public/usia-benur` | Data usia benur seluruh kolam | ❌ |
| GET | `/api/public/stats` | Statistik publik tambak | ❌ |

### Authentication

| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| POST | `/api/auth/login` | Login user | ❌ |
| POST | `/api/auth/register` | Register user baru | ❌ |
| POST | `/api/auth/logout` | Logout | ✅ |
| GET | `/api/auth/me` | Profil user saat ini | ✅ |

### Protected Endpoints (JWT Required)

#### Manajemen Kolam
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/kolam` | List semua kolam |
| POST | `/api/kolam` | Tambah kolam baru |
| GET | `/api/kolam/{id}` | Detail kolam |
| PUT/PATCH | `/api/kolam/{id}` | Update kolam |
| DELETE | `/api/kolam/{id}` | Hapus kolam (soft delete) |

#### Manajemen Produksi
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/produksi` | List produksi |
| POST | `/api/produksi` | Mulai siklus produksi baru |
| PUT/PATCH | `/api/produksi/{id}` | Update produksi |
| DELETE | `/api/produksi/{id}` | Hapus produksi |

#### Produksi Log (Catatan Harian)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/produksi/log/{kolam_id}` | Log harian per kolam |
| POST | `/api/produksi/log` | Tambah log harian (suhu, pH, DO, TDS, pakan, MBW, kematian) |

#### Manajemen Pakan
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/pakan` | List pakan |
| POST | `/api/pakan` | Tambah catatan pakan |
| GET | `/api/pakan/statistik` | Statistik pakan |

#### Manajemen Panen
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/panen` | List panen |
| POST | `/api/panen` | Catat panen baru |
| GET | `/api/panen/statistik` | Statistik panen |

#### Monitoring & Devices
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/monitoring/latest` | Data monitoring terbaru semua sensor |
| GET | `/api/devices` | List perangkat IoT |
| GET | `/api/devices/{id}/sensors` | Sensor pada perangkat |
| PUT | `/api/devices/{id}/calibration` | Kalibrasi sensor |
| POST | `/api/relay` | Kontrol relay (batch) |

#### Users (Super Admin & Admin only)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/users` | List user |
| POST | `/api/users` | Tambah user |
| PUT/PATCH | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Hapus user |

#### Laporan
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/laporan/{kolam_id}` | Laporan agregat per kolam |

---

## 🖼️ Screenshots

> *(Tambahkan screenshot aplikasi di sini)*

| Halaman | Preview |
|---------|---------|
| **Landing Page** | `public/hero-aquaculture.jpg` |
| **Dashboard Admin** | _Coming Soon_ |
| **Monitoring Real-time** | _Coming Soon_ |

---

## 🚀 Penggunaan

### Akses Aplikasi

1. Buka browser dan akses `http://localhost:5173`
2. Halaman landing akan menampilkan informasi umum, fitur, dan live stats
3. Klik "Login" atau "Mulai Sekarang" untuk membuka modal login
4. Masukkan kredensial (default dari seeder: `admin@example.com` / `password`)
5. Setelah login, Anda akan diarahkan ke **Dashboard Admin**

### Alur Manajemen Tambak

```
1. Tambah Kolam          → Kelola /admin/kolam
2. Mulai Produksi        → Atur benur di /admin/produksi
3. Catat Log Harian      → Input data pakan, MBW, kematian, kualitas air
4. Monitoring            → Pantau sensor real-time di /admin/monitoring
5. Catat Panen           → Parsial/total di /admin/panen
6. Lihat Laporan         → Data agregat untuk evaluasi
```

### MQTT Real-time Monitoring

Sistem secara otomatis terhubung ke broker MQTT untuk menerima data sensor dari perangkat IoT di tambak. Data yang diterima meliputi:

- 🌡️ **Suhu** (°C)
- 🧪 **pH** Air
- 💨 **DO** (Dissolved Oxygen / Oksigen Terlarut)
- 💧 **TDS** (Total Dissolved Solids)

Data sensor diperbarui secara langsung di halaman monitoring tanpa perlu refresh halaman.

---

## 🗺️ Roadmap

- [x] Landing page interaktif dengan animasi 3D
- [x] CRUD kolam, produksi, pakan, panen
- [x] Monitoring real-time via MQTT
- [x] JWT Authentication & RBAC
- [ ] **Laporan PDF** — Export laporan ke PDF
- [ ] **Notifikasi Real-time** — Integrasi WebSocket untuk notifikasi
- [ ] **Mobile App** — Aplikasi mobile (React Native)
- [ ] **Multi Tenant** — Dukungan multi pemilik tambak
- [ ] **AI Prediction** — Prediksi panen dan deteksi anomali
- [ ] **Grafik Lanjutan** — Visualisasi tren kualitas air
- [ ] **Dark Mode** — Tema gelap

---

## 🤝 Kontribusi

Kontribusi selalu diterima dengan tangan terbuka! Berikut langkah-langkahnya:

1. **Fork** repository ini
2. Buat **branch** baru (`git checkout -b feat/fitur-keren`)
3. **Commit** perubahan Anda (`git commit -m 'feat: tambah fitur keren'`)
4. **Push** ke branch (`git push origin feat/fitur-keren`)
5. Buat **Pull Request**

### Panduan Kontribusi

- Ikuti struktur kode yang sudah ada (Component-based untuk frontend, Controller-Service untuk backend)
- Untuk frontend: baca [`src/agent.md`](web/src/agent.md) dan [`api_contract.md`](web/src/api_contract.md)
- Untuk design: baca [`src/design.md`](web/src/design.md) — jangan ubah sistem desain yang ada
- Pastikan API mengikuti kontrak yang sudah ditentukan di [`api_contract.md`](web/src/api_contract.md)
- Gunakan commit message yang deskriptif (conventional commits)

---

## 📄 Lisensi

Hak Cipta © 2025 **Tambak Udang Sampang**.

Dilarang mendistribusikan, memodifikasi, atau menggunakan perangkat lunak ini tanpa izin tertulis dari pemilik hak cipta.

---

<p align="center">
  Dibuat dengan ❤️ untuk petambak udang Indonesia
  <br />
  <a href="https://github.com/your-username/Tambak-Udang-Sampang">GitHub</a>
  ·
  <a href="#daftar-isi">Kembali ke Atas</a>
</p>
