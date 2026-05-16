@echo off
:: ============================================================
::  Sentinel — Windows Funktionstest
::  Testet alle Kernfunktionen ohne GUI und ohne Internet
:: ============================================================
title Sentinel — Windows Test
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo  ============================================
echo   Sentinel Windows Funktionstest
echo  ============================================
echo.

set PYTHON=.venv\Scripts\python.exe
set PASS=0
set FAIL=0

if not exist "%PYTHON%" (
    echo  FEHLER: .venv nicht gefunden - zuerst install.bat ausfuehren!
    pause & exit /b 1
)

:: ── Test 1: Python-Imports ───────────────────────────────────
echo [Test 1] Python-Imports...
%PYTHON% -c "from core.config import Config; from core.models import ScanResult, ThreatLevel; print('OK')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN
    set /a FAIL+=1
)

:: ── Test 2: PySide6 GUI ──────────────────────────────────────
echo.
echo [Test 2] PySide6 GUI-Bibliothek...
%PYTHON% -c "from PySide6.QtWidgets import QApplication; print('OK')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN - pip install PySide6
    set /a FAIL+=1
)

:: ── Test 3: Watchdog Windows Observer ───────────────────────
echo.
echo [Test 3] Watchdog Windows-Observer...
%PYTHON% -c "from watchdog.observers.winapi import WindowsApiObserver; print('OK')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN (nativer Windows-Observer)
    set /a PASS+=1
) else (
    echo  INFO: Fallback-Observer wird verwendet
    set /a PASS+=1
)

:: ── Test 4: python-magic MIME-Erkennung ─────────────────────
echo.
echo [Test 4] MIME-Erkennung (python-magic-bin)...
%PYTHON% -c "import magic; print('OK')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  INFO: Fallback-Erkennung aktiv (kein python-magic)
    set /a PASS+=1
)

:: ── Test 5: Dateianalyse ─────────────────────────────────────
echo.
echo [Test 5] Dateianalyse (SHA-256, Entropy, Patterns)...
%PYTHON% -c ^
"from pathlib import Path; import tempfile; from scanner.file_analyzer import FileAnalyzer; ^
f=tempfile.NamedTemporaryFile(suffix='.txt',delete=False); ^
f.write(b'powershell -ExecutionPolicy Bypass -WindowStyle Hidden'); f.close(); ^
a=FileAnalyzer(); m=a.analyze(Path(f.name)); ^
print('SHA256:', m.sha256[:16]+'...'); ^
print('Patterns:', m.suspicious_patterns); ^
Path(f.name).unlink()" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN
    set /a FAIL+=1
)

:: ── Test 6: Datenbank ────────────────────────────────────────
echo.
echo [Test 6] SQLite-Datenbank...
%PYTHON% -c ^
"from pathlib import Path; import tempfile; from database.db_manager import DatabaseManager; ^
from core.models import ScanResult, ScanStatus, ThreatLevel; ^
d=tempfile.mkdtemp(); db=DatabaseManager(Path(d)/'test.db'); ^
db.initialize(); r=ScanResult(file_path='C:/test.exe',filename='test.exe', ^
status=ScanStatus.COMPLETE,threat_level=ThreatLevel.CLEAN); ^
db.save_scan(r); s=db.get_stats(); print('Gesamt:',s['total']); print('OK')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN
    set /a FAIL+=1
)

:: ── Test 7: Windows-Pfade ────────────────────────────────────
echo.
echo [Test 7] Windows Download-Ordner...
%PYTHON% -c ^
"from pathlib import Path; d=Path.home()/'Downloads'; ^
print('Pfad:', d); print('Existiert:', d.exists())" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN
    set /a FAIL+=1
)

:: ── Test 8: VirusTotal API Key ───────────────────────────────
echo.
echo [Test 8] VirusTotal Konfiguration...
%PYTHON% -c ^
"from core.config import Config; c=Config(); ^
print('API Key konfiguriert:', c.vt_configured); ^
print('Rate Limit:', c.vt_rate_limit, 'req/min')" 2>&1
if %errorlevel% equ 0 (
    echo  BESTANDEN
    set /a PASS+=1
) else (
    echo  FEHLGESCHLAGEN
    set /a FAIL+=1
)

:: ── Test 9: EICAR Test-Datei (optional) ─────────────────────
echo.
echo [Test 9] EICAR Testdatei in Downloads-Ordner...
echo  (Erstellt eine HARMLOSE Testdatei fuer Sentinel)
set /p DO_EICAR="EICAR-Test erstellen? (j/n): "
if /i "%DO_EICAR%"=="j" (
    %PYTHON% -c ^
    "from pathlib import Path; ^
    p=Path.home()/'Downloads'/'eicar_test.txt'; ^
    p.write_text('X5O!P%%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'); ^
    print('EICAR-Datei erstellt:', p); ^
    print('Sentinel sollte sie jetzt automatisch scannen!')" 2>&1
    if %errorlevel% equ 0 (
        echo  BESTANDEN - Schau in Sentinel rein!
        set /a PASS+=1
    ) else (
        echo  FEHLGESCHLAGEN
        set /a FAIL+=1
    )
) else (
    echo  Uebersprungen.
)

:: ── Ergebnis ─────────────────────────────────────────────────
echo.
echo  ============================================
echo   Testergebnis: !PASS! bestanden, !FAIL! fehlgeschlagen
echo  ============================================
echo.

if !FAIL! equ 0 (
    echo  Alles OK! Starte Sentinel mit: start.bat
) else (
    echo  Einige Tests fehlgeschlagen.
    echo  Prüfe die Fehlermeldungen oben.
    echo  Versuche: pip install -r requirements.txt
)

echo.
pause
endlocal
