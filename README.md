# TF2 Classified Server

Docker image for running a dedicated [TF2 Classified](https://tf2classified.com/) server. MetaMod and SourceMod are included.

## Quick start

Create the persistent directories:

```sh
mkdir -p data/tf data/classified data/maps data/mods cfg.d
```

Create `compose.yml`:

```yaml
services:
  tf2classified:
    image: ghcr.io/kruhlmann/tf2classified-server:latest
    restart: unless-stopped
    environment:
      TF_HOST: "0.0.0.0"
      TF_PORT: 27015
      TF_SERVER_NAME: "TF2 Classified"
      TF_MAX_PLAYERS: 24
      TF_STARTUP_MAP: cp_dustbowl
      TF_RCON_PASSWORD: "change-me"
      TF_CFG_DIR: /etc/tf/cfg.d
      TF_MAP_ROTATION: |
        cp_dustbowl
        pl_badwater
        pl_upward
    ports:
      - "27015:27015/udp"
    volumes:
      - ./data/tf:/data/tf
      - ./data/classified:/data/classified
      - ./data/maps:/data/maps:ro
      - ./data/mods:/data/mods:ro
      - ./cfg.d:/etc/tf/cfg.d:ro
```

Start the server:

```sh
docker compose up -d
docker compose logs -f tf2classified
```

The first start downloads TF2 and TF2 Classified and can take a while. Subsequent starts reuse the files in `data/`.

Connect from the in-game console:

```text
connect SERVER_IP:27015
```

## Configuration

| Variable | Description | Default |
| --- | --- | --- |
| `TF_HOST` | Address on which the server listens | `127.0.0.1` |
| `TF_PORT` | Game and RCON port | `27015` |
| `TF_SERVER_NAME` | Name shown in the server browser | `tf2classified-in-docker` |
| `TF_MAX_PLAYERS` | Maximum player count | `24` |
| `TF_STARTUP_MAP` | Initial map | `ctf_2fort` |
| `TF_MAP_ROTATION` | Comma- or newline-separated map names | unset |
| `TF_MOTD` | Message shown to connecting players | `Welcome to the TF2 Classified server!` |
| `TF_PASSWORD` | Optional game password | unset |
| `TF_RCON_PASSWORD` | RCON password; set this to keep it stable | generated |
| `TF_ADMIN_STEAM_IDS` | Comma- or newline-separated SourceMod Steam2 IDs | unset |
| `TF_UPDATE_INTERVAL_SECONDS` | Update-check interval | `300` |
| `TF_CFG_DIR` | Directory containing additional `.cfg` fragments | unset |

For an Internet-facing container, set `TF_HOST` to `0.0.0.0`.

SourceMod administrators must use Steam2 IDs:

```yaml
TF_ADMIN_STEAM_IDS: |
  STEAM_0:1:12345678
```

Administrators can open the in-game menu with `sm_admin` or `!admin`.

## Custom maps

Place `.bsp` files in `data/maps`. Every map named in `TF_MAP_ROTATION` must either be part of the installed game or exist in that directory; startup fails if a required map is missing.

Clients also need custom maps. For small maps, enable direct downloads in a file such as `cfg.d/downloads.cfg`:

```cfg
sv_allowdownload 1
net_maxfilesize 64
```

For larger maps, configure a separate FastDL HTTP server with `sv_downloadurl`.

## SourceMod plugins

Place additional `.smx` files in `data/mods` and recreate the container. The entrypoint links them into SourceMod without modifying the mounted files.

To enable the bundled Rock the Vote plugins:

```sh
cp data/classified/tf2classified/addons/sourcemod/plugins/disabled/mapchooser.smx data/mods/
cp data/classified/tf2classified/addons/sourcemod/plugins/disabled/rockthevote.smx data/mods/
docker compose up -d --force-recreate tf2classified
```

Players can then type `!rtv`.

## Updating

```sh
docker compose pull
docker compose up -d
```

The container periodically checks for game updates. Persistent game data, maps, plugins, and configuration remain in the mounted directories.
