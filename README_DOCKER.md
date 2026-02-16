# SillyTavern + Ollama

This project runs SillyTavern and Ollama in Docker containers for a complete AI character chat experience.

## ⚡ Quick Start

### Option 1: Docker Compose (Recommended)

```bash
docker compose up
```

Then open: **http://localhost:8000**

### Option 2: Validate First, Then Start

```bash
# Validate your setup
.\startup-check.bat

# Start the stack
docker compose up
```

## 📚 Documentation

- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Common commands and URLs
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Comprehensive troubleshooting guide
- **[SETUP_SUMMARY.md](SETUP_SUMMARY.md)** - What was set up and why

## 🐳 Services

| Service | URL | Purpose |
|---------|-----|---------|
| SillyTavern | http://localhost:8000 | Web UI for chat |
| Ollama | http://localhost:11434 | LLM API server |

## 📁 Project Structure

```
SillyTavern/
├── docker-compose.yml        ← Start here (docker compose up)
├── Dockerfile                ← Docker image definition
├── docker-entrypoint.sh      ← Container startup script
│
├── QUICK_REFERENCE.md        ← Commands cheat sheet
├── DEVELOPMENT.md            ← Troubleshooting guide
├── SETUP_SUMMARY.md          ← Setup documentation
│
├── startup-check.bat         ← Validate setup
├── scripts/startup-check.sh  ← Linux/macOS validation
│
├── data/                     ← Chat data (persisted)
├── config/                   ← Configuration (persisted)
├── src/                      ← Source code
├── public/                   ← Web UI assets
└── ... (other project files)
```

## 🚀 Common Commands

```bash
# Start services
docker compose up

# Start in background
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Restart a service
docker compose restart sillytavern

# Check status
docker compose ps
```

## ❓ Need Help?

1. Run the validation script: `.\startup-check.bat`
2. Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common issues
3. See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed troubleshooting

## ⚙️ Configuration

- **Ollama URL**: `http://localhost:11434` (from host machine)
- **SillyTavern**: `http://localhost:8000`
- **Settings file**: `data/default-user/settings.json`
- **Environment**: `.env.example` (copy to `.env` if needed)

## 🔗 Links

- [SillyTavern GitHub](https://github.com/SillyTavern/SillyTavern)
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Docker Compose Docs](https://docs.docker.com/compose/)

---

**Note**: This project uses Docker. Make sure Docker Desktop is installed and running.
