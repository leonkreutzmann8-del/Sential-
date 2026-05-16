"""
Sentinel Security Monitor
=========================
A Windows Defender-inspired malware analysis tool.

Package structure:
  core/       — configuration, logging, shared data models
  scanner/    — file analysis, folder watcher, scan queue
  vt_api/     — VirusTotal API client
  database/   — SQLite persistence layer
  gui/        — PySide6 user interface
  utils/      — PDF reports, helper functions
"""

__version__ = "1.0.0"
__author__  = "Sentinel Security Team"
