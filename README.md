# The Forgotten Server 7.4

This repo is set up to run the server in Docker with a separate MariaDB container.

## Setup

From the project directory:

```sh
docker compose up --build
```

That will:
- build the `app` image
- start the game server container
- start the MariaDB container
- initialize the database from `schema.sql` on first startup

To run in the background:

```sh
docker compose up -d --build
```

## Services

This stack uses two containers:

- `app`: the game server
- `db`: MariaDB

Check them with:

```sh
docker compose ps
```

## Database

Compose-managed database credentials:

- database: `tfs74`
- user: `tfs`
- password: `tfs`
- root password: `root`

Connect to the database:

```sh
docker exec -it theforgottenserver-74-db-1 mariadb -utfs -ptfs tfs74
```

## Config

Main config is [config.lua](/Users/joshknight/Documents/GitHub/theforgottenserver-7.4/config.lua).

Important note:
- `config.lua` is bind-mounted into the container
- changing existing config values only needs an app restart
- adding a brand new C++ config key needs a rebuild first

## Create an account

This server does not create starter accounts automatically.

Example: create account name `1` with password `1`:

```sh
docker exec -it theforgottenserver-74-db-1 mariadb -utfs -ptfs tfs74 -e "INSERT INTO accounts (name, password, type, premdays, lastday, email, creation) VALUES ('1', SHA1('1'), 1, 0, 0, '', UNIX_TIMESTAMP());"
```

## Create a character

Example: create character `Starter` on account `1`:

```sh
docker exec -it theforgottenserver-74-db-1 mariadb -utfs -ptfs tfs74 -e "INSERT INTO players (name, account_id, group_id, level, vocation, health, healthmax, experience, maglevel, mana, manamax, soul, town_id, posx, posy, posz, cap, sex) VALUES ('Starter', 1, 1, 8, 0, 185, 185, 4200, 0, 35, 35, 100, 2, 0, 0, 0, 470, 1);"
```

Notes:
- `account_id = 1` links the character to account `1`
- `town_id = 2` is Thais in this setup
- `posx/posy/posz = 0/0/0` lets the server place the character at the town temple on login
- login uses numeric account name plus password

Create: name: Arrow, account: 1, vocation: 3 = Paladin, level: 8, distance: 130, shielding: 80, town: 2 = Thais
```sh
docker compose -f /Users/joshknight/Documents/GitHub/theforgottenserver-7.4/docker-compose.yml exec db mariadb -utfs -ptfs tfs74 -e "
INSERT INTO players (
  name, account_id, group_id, level, vocation,
  health, healthmax, experience,
  maglevel, mana, manamax, soul,
  town_id, posx, posy, posz,
  conditions,
  cap, sex,
  skill_dist, skill_dist_tries,
  skill_shielding, skill_shielding_tries
) VALUES (
  'Arrow', 1, 1, 8, 3,
  185, 185, 4200,
  0, 35, 35, 100,
  2, 0, 0, 0,
  '',
  470, 1,
  130, 0,
  80, 0
);
"
```

## Rebuild vs restart

Use these rules:

- changed `src/*.cpp`, `src/*.h`, `CMakeLists.txt`, `Dockerfile`, or other compiled code:
  rebuild and recreate
- changed `config.lua` or `server/data/*`:
  restart `app`
- changed only database rows:
  no rebuild or restart needed

Rebuild and recreate:

```sh
docker compose build app
docker compose up -d --force-recreate app
```

Restart only the game server:

```sh
docker compose restart app
```

View logs:

```sh
docker compose logs -f app
```

## Reset or stop the server

Stop the stack without deleting the database:

```sh
docker compose down
```

Start it again:

```sh
docker compose up -d
```

Reset the database completely:

```sh
docker compose down -v
docker compose up -d --build
```

Important:
- `docker compose down -v` deletes the MariaDB volume
- rebuilding the `app` image does not delete the database

## Common commands

Build app:

```sh
docker compose build app
```

Start app and db:

```sh
docker compose up -d
```

Restart app:

```sh
docker compose restart app
```

Tail server log:

```sh
docker compose logs -f app
```

Open DB shell:

```sh
docker exec -it theforgottenserver-74-db-1 mariadb -utfs -ptfs tfs74
```

## Notes

- The server currently warns that the map needs an updated `items.otb`.
- That warning can cause client/map item display mismatches even when server-side logic is working.
- Docker setup details are also summarized in [DOCKER.md](/Users/joshknight/Documents/GitHub/theforgottenserver-7.4/DOCKER.md).
