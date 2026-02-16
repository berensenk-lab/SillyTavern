# Startup Scripts Guide

## Current Setup (Docker)

You are using **Docker** to run SillyTavern and Ollama. Use these commands:

```bash
# Start the stack
docker compose up

# Stop the stack
docker compose down
```

## Old Startup Scripts (Non-Docker)

The following files are from the **original SillyTavern distribution** and run Node.js directly on your machine (not Docker). They are **NOT recommended** for this project since we're using Docker.

### ⚠️ Don't Use These (They may not work):

| File | Purpose | Why Not Recommended |
|------|---------|---------------------|
| `Start.bat` | Runs npm install + node server.js on Windows host | Requires Node.js installed locally; doesn't use Docker |
| `start.sh` | Runs npm install + node server.js on Linux/macOS | Requires Node.js installed locally; doesn't use Docker |
| `Start-SillyTavern.ps1` | Uses Docker Compose (old PowerShell version) | Works but naming is confusing |
| `UpdateAndStart.bat` | Git pull + Start.bat | Uses non-Docker startup |
| `UpdateForkAndStart.bat` | Git pull (fork) + Start.bat | Uses non-Docker startup |

### Why Docker is Better

✅ Consistent across machines  
✅ No need to install Node.js on your machine  
✅ Easy to manage Ollama alongside SillyTavern  
✅ Isolated environments  
✅ Reproducible builds  

### If You Want to Use Non-Docker

If you want to run SillyTavern on your machine without Docker:

1. Install Node.js from https://nodejs.org/
2. Run: `Start.bat` (Windows) or `./start.sh` (Linux/macOS)

**But then you'll need to run Ollama separately.**

## Recommended Workflow

### Daily Use
```bash
docker compose up
```

### Update SillyTavern Code
```bash
git pull
docker compose build --no-cache
docker compose up
```

### Check Status
```bash
docker compose ps
docker compose logs -f
```

## Summary

| Scenario | Command |
|----------|---------|
| Start the stack | `docker compose up` |
| Stop the stack | `docker compose down` |
| Restart services | `docker compose restart` |
| View logs | `docker compose logs -f` |
| Update code | `git pull && docker compose build --no-cache && docker compose up` |

**Don't worry about the old startup scripts.** They won't hurt anything; just use `docker compose up` going forward.

For more details, see [DEVELOPMENT.md](DEVELOPMENT.md).
