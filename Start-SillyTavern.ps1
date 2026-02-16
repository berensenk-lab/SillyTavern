# ========================================
# Docker Startup Script (PowerShell)
# ========================================
#
# This script starts SillyTavern + Ollama using Docker Compose
# and opens the UI in your default browser.
#
# RECOMMENDED: Use command line instead
#   docker compose up
#
# Or just double-click this file to start services and open the UI.
#
# See README_DOCKER.md for Docker setup
# See STARTUP_SCRIPTS_GUIDE.md for all startup options
#
# ========================================

cd C:\Users\beren\OneDrive\Documents\GitHub\SillyTavern
docker-compose up -d
Start-Sleep -Seconds 3
Start-Process "http://localhost:8000"
