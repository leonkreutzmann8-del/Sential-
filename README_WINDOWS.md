# 🛡 Sentinel Security Monitor — Windows Anleitung

## Voraussetzungen

| Programm | Version | Download |
|---|---|---|
| Python | 3.12+ | https://www.python.org/downloads/ |
| Windows | 10 / 11 | — |

> **Wichtig:** Bei der Python-Installation das Häkchen bei **"Add Python to PATH"** setzen!

---

## Installation (3 Schritte)

### Schritt 1 — Entpacken
Entpacke `sentinel_v1.0.zip` in einen Ordner, z.B.:
```
C:\Users\DeinName\sentinel\
```

### Schritt 2 — Installieren
Doppelklick auf **`install.bat`**

Das Script:
- Prüft Python Installation
- Erstellt virtuelle Umgebung (`.venv`)
- Installiert alle Pakete automatisch
- Erstellt Desktop-Verknüpfung

### Schritt 3 — API Key eintragen
Öffne die Datei `.env` (wird automatisch geöffnet) und trage ein:
```
SENTINEL_VT_API_KEY=dein_64_zeichen_key_hier
```

**Kostenlosen Key holen:**
1. Gehe zu https://www.virustotal.com/gui/sign-in
2. Kostenlosen Account erstellen
3. Avatar oben rechts → **API Key** → kopieren

---

## Starten

**Option A** — Doppelklick auf Desktop-Verknüpfung **Sentinel**

**Option B** — Doppelklick auf **`start.bat`**

**Option C** — PowerShell / CMD:
```powershell
cd C:\Users\DeinName\sentinel
.venv\Scripts\python.exe main.py
```

---

## Testen

### Schnelltest (ohne Internet)
Doppelklick auf **`test_windows.bat`** — testet alle Kernfunktionen.

### EICAR Testdatei (mit VirusTotal)
Die EICAR-Datei ist eine **100% harmlose** Standardtestdatei, die von allen
Antivirenprogrammen erkannt wird — perfekt zum Testen:

```powershell
# In PowerShell ausführen:
$eicar = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
$eicar | Out-File -FilePath "$env:USERPROFILE\Downloads\eicar_test.txt" -NoNewline -Encoding ASCII
```

Sentinel sollte innerhalb von Sekunden die Datei erkennen und
**~70/72 Detektionen** melden. ✅

### Verdächtige Textdatei (lokal, kein Internet)
```powershell
$content = "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command DownloadString('http://test.com')"
$content | Out-File "$env:USERPROFILE\Downloads\test_suspicious.txt"
```
Sentinel erkennt Muster wie `powershell`, `bypass_execution`, `hidden_window`.

### Manuellen Scan starten
Im Menü: **File → Scan File Manually…** → beliebige Datei auswählen

---

## Konfiguration (`.env` Datei)

```ini
# Pflichtfeld — ohne Key kein VT-Scan
SENTINEL_VT_API_KEY=dein_key_hier

# Überwachter Ordner (Standard: C:\Users\Du\Downloads)
SENTINEL_WATCH_PATH=C:\Users\Max\Downloads

# Rate Limit (kostenlos = max. 4 pro Minute)
SENTINEL_VT_RATE_LIMIT=4
```

---

## Häufige Probleme & Lösungen

| Problem | Lösung |
|---|---|
| `Python wurde nicht gefunden` | Python neu installieren, "Add to PATH" ankreuzen |
| `ModuleNotFoundError: PySide6` | `.venv\Scripts\pip install PySide6` |
| `python-magic` Fehler | `.venv\Scripts\pip install python-magic-bin` |
| Kein Downloads-Ordner | `SENTINEL_WATCH_PATH=C:\Users\Du\Desktop` in `.env` |
| VT-Fehler 401 | API Key falsch — neu aus VT-Webseite kopieren |
| VT-Fehler 429 | Rate Limit — `SENTINEL_VT_RATE_LIMIT=2` in `.env` |
| Defender löscht Testdatei | Sentinel-Ordner in Windows Defender ausschließen |
| Schwarzes Fenster erscheint kurz | Normal — das ist das Launcher-Fenster |

---

## Windows Defender Ausnahme (optional)

Falls Windows Defender den Sentinel-Ordner scannt und verlangsamt:

1. Windows Sicherheit öffnen
2. Viren- & Bedrohungsschutz → Einstellungen
3. Ausschlüsse verwalten → Ordner ausschließen
4. Sentinel-Ordner hinzufügen (z.B. `C:\Users\Du\sentinel`)

> Hinweis: Die EICAR-Testdatei **wird** von Windows Defender erkannt und
> möglicherweise gelöscht — das ist normal und korrekt!

---

## Daten & Datenschutz

| Was Sentinel tut ✅ | Was Sentinel NICHT tut ❌ |
|---|---|
| Dateien in Downloads lesen (nur Bytes) | Dateien löschen oder verändern |
| Hashes & Dateien an VirusTotal senden | Dateien ausführen |
| Ergebnisse lokal in SQLite speichern | Kernel-Hooks oder Prozess-Injection |
| Desktop-Benachrichtigungen anzeigen | Automatische Quarantäne |

**Datenbank-Ort:** `C:\Users\DeinName\.sentinel\sentinel.db`  
**Logs:** `C:\Users\DeinName\.sentinel\sentinel.log`  
**Reports:** `C:\Users\DeinName\.sentinel\reports\`

---

## Deinstallation

1. Ordner `sentinel\` löschen
2. Desktop-Verknüpfung löschen
3. Optional: `C:\Users\DeinName\.sentinel\` löschen (Datenbank & Logs)
