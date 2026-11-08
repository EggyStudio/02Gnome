# Ollama and Open WebUI

Local LLM inference with Ollama, and Open WebUI as its web chat interface.

## Addresses

| Service | URL |
|---|---|
| **Open WebUI** | http://localhost:3000 |
| **Ollama API** | http://localhost:11434 |

Open WebUI asks for an admin account on its first start.

## Commands

```bash
cd ~/ollama

# Start in the background
docker compose up -d

# Stop
docker compose down

# Update within the versions in docker-compose.yml
docker compose pull
docker compose up -d

# Download a model, such as llama3
docker exec ollama ollama pull llama3

# List the downloaded models
docker exec ollama ollama list
```

## Versions

Ollama is pinned to `0.40.15`, since its image has no tag for a minor version, and Open WebUI to
`0.13`, which takes that minor version's patch releases. A later version is set in
`docker-compose.yml`. Open WebUI 0.13 changes its database schema on its first start, so its data
folder is copied before an earlier install moves to it.

## Data

- Ollama's models are in `./ollama-data/`.
- Open WebUI's users and chat history are in `./open-webui-data/`.

## GPU

The Compose file requests every NVIDIA GPU, and the installer removes that request on a machine
without one. On such a machine set up by hand, remove the `deploy` section of the `ollama` service.
