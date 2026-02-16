# SillyTavern + Ollama Development Guide

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Port 8000 available for SillyTavern
- Port 11434 available for Ollama

### Starting the Stack

```bash
cd C:\Users\beren\OneDrive\Documents\GitHub\SillyTavern
docker compose up
```

SillyTavern will be available at `http://localhost:8000`

### Stopping the Stack

```bash
docker compose down
```

To stop and remove all data:
```bash
docker compose down -v
```

---

## Architecture

### Services

**SillyTavern** (Node.js)
- Port: 8000 (HTTP)
- Purpose: Web UI and backend for character interactions
- Docker network name: `sillytavern` (use from host: `localhost:8000`)

**Ollama** (LLM Server)
- Port: 11434 (HTTP)
- Purpose: Runs language models and provides generation API
- Docker network name: `ollama` (use from host: `localhost:11434`)
- Models: `llama3:latest` (pre-loaded)

### Network
Both services are on the same Docker network (`sillytavern-net`), so they can communicate using service names internally.

**Important**: When calling Ollama from the **host machine** (e.g., from Anna_AI running locally), use `http://localhost:11434`. Inside Docker containers, you would use `http://ollama:11434`.

---

## Configuration

### Ollama URL in SillyTavern

The Ollama API URL is configured in:
```
data/default-user/settings.json
```

Look for:
```json
"server_urls": {
    "ooba": "http://localhost",
    "ollama": "http://localhost:11434"
}
```

**This must be `http://localhost:11434` for external clients (Anna_AI, etc.).**

If accessing Ollama from within another Docker container on the same network, use `http://ollama:11434` instead.

### Environment Variables

Both services are configured in `docker-compose.yml`:

**SillyTavern**:
- `NODE_ENV=production`
- `OLLAMA_API_URL=http://ollama:11434` (internal Docker network URL)

**Ollama**:
- `OLLAMA_HOST=0.0.0.0:11434` (listen on all interfaces)

---

## Common Tasks

### Check Service Status

```bash
docker compose ps
```

Expected output:
```
NAME          STATUS
sillytavern   Up X minutes
ollama        Up X minutes
```

### View Logs

**SillyTavern logs**:
```bash
docker compose logs sillytavern -f
```

**Ollama logs**:
```bash
docker compose logs ollama -f
```

**Both services**:
```bash
docker compose logs -f
```

### Test Ollama Connectivity

From host machine:
```bash
curl http://localhost:11434/api/tags
```

Expected response: JSON with available models.

### Access SillyTavern Shell

```bash
docker exec -it sillytavern /bin/sh
```

### Restart a Service

```bash
docker compose restart sillytavern
```

Or restart everything:
```bash
docker compose restart
```

---

## Troubleshooting

### "Connection refused" or "Cannot reach Ollama"

**Symptom**: Anna_AI or other client gets 404 or connection error on `http://localhost:11434`.

**Causes**:
1. Ollama container is not running
2. Using `http://ollama:11434` from host machine (only works inside Docker)
3. Port 11434 is bound to something else

**Fix**:
1. Check status: `docker compose ps` — ensure `ollama` is running
2. Check port: `netstat -ano | findstr :11434` (Windows) or `lsof -i :11434` (macOS/Linux)
3. Verify connectivity: `curl http://localhost:11434/api/tags`
4. Restart: `docker compose restart ollama`

### SillyTavern Container Keeps Restarting

**Symptom**: `docker compose logs sillytavern` shows `[FATAL tini (7)] exec ./docker-entrypoint.sh failed: No such file or directory`

**Causes**:
1. `docker-entrypoint.sh` is missing from the app directory
2. File has Windows line endings (CRLF) instead of Unix (LF)
3. Volume mount is overriding the built Docker image

**Fix**:
1. Ensure `docker-entrypoint.sh` exists in the root directory (not just in `docker/`)
2. Convert to Unix line endings if needed
3. Rebuild the image: `docker compose build --no-cache sillytavern`
4. Restart: `docker compose restart sillytavern`

### Ollama Model Not Loading

**Symptom**: Requests to Ollama time out or return errors.

**Causes**:
1. Model is still downloading
2. Not enough disk space or memory
3. Model name is wrong

**Fix**:
1. Check available models: `curl http://localhost:11434/api/tags`
2. Manually pull a model: 
   ```bash
   docker exec ollama ollama pull llama2
   ```
3. Check Ollama logs: `docker compose logs ollama | tail -20`

### SillyTavern Won't Connect to Ollama (from UI)

**Symptom**: SillyTavern web UI shows connection error to Ollama.

**Causes**:
1. Ollama URL in settings is wrong
2. Ollama container is not healthy
3. Network connectivity issue

**Fix**:
1. Check settings file: `data/default-user/settings.json`
   - Look for `"ollama": "http://localhost:11434"`
2. Verify Ollama is running: `docker compose ps ollama`
3. Test from SillyTavern container:
   ```bash
   docker exec sillytavern node -e "require('http').get('http://ollama:11434/api/tags', (r) => r.on('data', (d) => console.log(d.toString())))"
   ```

### Docker Image Won't Build

**Symptom**: `docker compose build` fails.

**Common causes**:
1. Rate limiting from Docker Hub (image pull timeout)
2. Missing files referenced in COPY statements
3. Network issues

**Fix**:
1. Check Dockerfile for COPY statements — ensure all referenced files exist locally
2. Try pulling the base image first:
   ```bash
   docker pull node:lts-alpine3.22
   ```
3. Retry the build:
   ```bash
   docker compose build --no-cache sillytavern
   ```

---

## Performance & Optimization

### Memory Usage

Check current memory usage:
```bash
docker stats
```

If OOM errors occur, adjust in `docker-compose.yml`:
```yaml
services:
  sillytavern:
    mem_limit: 4g
  ollama:
    mem_limit: 8g
```

### Disk Space

Check Docker disk usage:
```bash
docker system df
```

Clean up unused images/containers:
```bash
docker system prune -a
```

### Persistence

**SillyTavern data** is persisted in:
- `./data/` → stored as-is
- `./config/` → configuration files

**Ollama models** are persisted in:
- Docker volume `ollama-data` → stored on host

To back up data:
```bash
# Backup SillyTavern
tar -czf sillytavern-backup.tar.gz data/ config/

# Restore SillyTavern
tar -xzf sillytavern-backup.tar.gz
```

---

## Development Workflow

### Making Code Changes

1. Edit files locally in `src/`, `public/`, etc.
2. Restart SillyTavern:
   ```bash
   docker compose restart sillytavern
   ```
3. View changes in browser (refresh at `http://localhost:8000`)

### Rebuilding After Dockerfile Changes

```bash
docker compose build --no-cache sillytavern
docker compose up sillytavern
```

### Debugging

Enable debug logs in SillyTavern:
1. Check `config/config.yaml`
2. Set `logging.minLogLevel: 0` (DEBUG)
3. Restart: `docker compose restart sillytavern`
4. View logs: `docker compose logs sillytavern -f`

---

## Useful Resources

- **Docker Compose Docs**: https://docs.docker.com/compose/
- **Ollama API Docs**: https://github.com/ollama/ollama/blob/main/docs/api.md
- **SillyTavern Docs**: https://github.com/SillyTavern/SillyTavern/wiki

---

## Need Help?

1. Check logs first: `docker compose logs`
2. Verify services are running: `docker compose ps`
3. Test connectivity: `curl http://localhost:11434/api/tags`
4. Review this guide's troubleshooting section
5. Rebuild from scratch: `docker compose down -v && docker compose up`
