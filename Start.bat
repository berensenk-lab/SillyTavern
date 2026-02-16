@echo off
REM ========================================
REM OPTIONAL: Non-Docker Startup Script
REM ========================================
REM
REM This script runs SillyTavern natively on your machine (NOT in Docker).
REM
REM RECOMMENDED: Use Docker instead
REM   docker compose up
REM
REM See README_DOCKER.md for Docker setup
REM See STARTUP_SCRIPTS_GUIDE.md for all startup options
REM
REM Prerequisites for this script:
REM   - Node.js must be installed: https://nodejs.org/
REM   - npm must be available in PATH
REM
REM ========================================

pushd %~dp0
set NODE_ENV=production
call npm install --no-save --no-audit --no-fund --loglevel=error --no-progress --omit=dev
node server.js %*
pause
popd
