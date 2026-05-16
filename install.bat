@echo off
:: ============================================================
::  Sentinel Security Monitor — Windows Installer
::  Führe dieses Script als normaler Benutzer aus (kein Admin nötig)
:: ============================================================
setlocal EnableDelayedExpansion
title Sentinel Installer

echo.
echo  =========================================
echo   ^|  Sentinel Security Monitor v1.0     ^|
echo   ^|  Windows Installer                  ^|
echo  =========================================
echo.

:: ── 1. Python prüfen ────────────────────────────────────────
echo [1/6] Prüfe Python Installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  FEHLER: Python wurde nicht gefunden!
    echo.
    echo  Bitte installiere Python 3.12+ von:
    echo  https://www.python.org/downloads/
    echo.
    echo  WICHTIG: Hake bei der Installation
    echo  "Add Python to PATH" an!
    echo.
    pause
    start https://www.python.org/downloads/
    exit /b 1
)

for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYVER=%%v
echo  Python %PYVER% gefunden. OK

:: Mindestversion 3.12 prüfen
for /f "tokens=1,2 delims=." %%a in ("%PYVER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)
if %PY_MAJOR% LSS 3 (
    echo  FEHLER: Python 3.12+ benötigt!
    pause & exit /b 1
)
if %PY_MAJOR% EQU 3 if %PY_MINOR% LSS 12 (
    echo  WARNUNG: Python 3.12+ empfohlen. Gefunden: %PYVER%
    echo  Es wird trotzdem versucht fortzufahren...
)

:: ── 2. Virtuelle Umgebung erstellen ────────────────────────
echo.
echo [2/6] Erstelle virtuelle Umgebung (.venv)...
if exist .venv (
    echo  .venv bereits vorhanden - wird übersprungen.
) else (
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo  FEHLER: Konnte .venv nicht erstellen!
        pause & exit /b 1
    )
    echo  .venv erstellt. OK
)

:: ── 3. pip aktualisieren ────────────────────────────────────
echo.
echo [3/6] Aktualisiere pip...
.venv\Scripts\python.exe -m pip install --upgrade pip --quiet
echo  pip aktualisiert. OK

:: ── 4. Abhängigkeiten installieren ──────────────────────────
echo.
echo [4/6] Installiere Abhängigkeiten (kann 2-5 Minuten dauern)...
.venv\Scripts\pip.exe install -r requirements.txt --quiet
if %errorlevel% neq 0 (
    echo.
    echo  FEHLER beim Installieren der Abhängigkeiten!
    echo  Versuche erneut mit ausführlicher Ausgabe...
    .venv\Scripts\pip.exe install -r requirements.txt
    pause & exit /b 1
)
echo  Alle Pakete installiert. OK

:: ── 5. .env Konfiguration erstellen ─────────────────────────
echo.
echo [5/6] Erstelle Konfigurationsdatei...
if exist .env (
    echo  .env bereits vorhanden - wird nicht überschrieben.
) else (
    copy .env.example .env >nul
    echo  .env aus Vorlage erstellt.
    echo.
    echo  WICHTIG: Trage deinen VirusTotal API Key ein!
    echo  Öffne .env mit einem Texteditor und setze:
    echo  SENTINEL_VT_API_KEY=dein_key_hier
    echo.
    echo  Kostenlosen Key gibt es unter:
    echo  https://www.virustotal.com/gui/sign-in
)

:: ── 6. Desktop-Verknüpfung erstellen ────────────────────────
echo.
echo [6/6] Erstelle Desktop-Verknüpfung...
set SCRIPT_DIR=%~dp0
set SHORTCUT=%USERPROFILE%\Desktop\Sentinel.lnk

:: PowerShell Shortcut erstellen
powershell -Command ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$s = $ws.CreateShortcut('%SHORTCUT%');" ^
  "$s.TargetPath = '%SCRIPT_DIR%start.bat';" ^
  "$s.WorkingDirectory = '%SCRIPT_DIR%';" ^
  "$s.Description = 'Sentinel Security Monitor';" ^
  "$s.Save()" >nul 2>&1

if exist "%SHORTCUT%" (
    echo  Desktop-Verknüpfung erstellt. OK
) else (
    echo  Verknüpfung konnte nicht erstellt werden - kein Problem,
    echo  starte Sentinel mit: start.bat
)

:: ── Fertig ───────────────────────────────────────────────────
echo.
echo  =========================================
echo   Installation abgeschlossen!
echo  =========================================
echo.
echo  Nächste Schritte:
echo   1. Öffne .env und trage deinen VT API Key ein
echo   2. Starte Sentinel mit: start.bat
echo      oder per Desktop-Verknüpfung
echo.
echo  VirusTotal Key holen (kostenlos):
echo  https://www.virustotal.com/gui/sign-in
echo.

set /p OPEN_ENV="Möchtest du .env jetzt öffnen? (j/n): "
if /i "%OPEN_ENV%"=="j" (
    notepad .env
)

set /p START_NOW="Sentinel jetzt starten? (j/n): "
if /i "%START_NOW%"=="j" (
    call start.bat
)

endlocal
