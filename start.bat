@echo off
:: Sentinel starten ohne CMD-Fenster
:: Nutzt VBScript als Zwischenstufe

set SCRIPT_DIR=%~dp0

:: Prüfe ob .venv existiert
if not exist "%SCRIPT_DIR%.venv\Scripts\pythonw.exe" (
    echo FEHLER: .venv nicht gefunden! Bitte install.bat ausfuehren.
    pause
    exit /b 1
)

:: Starte via VBScript (kein CMD-Fenster)
if exist "%SCRIPT_DIR%start_hidden.vbs" (
    wscript.exe "%SCRIPT_DIR%start_hidden.vbs"
) else (
    :: Fallback: normaler Start
    cd /d "%SCRIPT_DIR%"
    start "" "%SCRIPT_DIR%.venv\Scripts\pythonw.exe" "%SCRIPT_DIR%main.py"
)
