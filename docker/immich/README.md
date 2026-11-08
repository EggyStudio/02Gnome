# Immich

Self-hosted photo and video management.

## Address

| Service | URL |
|---|---|
| **Immich Web** | http://localhost:2283 |

Immich asks for an admin account on its first start.

## Commands

```bash
cd ~/immich

# Start in the background
docker compose up -d

# Stop
docker compose down

# Update within the version in .env
docker compose pull
docker compose up -d

# Follow the logs
docker compose logs -f
```

## Configuration

The `.env` file holds these settings:

| Variable | Holds | Default |
|---|---|---|
| `UPLOAD_LOCATION` | The folder for uploaded photos and videos | `./library` |
| `DB_DATA_LOCATION` | The folder for the PostgreSQL database, which cannot be a network share | `./postgres` |
| `IMMICH_VERSION` | The release Immich pulls, a major such as `v3` or an exact version such as `v3.3.6` | `v3` |
| `DB_PASSWORD` | The database password, which the installer generates and which takes only `A-Za-z0-9` | generated |

`docker-compose.yml` is Immich's own file of release v3.3.6, so a later release's file replaces it
whole.

## Upgrading an earlier install

An install made before this file pinned `v3` has `IMMICH_VERSION=release` in its `.env`, which the
installer keeps. Set it to `v3`, then pull and start as above. Immich 3 no longer supports
pgvecto.rs, so an install that has run only releases before v1.133.0 first follows Immich's
[migration to VectorChord](https://docs.immich.app/install/upgrading/#migrating-to-vectorchord).
The Valkey image moves from 8 to 9, which reads the data of 8. Immich's
[v3 migration guide](https://immich.app/blog/v3-migration) lists the remaining changes, most of
which concern tools that use Immich's API.

## Data

- Uploaded media is in `./library/`.
- The database is in `./postgres/`.

## Documentation

https://docs.immich.app
