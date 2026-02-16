@echo off
REM Windows batch script to run the startup validation check
REM This helps catch common issues before they cause problems

setlocal enabledelayedexpansion

echo.
echo ======================================
echo SillyTavern + Ollama Startup Check
echo ======================================
echo.

REM Check if docker and docker compose are available
where docker >nul 2>nul
if errorlevel 1 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)

where docker-compose >nul 2>nul
if errorlevel 1 (
    echo ERROR: Docker Compose is not installed
    echo It should come with Docker Desktop
    exit /b 1
)

echo 1. File Checks
echo ---

if not exist "docker-entrypoint.sh" (
    echo ERROR: docker-entrypoint.sh is missing!
    echo Copy it from docker\ subdirectory to the root.
    exit /b 1
) else (
    echo [OK] docker-entrypoint.sh exists
)

if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml is missing!
    exit /b 1
) else (
    echo [OK] docker-compose.yml exists
)

echo.
echo 2. Container Status
echo ---

echo Checking Docker daemon...
docker ps >nul 2>nul
if errorlevel 1 (
    echo ERROR: Docker daemon is not running
    echo Please start Docker Desktop
    exit /b 1
) else (
    echo [OK] Docker daemon is running
)

echo Checking container status...
for /f %%i in ('docker ps -q -f name=sillytavern 2^>nul') do set SILLYTAVERN_RUNNING=%%i
for /f %%i in ('docker ps -q -f name=ollama 2^>nul') do set OLLAMA_RUNNING=%%i

if "!SILLYTAVERN_RUNNING!"=="" (
    echo [WARN] SillyTavern container is not running
    echo Start with: docker compose up
) else (
    echo [OK] SillyTavern container is running
)

if "!OLLAMA_RUNNING!"=="" (
    echo [WARN] Ollama container is not running
    echo Start with: docker compose up
) else (
    echo [OK] Ollama container is running
)

echo.
echo 3. Service Connectivity
echo ---

if "!OLLAMA_RUNNING!"=="" (
    echo [SKIP] Ollama not running, skipping connectivity check
) else (
    echo Checking Ollama API...
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:11434/api/tags' -TimeoutSec 5 -ErrorAction Stop; Write-Host '[OK] Ollama API is responding' } catch { Write-Host '[WARN] Ollama API is not responding' }"
)

if "!SILLYTAVERN_RUNNING!"=="" (
    echo [SKIP] SillyTavern not running, skipping connectivity check
) else (
    echo Checking SillyTavern Web UI...
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8000' -TimeoutSec 5 -ErrorAction Stop; Write-Host '[OK] SillyTavern is responding' } catch { Write-Host '[WARN] SillyTavern is not responding' }"
)

echo.
echo 4. Configuration Check
echo ---

if exist "data\default-user\settings.json" (
    echo Checking Ollama URL in settings...
    findstr /C:"http://localhost:11434" "data\default-user\settings.json" >nul 2>nul
    if errorlevel 1 (
        findstr /C:"http://ollama:11434" "data\default-user\settings.json" >nul 2>nul
        if errorlevel 1 (
            echo [WARN] Could not determine Ollama URL in settings
        ) else (
            echo [WARN] Ollama URL is set to http://ollama:11434 (only works inside Docker containers)
            echo For external clients, use http://localhost:11434
        )
    ) else (
        echo [OK] Ollama URL is correctly set to http://localhost:11434
    )
) else (
    echo [INFO] Settings file not found (will be created on first run)
)

echo.
echo ======================================
echo Startup check complete!
echo ======================================
echo.
echo Next steps:
echo   1. Start the stack: docker compose up
echo   2. Access SillyTavern: http://localhost:8000
echo   3. Ollama API: http://localhost:11434
echo.
echo For more help, see DEVELOPMENT.md
echo.
