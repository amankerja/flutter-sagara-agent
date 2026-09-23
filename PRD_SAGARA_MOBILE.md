# PRD: Sagara Mobile (Virtual Office & Agent Mission Control)
**Versi:** 1.3.1 (Hermes Real State & Live Fleet Synchronized)  
**Target Platform:** Android (Flutter SDK ^3.11.5 / Flutter 3.41+)  
**Referensi Induk:** [amankerja/virtual-office-sagara-agent (GitHub origin/main)](https://github.com/amankerja/virtual-office-sagara-agent.git)  
**Production Host:** `https://office.alkaralintas.site`  
**Status:** IMPLEMENTED, VERIFIED & SYNCHRONIZED (READY FOR LOCAL PC DEVELOPMENT)  

---

## 1. Executive Summary & Visi Produk

### 1.1 Latar Belakang & Sinkronisasi Real Fleet
Sagara Mission Control menyajikan kontrol operasi agen AI otonom berbasis arsitektur Hermes Agent dan Sagara Platform. Seluruh kontrak data, API FastAPI, adapter SQLite/Hermes, dan antarmuka Command Center telah diverifikasi langsung dari cabang terbaru GitHub (`origin/main`).

Pada versi 1.3.1:
- **Model Standardized:** Menggunakan model kanonikal `SAGARA-AGENTIC-AI-1` pada seluruh model agen & sesi chat.
- **Provider Standardized:** Default provider `sagara` (menghapus residu mock `anthropic`).
- **Live Hermes Log Aggregation:** Endpoint `/api/v1/sessions/{id}/logs` terhubung langsung untuk menampilkan streaming pesan riil dari database SQLite Hermes (`state.db`).
- **Governance Metrics API:** Menambahkan integrasi endpoint `/api/v1/governance` untuk inspeksi konsumsi token dan burn rate harian.
- **9 Profil Kanonikal Lengkap:** `lead`, `it-coding`, `it-support`, `marketing`, `cs`, `business`, `personal`, `sagara-lab`, dan `exportir-handal`.
- **SOUL.md Template Lengkap:** Setiap agen memiliki berkas persona sistem yang utuh (*Operational Title, Mission, Responsibilities, Working Style, Decision Boundaries, Delegation Policy, Channel Routes, Workspace Policy*).
- **Dual Schema Support:** Adapter data mendukung `snake_case` (FastAPI VPS backend: `session_count`, `allowed_skills`, `estimated_cost_usd`) dan `camelCase` (TypeScript frontend mocks) secara otomatis.

### 1.2 Visi & Filosofi: *"Simple tapi Berguna Sekali"*
Mengemas seluruh kekuatan operasional Sagara Mission Control ke dalam genggaman Android (mobile-first):
- **Super Cepat & Ringan:** Tidak menggunakan render 3D Three.js yang berat; digantikan dengan visual 2D Floorplan & Direktori Profil 9 Agen yang responsif dan hemat baterai.
- **Tindakan Instan (Action-Oriented):** 1-tap approvals, task dispatch langsung ke Lead Orchestrator, inspeksi profil agen/SOUL, penjadwalan berkala (*cron/schedules*), dan tombol darurat *kill-switch*.
- **Konektivitas Fleksibel & Realtime Stream:** Terhubung ke backend VPS melalui REST API dan streaming **WebSocket Realtime (`/realtime/ws`)**, dilengkapi notifikasi alarm suara & getaran untuk aksi berisiko tinggi, serta memiliki *Offline Demo Mode* dengan dataset asli dari GitHub.

---

## 2. Status Implementasi Fitur (Feature Matrix)

| Modul | Status | Deskripsi & Implementasi di Kode |
| :--- | :---: | :--- |
| **1. Command Center & Infra Strip** | ✅ **SELESAI** | Pantauan CPU Load (%), RAM Used (MB/GB), Disk Space (GB), Host Uptime, Hermes Gateway pulse, Work Queue counters, Attention Queue, dan Recent Activity log. |
| **2. 9 Profil Agen & SOUL.md** | ✅ **SELESAI** | 9 Profil resmi (`lead`, `it-coding`, `it-support`, `marketing`, `cs`, `business`, `personal`, `sagara-lab`, `exportir-handal`) dengan inspeksi file prompt `SOUL.md` persona, channel routes, workspace policy, model policy, dan skill matrix. |
| **3. Lead Orchestrator & Delegations** | ✅ **SELESAI** | Pohon rantai delegasi sub-tugas (*Parent Task -> Worker Agent PID -> Status Delegasi*), dekomposisi tugas, dan ringkasan hasil kerja. |
| **4. Tasks Management & Kanban** | ✅ **SELESAI** | Segmented status bar (`RUNNING`, `READY`, `AWAITING_APPROVAL`, `COMPLETED`, `FAILED`), Quick Dispatch FAB, pembatalan tugas berjalan, dan pelacakan status. |
| **5. 1-Tap Human-in-the-Loop Approvals** | ✅ **SELESAI** | Kartu approval berjenjang risiko (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`), preview kode/query monospace, tombol **[1-Tap Setujui]** & **[Tolak]**, sinkronisasi bot Telegram, dan badge counter di bottom bar. |
| **6. 2D Interactive Virtual Office** | ✅ **SELESAI** | Pengganti Three.js 3D: Peta 2D vektor denah 4 zona kantor (*Command Room, Engineering Lab, Growth Studio, Research Lounge*), pulsing status ring avatar, dan toggle ke **Direktori 9 Profil & SOUL**. |
| **7. Automated Schedule & Cron** | ✅ **SELESAI** | Agenda rutinitas otomatis (WAL backup, latency probe, retrospective, Telegram briefing), format cron monospace, dan tombol *"Picu Sekarang / Run Now"*. |
| **8. Realtime WebSocket Stream (`/realtime/ws`)** | ✅ **SELESAI** | Protokol v1, streaming pesan `snapshot` & `delta`, auto-reconnect 5 detik, auto-sync data secara senyap (*silent update*), dan engine simulasi live ticks di Mode Demo. |
| **9. Audio Alert & Push Notification HP** | ✅ **SELESAI** | Saluran notifikasi prioritas tinggi Android (`sagara_critical_channel`), dering alarm sistem (`SystemSound.play`), getaran taktil berulang (`HapticFeedback.heavyImpact`), dan banner darurat in-app. |
| **10. Emergency Kill-Switch & Dual Mode** | ✅ **SELESAI** | Global Freeze Lockout darurat di top bar, switch instan Live VPS (`office.alkaralintas.site`) vs Demo Mock Mode, dan tombol pengujian alarm suara. |

---

## 3. Direktori 9 Profil Kanonikal & Arsitektur Sagara Fleet

1. **Lead Manager Agent (`lead`)**:
   - Title: *Fleet Operations Coordinator & Triage Director*
   - Model Policy: `primary=flagship, fallback=balanced`
   - Channel Routes: `#agent-status`, `#alerts`, `#cron`, `#gateway-status`, `#sagara-command`, `#system-alerts`
2. **IT Coding Agent (`it-coding`)**:
   - Title: *Software Engineer & Technical Development Specialist*
   - Model Policy: `primary=coding, fallback=balanced`
   - Channel Routes: `#agent-coding-1`
3. **IT Support Sentinel Agent (`it-support`)**:
   - Title: *Systems Reliability & Operational Monitoring Specialist*
   - Model Policy: `primary=balanced, fallback=fast`
   - Channel Routes: `#it-support-self-healing`
4. **Marketing & Content Agent (`marketing`)**:
   - Title: *Creative Content & Multichannel Growth Specialist*
   - Model Policy: `primary=balanced, fallback=fast`
   - Channel Routes: `#marketing`
5. **Customer Service Agent (`cs`)**:
   - Title: *Customer Support & Order Fulfillment Coordinator*
   - Model Policy: `primary=fast, fallback=balanced`
   - Channel Routes: `#customer-service`
6. **Business Strategy Agent (`business`)**:
   - Title: *Commercial Strategy & Product Operations Specialist*
   - Model Policy: `primary=flagship, fallback=balanced`
   - Channel Routes: `#orders`, `#products`
7. **Personal Assistant Agent (`personal`)**:
   - Title: *Executive Personal Assistant & Schedule Coordinator*
   - Model Policy: `primary=balanced, fallback=fast`
   - Channel Routes: `#assistant`, `#career`, `#personal-finance`, `#reminders`
8. **Sagara Lab R&D Agent (`sagara-lab`)**:
   - Title: *R&D & Architectural Experimentation Specialist*
   - Model Policy: `primary=research, fallback=balanced`
   - Channel Routes: `#sagara-lab`
9. **Exportir Handal Specialist (`exportir-handal`)**:
   - Title: *Cross-Border Commerce & Export Logistics Specialist*
   - Model Policy: `primary=balanced, fallback=fast`
   - Channel Routes: `#export-trade`, `#customs-docs`

---

## 4. Arsitektur Teknis & Struktur Proyek

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart             # OFALabs Minimalist Palette (Slate & Blue)
│   ├── network/
│   │   └── realtime_sync_service.dart  # WebSocket client (/realtime/ws) & polling
│   ├── services/
│   │   └── notification_service.dart   # FlutterLocalNotifications, suara alarm & haptic
│   └── theme/
│       └── app_theme.dart              # Material 3 flat, border 1px, no gradients
├── data/
│   ├── mocks/
│   │   └── sagara_mock_data.dart       # 9 Profil Kanonikal & SOUL template asli GitHub
│   ├── models/
│   │   ├── agent_model.dart            # Dual schema snake_case & camelCase parser
│   │   ├── approval_model.dart         # Approval, Risk, & Preview models
│   │   ├── profile_model.dart          # Canonical Profile & SOUL prompt models
│   │   ├── schedule_model.dart         # Schedule & Cron models
│   │   ├── system_pulse_model.dart     # Gateway, Infra, & Attention models
│   │   └── task_model.dart             # Task & Sub-task Delegation models
│   └── repositories/
│       └── sagara_repository.dart      # Dual-mode repository (REST API / Mock)
├── providers/
│   ├── agent_provider.dart             # State agen & profil SOUL
│   ├── app_state_provider.dart         # State global, sync status, & high-risk alert
│   ├── approval_provider.dart          # State approval 1-tap & counter
│   ├── schedule_provider.dart          # State agenda & cron automation
│   └── task_provider.dart              # State task dispatch & filters
├── screens/
│   ├── approvals/
│   │   └── approvals_screen.dart       # Tab 2: 1-Tap Approvals & Telegram Sync
│   ├── command/
│   │   └── command_center_screen.dart  # Tab 1: Infra Strip & Work Queue
│   ├── office_2d/
│   │   └── office_2d_screen.dart       # Tab 3: Denah 2D + Direktori 9 Profil & SOUL
│   ├── schedule/
│   │   └── schedule_screen.dart        # Tab 5: Cron Schedule & Run Now
│   ├── tasks/
│   │   └── tasks_screen.dart           # Tab 4: Tasks & Lead Delegation Tree
│   └── main_shell_screen.dart          # Top Bar, Kill-Switch, & Bottom Nav Bar
├── widgets/
│   ├── approval_detail_sheet.dart      # Sheet preview payload & approval decision
│   ├── attention_card.dart             # Alert card untuk attention queue
│   ├── create_task_sheet.dart          # Modal dispatch task baru
│   ├── metric_tile.dart                # Tile metrik CPU/RAM/Disk/Uptime
│   ├── profile_bottom_sheet.dart       # Sheet inspeksi agen & SOUL.md prompt
│   ├── settings_dialog.dart            # Dialog koneksi, mode, & uji coba alarm
│   └── status_pill.dart                # Semantic status badges (OFALabs)
└── main.dart                           # Entry point, MultiProvider initialization
```
