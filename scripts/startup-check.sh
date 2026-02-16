#!/bin/sh
# Startup validation script for SillyTavern + Ollama stack
# This script checks that all services are healthy before starting the application

set -e

echo "======================================"
echo "SillyTavern + Ollama Startup Check"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
check_url() {
    local url=$1
    local name=$2
    
    echo -n "Checking $name at $url... "
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo "${GREEN}✓ OK${NC}"
        return 0
    else
        echo "${RED}✗ FAILED${NC}"
        return 1
    fi
}

check_file() {
    local filepath=$1
    local name=$2
    
    echo -n "Checking for $name at $filepath... "
    
    if [ -f "$filepath" ]; then
        echo "${GREEN}✓ OK${NC}"
        return 0
    else
        echo "${RED}✗ MISSING${NC}"
        return 1
    fi
}

# Start checks
echo "1. File Checks"
echo "---"

check_file "./docker-entrypoint.sh" "docker-entrypoint.sh" || {
    echo "${RED}ERROR: docker-entrypoint.sh is missing!${NC}"
    echo "Copy it from docker/ subdirectory to the root."
    exit 1
}

check_file "./docker-compose.yml" "docker-compose.yml" || {
    echo "${RED}ERROR: docker-compose.yml is missing!${NC}"
    exit 1
}

echo ""
echo "2. Container Status"
echo "---"

# Check if containers are running (give them a moment to start)
echo "Waiting for containers to be ready (up to 30 seconds)..."
COUNTER=0
MAX_ATTEMPTS=30

while [ $COUNTER -lt $MAX_ATTEMPTS ]; do
    SILLYTAVERN_RUNNING=$(docker ps -q -f name=sillytavern 2>/dev/null || echo "")
    OLLAMA_RUNNING=$(docker ps -q -f name=ollama 2>/dev/null || echo "")
    
    if [ ! -z "$SILLYTAVERN_RUNNING" ] && [ ! -z "$OLLAMA_RUNNING" ]; then
        break
    fi
    
    COUNTER=$((COUNTER + 1))
    if [ $((COUNTER % 5)) -eq 0 ]; then
        echo "  Attempt $COUNTER/$MAX_ATTEMPTS..."
    fi
    sleep 1
done

echo -n "SillyTavern container... "
if docker ps -q -f name=sillytavern | grep -q .; then
    echo "${GREEN}✓ Running${NC}"
else
    echo "${RED}✗ Not running${NC}"
    echo "Start with: docker compose up -d"
    exit 1
fi

echo -n "Ollama container... "
if docker ps -q -f name=ollama | grep -q .; then
    echo "${GREEN}✓ Running${NC}"
else
    echo "${RED}✗ Not running${NC}"
    echo "Start with: docker compose up -d"
    exit 1
fi

echo ""
echo "3. Service Connectivity"
echo "---"

# Give services a moment to fully start
sleep 2

check_url "http://localhost:11434/api/tags" "Ollama API" || {
    echo "${YELLOW}WARNING: Ollama API is not responding yet. It may still be starting.${NC}"
    echo "Retry in a few seconds with: docker compose logs ollama"
}

check_url "http://localhost:8000/" "SillyTavern Web UI" || {
    echo "${YELLOW}WARNING: SillyTavern is not responding yet. It may still be starting.${NC}"
    echo "Check logs with: docker compose logs sillytavern"
}

echo ""
echo "4. Configuration Check"
echo "---"

# Check if Ollama URL is configured correctly in settings
if [ -f "data/default-user/settings.json" ]; then
    echo -n "Checking Ollama URL in settings... "
    if grep -q '"ollama".*"http://localhost:11434"' "data/default-user/settings.json"; then
        echo "${GREEN}✓ Correctly set to http://localhost:11434${NC}"
    elif grep -q '"ollama".*"http://ollama:11434"' "data/default-user/settings.json"; then
        echo "${YELLOW}⚠ Set to http://ollama:11434 (only works inside Docker)${NC}"
        echo "  For external clients, this should be http://localhost:11434"
    else
        echo "${YELLOW}⚠ Could not determine Ollama URL${NC}"
    fi
else
    echo "${YELLOW}⚠ Settings file not found (will be created on first run)${NC}"
fi

echo ""
echo "======================================"
echo "${GREEN}Startup check complete!${NC}"
echo "======================================"
echo ""
echo "Access SillyTavern at: http://localhost:8000"
echo "Ollama API at: http://localhost:11434"
echo ""
echo "Troubleshooting? See DEVELOPMENT.md"
