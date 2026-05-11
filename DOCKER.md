# Docker usage

This repo now has two Docker paths:

1. `docker-compose.yml`
   Runs both the game server and a MariaDB container managed by Compose.

2. `docker-compose.existing-db.yml`
   Runs only the game server and connects it to an already-running database container such as `tfs74-db`.

## Fresh stack

```sh
docker compose up --build
```

The database is initialized from `schema.sql` on first startup.

## Reuse existing `tfs74-db`

Create a shared user-defined network once:

```sh
docker network create tfs74
docker network connect tfs74 tfs74-db
```

Then start only the server container:

```sh
docker compose -f docker-compose.existing-db.yml up --build
```

## Notes

- The container reads `./config.lua` as a template and injects DB settings at startup.
- `./server/data` is bind-mounted into the container, so map and script edits are picked up from your working tree.
- `ip = "127.0.0.1"` in `config.lua` is fine for local play. If the client connects from another machine, set `TFS_SERVER_IP` or change `config.lua`.
- If Docker Desktop runs low on memory while compiling, reduce build concurrency:

```sh
docker compose build --build-arg TFS_BUILD_JOBS=1 app
```

- Rebuilds are accelerated with `ccache`. The first full build is still slow; later builds should be much faster.

## Containers and data

- The game server and MariaDB do not run in the same container.
- `app` runs the game server.
- `db` runs MariaDB.
- The MariaDB data is stored in the Docker volume `tfs74-db-data`.
- Rebuilding or recreating the `app` container does not reset the database.

You can see both containers with:

```sh
docker compose ps
```

## When to rebuild

Rebuild the `app` image when you change files that are baked into the image:

- `src/*.cpp`, `src/*.h`
- `CMakeLists.txt` and other build files
- `Dockerfile`
- `docker/entrypoint.sh`

Use:

```sh
docker compose build app
docker compose up -d --force-recreate app
```

## When restart is enough

Restart only the game server when:

- you want to bounce the server process
- the server is hung
- you changed a bind-mounted runtime file

In this setup, these are bind-mounted and picked up from your working tree:

- `config.lua`
- `server/data/*`

After changing those, a restart is usually enough:

```sh
docker compose restart app
```

## When nothing is needed

You do not need to rebuild or restart when you only change database contents:

- creating accounts
- creating characters
- editing player data directly in MariaDB

The database lives in its own container and persistent volume, so those changes take effect without rebuilding the game server.

## What resets the database

These are safe and do not reset DB data:

```sh
docker compose build app
docker compose up -d --force-recreate app
docker compose restart app
docker compose down
```

This removes the MariaDB volume and resets the database:

```sh
docker compose down -v
```
