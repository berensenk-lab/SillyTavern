# Quick Reference

## Starting & Stopping

```bash
# Start the stack (runs in background)
docker compose up -d

# Start and watch logs
docker compose up

# Stop the stack
docker compose down

# Stop and remove all data
docker compose down -v
```

## Common Commands

```bash
# Check if services are running
docker compose ps

# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs sillytavern -f
docker compose logs ollama -f

# Restart a service
docker compose restart sillytavern

# Rebuild images
docker compose build --no-cache
```

## URLs

- **SillyTavern**: http://localhost:8000
- **Ollama API**: http://localhost:11434

## Data Locations

- **SillyTavern data**: `./data/`
- **SillyTavern config**: `./config/`
- **Ollama models**: Docker volume `ollama-data`

## Testing Connectivity

```bash
# From host machine, test Ollama
curl http://localhost:11434/api/tags

# From SillyTavern container, test Ollama
docker exec sillytavern node -e "require('http').get('http://ollama:11434/api/tags', (r) => r.on('data', (d) => console.log(d.toString())))"
```

## Troubleshooting Checklist

- [ ] Docker daemon is running
- [ ] Ports 8000 and 11434 are available
- [ ] `docker-entrypoint.sh` exists in root directory
- [ ] Containers are running: `docker compose ps`
- [ ] Ollama is responding: `curl http://localhost:11434/api/tags`
- [ ] SillyTavern is responding: `curl http://localhost:8000`
- [ ] Check logs: `docker compose logs`

## For Detailed Help

See **DEVELOPMENT.md**
