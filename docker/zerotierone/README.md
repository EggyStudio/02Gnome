# ZeroTier One

A ZeroTier network node in Docker.

## Address

ZeroTier runs in the host's network, so once the node joins a network, the machine is reachable at
its ZeroTier address. Networks are managed at https://central.zerotier.com.

## Commands

```bash
cd ~/zerotierone

# Start in the background
docker compose up -d

# Stop
docker compose down

# Update within the version in docker-compose.yml
docker compose pull
docker compose up -d

# Join a network
docker exec zerotier-one zerotier-cli join <NETWORK_ID>

# Show the node's status
docker exec zerotier-one zerotier-cli status

# List the joined networks
docker exec zerotier-one zerotier-cli listnetworks
```

## Version

The image is pinned to `1.14.2`, the latest version ZeroTier publishes on Docker Hub. The
container has the `NET_ADMIN` capability and the `/dev/net/tun` device, which ZeroTier's image
documentation names as its requirements.

## Data

The node's identity and configuration are in `./data/`.
