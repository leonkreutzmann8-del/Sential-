# 🛡 Sentinel Security Monitor

A **Windows Defender-inspired** malware analysis tool that monitors your Downloads folder and scans new files using the [VirusTotal](https://www.virustotal.com) API.

> **Defensive & Educational** — Sentinel *never* deletes, modifies, executes, or blocks any file.  
> It is a read-only analysis tool designed to give you visibility into what lands in your Downloads folder.

---

## Screenshots

```
┌──────────────────────────────────────────────────────────────────────────┐
│ 🛡 SENTINEL    │  Security Dashboard                          14:32:05   │
│ Security Monitor│  ─────────────────────────────────────────────────────  │
│─────────────────│                                                          │
│  Dashboard   ●  │  ┌──────────────┐  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│  Live Feed      │  │  ✓ ALL CLEAR │  │ 142  │ │ 138  │ │  3   │ │  1   ││
│  History        │  │              │  │Total │ │Clean │ │Susp. │ │Malic.││
│  Settings       │  └──────────────┘  └──────┘ └──────┘ └──────┘ └──────┘│
│                 │                                                          │
│ ● MONITORING    │  RECENT ALERTS          DETECTION BREAKDOWN             │
│   ACTIVE        │  ┌─────────────────┐   Clean      ████████████ 97%     │
│ 📁 Downloads    │  │ ⚠️ invoice.exe  │   Suspicious ▌           2%      │
└─────────────────┘  │ 3/72 detections │   Malicious  ▌           1%      │
                     └─────────────────┘                                    │
```

---

## Features

| Feature | Description |
|---|---|
| 📡 **Live Monitoring** | Watches your Downloads folder using OS-native file events |
| 🔍 **Local Analysis** | SHA-256, MD5, entropy, MIME type, extracted strings |
| 🎯 **Pattern Detection** | PowerShell, certutil, base64, LOLBins, registry persistence |
| 🦠 **YARA Rules** | Plug-in rule files for custom threat signatures |
| 🌐 **VirusTotal** | Hash lookup first (no upload if known), upload if new |
| 📊 **72 AV Engines** | Full per-vendor detection table |
| 🗄️ **SQLite History** | All results persisted, searchable, exportable |
| 📄 **PDF Reports** | Professional scan report export |
| 🎨 **Dark UI** | Windows Defender–inspired dark-mode interface |

---

## Installation

### Requirements

- **Python 3.12+**
- **Windows 10/11** (primary target; works on macOS/Linux with minor differences)

### 1. Clone / download

```bash
git clone https://github.com/yourname/sentinel.git
cd sentinel
```

### 2. Create virtual environment

```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

> **Windows note:** `python-magic-bin` is used for MIME detection on Windows (no libmagic install needed).  
> On Linux/macOS, install `libmagic` via your package manager: `sudo apt install libmagic1` / `brew install libmagic`

### 4. Configure

```bash
cp .env.example .env
# Edit .env and add your VirusTotal API key
```

### 5. Run

```bash
python main.py
```

---

## VirusTotal Setup Guide

### Getting a Free API Key

1. Go to [https://www.virustotal.com/gui/sign-in](https://www.virustotal.com/gui/sign-in)
2. Create a free account
3. Click your avatar → **API Key**
4. Copy the 64-character key

### Adding the Key to Sentinel

**Option A — .env file (recommended):**
```
SENTINEL_VT_API_KEY=your64charkey...
```

**Option B — Settings page:**  
Open Sentinel → Settings → VirusTotal API → paste key → Save

**Option C — Environment variable:**
```bash
# Windows PowerShell
$env:SENTINEL_VT_API_KEY = "your64charkey..."
python main.py

# Linux / macOS
SENTINEL_VT_API_KEY="your64charkey..." python main.py
```

### Free Tier Limits

| Quota | Limit |
|---|---|
| Requests per minute | 4 |
| Requests per day | 500 |
| Max file upload size | 32 MB |

Sentinel's built-in rate limiter respects these limits automatically.

---

## Architecture

```
sentinel/
├── main.py                  # Entry point
├── .env.example             # Config template
├── requirements.txt
│
├── core/                    # Shared, dependency-free layer
│   ├── config.py            # All configuration (env vars / .env)
│   ├── logger.py            # Structured logging setup
│   └── models.py            # Data classes: FileMetadata, VTReport, ScanResult
│
├── scanner/                 # File analysis pipeline
│   ├── file_analyzer.py     # SHA-256/MD5, entropy, strings, patterns, YARA
│   ├── folder_watcher.py    # watchdog-based Downloads monitor
│   └── scan_queue.py        # Thread-safe queue + rate limiter
│
├── vt_api/                  # VirusTotal client
│   └── vt_client.py         # Hash lookup → upload → poll → parse
│
├── database/                # Persistence
│   └── db_manager.py        # SQLite CRUD (thread-safe, WAL mode)
│
├── gui/                     # PySide6 user interface
│   ├── main_window.py       # Root window + navigation
│   ├── styles.py            # Global dark-mode stylesheet + colour palette
│   └── pages/
│       ├── dashboard.py     # KPI cards, threat badge, alerts
│       ├── scan_feed.py     # Live scrolling scan events
│       ├── history.py       # Searchable/filterable history table
│       ├── file_detail.py   # Full detail: hashes, VT table, entropy
│       └── settings.py      # API key, watch path, rate limits
│
├── utils/
│   └── report_generator.py  # PDF export via ReportLab
│
└── assets/
    └── yara_rules/
        └── sentinel_default.yar  # Built-in YARA rules
```

---

## How It Works

```
Downloads folder
      │
      │  (new file appears)
      ▼
FolderWatcher (watchdog)
      │
      │  path → enqueue()
      ▼
ScanQueue (background threads)
      │
      ├─ 1. FileAnalyzer.analyze()
      │      ├── SHA-256 + MD5
      │      ├── MIME type detection
      │      ├── Shannon entropy
      │      ├── Printable string extraction
      │      ├── Suspicious pattern matching
      │      └── YARA rules
      │
      ├─ 2. Deduplication check (skip if hash seen)
      │
      ├─ 3. VTClient.lookup_or_upload()
      │      ├── GET /files/{sha256}  (hash lookup)
      │      ├── If unknown: POST /files  (upload)
      │      └── GET /analyses/{id}  (poll until complete)
      │
      ├─ 4. Risk score computation (0–100)
      │
      ├─ 5. DatabaseManager.save_scan()
      │
      └─ 6. Qt signal → GUI update
```

---

## YARA Rules

Place `.yar` or `.yrc` rule files in `assets/yara_rules/`.  
They are compiled and run against every new file automatically.

Built-in rules detect:
- PowerShell download cradles
- Base64-encoded payloads
- Mimikatz strings
- Registry persistence keys
- Certutil LOLBin abuse
- Ransomware note strings

---

## Security Design

Sentinel is built with a strict **read-only, defensive** philosophy:

| What Sentinel does ✅ | What Sentinel NEVER does ❌ |
|---|---|
| Read file bytes for hashing | Delete or modify files |
| Submit hashes/files to VT | Execute or open files |
| Display analysis results | Hook kernel APIs |
| Store results in SQLite | Inject into processes |
| Alert on threats | Bypass OS security |
| Export PDF reports | Create persistence |

---

## Optional Dependencies

| Package | Feature | Required? |
|---|---|---|
| `yara-python` | YARA rule scanning | Optional |
| `reportlab` | PDF report export | Optional |
| `python-magic` / `python-magic-bin` | Accurate MIME detection | Optional (fallback built-in) |
| `plyer` | System tray notifications | Optional |
| `python-dotenv` | `.env` file support | Optional |

---

## Troubleshooting

**"No VirusTotal API key configured"**  
→ Add `SENTINEL_VT_API_KEY=...` to `.env` or the Settings page.

**"python-magic" import error on Windows**  
→ `pip install python-magic-bin` (includes bundled DLL)

**YARA rules not loading**  
→ `pip install yara-python`; ensure rules are in `assets/yara_rules/*.yar`

**Rate limit errors from VirusTotal**  
→ Reduce `SENTINEL_VT_RATE_LIMIT` in `.env` (default: 4/min for free tier)

---

## License

MIT — Educational and defensive use only.

---

*Sentinel is not affiliated with Microsoft or VirusTotal / Google.*
