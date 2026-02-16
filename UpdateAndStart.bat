@echo off
REM ========================================
REM OPTIONAL: Non-Docker Update + Start Script
REM ========================================
REM
REM This script updates SillyTavern from git and runs it natively (NOT in Docker).
REM
REM RECOMMENDED: Use Docker instead
REM   git pull
REM   docker compose build --no-cache
REM   docker compose up
REM
REM See README_DOCKER.md for Docker setup
REM See STARTUP_SCRIPTS_GUIDE.md for all startup options
REM
REM Prerequisites for this script:
REM   - Git must be installed: https://git-scm.com/downloads
REM   - Node.js must be installed: https://nodejs.org/
REM   - Project must be cloned via git
REM
REM ========================================

pushd %~dp0
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [91mGit is not installed on this system.[0m
    echo Install it from https://git-scm.com/downloads
    goto end
) else (
    if not exist .git (
        echo [91mNot running from a Git repository. Reinstall using an officially supported method to get updates.[0m
        echo See: https://docs.sillytavern.app/installation/windows/
        goto end
    )
    call git pull --rebase --autostash
    if %errorlevel% neq 0 (
        REM incase there is still something wrong
        echo [91mThere were errors while updating.[0m
        echo See the update FAQ at https://docs.sillytavern.app/installation/updating/
        goto end
    )
)
set NODE_ENV=production
call npm install --no-save --no-audit --no-fund --loglevel=error --no-progress --omit=dev
node server.js %*
:end
pause
popd
