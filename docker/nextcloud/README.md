# Nextcloud

Self-hosted file sync and collaboration.

## Address

| Service | URL |
|---|---|
| **Nextcloud Web** | http://localhost:8080 |

Nextcloud asks for an admin account on its first start. The app container adds `localhost` on
`NC_PORT` to the trusted domains, and the machine's Tailscale address as well when Tailscale runs.

## Commands

```bash
cd ~/nextcloud

# Start in the background
docker compose up -d

# Stop
docker compose down

# Update within the major in docker-compose.yml
docker compose pull
docker compose up -d

# Follow the logs
docker compose logs -f
```

## Configuration

The `.env` file holds these settings:

| Variable | Holds | Default |
|---|---|---|
| `NC_PORT` | The port Nextcloud listens on | `8080` |
| `DB_DATA_LOCATION` | The folder for the PostgreSQL database | `./postgres` |
| `DB_PASSWORD` | The database password, which the installer generates | generated |

The images are pinned to a major, Nextcloud `35-apache`, PostgreSQL `16-alpine` and Redis
`7-alpine`, so a pull brings that major's updates and no other.

## Upgrading an earlier install

Nextcloud upgrades one major version at a time. An install made with the earlier `nextcloud:apache`
image runs the major that image had when it was last pulled, which this command prints:

```bash
docker exec -u www-data nextcloud-app php occ status
```

From there, set the image in `docker-compose.yml` to each next major in turn, such as
`33-apache`, then `34-apache`, then `35-apache`, and run `docker compose pull` and
`docker compose up -d` at each one, waiting for the upgrade to finish before the next.

## Data

- Nextcloud's files are in `./html/` and `./data/`.
- The database is in `./postgres/`.
- The Redis cache is in `./redis/`.

## Documentation

https://docs.nextcloud.com
