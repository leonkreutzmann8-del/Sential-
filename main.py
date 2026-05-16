"""
Sentinel - Windows Defender-Style Malware Analysis Tool
========================================================
Entry point for the Sentinel application.

SECURITY NOTICE:
This tool is purely defensive and educational. It:
 - Does NOT delete, modify, or execute any files
 - Does NOT hook kernel APIs or bypass OS security
 - Does NOT create persistence mechanisms
 - ONLY reads file metadata and submits hashes/files to VirusTotal

Author: Sentinel Security Team
License: MIT (Educational Use)
"""

import sys
import os
import logging

# ---------------------------------------------------------------------------
# Ensure the project root is on sys.path so all sub-packages resolve cleanly
# ---------------------------------------------------------------------------
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt, QCoreApplication
from PySide6.QtGui import QIcon, QFontDatabase, QFont

from core.config import Config
from core.logger import setup_logging
from database.db_manager import DatabaseManager
from gui.main_window import MainWindow


def main() -> int:
    """Application entry point."""

    # ------------------------------------------------------------------
    # 1. Bootstrap logging before anything else
    # ------------------------------------------------------------------
    setup_logging()
    log = logging.getLogger("sentinel.main")
    log.info("Sentinel starting up...")

    # ------------------------------------------------------------------
    # 2. Load configuration (env vars, .env file, defaults)
    # ------------------------------------------------------------------
    config = Config()

    # ------------------------------------------------------------------
    # 3. Initialise the database (creates tables if they don't exist)
    # ------------------------------------------------------------------
    db = DatabaseManager(config.db_path)
    db.initialize()
    log.info("Database ready at %s", config.db_path)

    # ------------------------------------------------------------------
    # 4. Create the Qt application
    # ------------------------------------------------------------------
    # High-DPI scaling
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling, True)
    QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps, True)

    app = QApplication(sys.argv)
    app.setApplicationName("Sentinel")
    app.setApplicationDisplayName("Sentinel Security Monitor")
    app.setOrganizationName("Sentinel")
    app.setOrganizationDomain("sentinel.local")
    app.setApplicationVersion("1.0.0")

    # App-Icon setzen
    _icon_path = Path(PROJECT_ROOT) / "assets" / "sentinel.ico"
    if _icon_path.exists():
        from PySide6.QtGui import QIcon
        app.setWindowIcon(QIcon(str(_icon_path)))

    # ------------------------------------------------------------------
    # 5. Apply global stylesheet
    # ------------------------------------------------------------------
    from gui.styles import GLOBAL_STYLESHEET
    app.setStyleSheet(GLOBAL_STYLESHEET)

    # ------------------------------------------------------------------
    # 6. Launch main window
    # ------------------------------------------------------------------
    window = MainWindow(config=config, db=db)
    window.show()

    log.info("Sentinel GUI ready.")
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
