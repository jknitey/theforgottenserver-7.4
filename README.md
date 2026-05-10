forgottenserver 7.4
===============

Based on a downgraded branch by [@ninjalulz](https://github.com/ninjalulz/), which according to the file 'definition.h' is **TFS 1.2**. The original [Forgotten Server](https://github.com/otland/forgottenserver/) is a free and open-source MMORPG server emulator written in C++. It is a fork of the [OpenTibia Server](https://github.com/opentibia/server) project. Custom client included (7.72 client with 7.4 dat/spr/pic).

### Getting Started 

* [Compiling](https://github.com/otland/forgottenserver/wiki/Compiling)
* [Scripting Reference](https://github.com/otland/forgottenserver/wiki/Script-Interface)

### Rebuild on macOS

Install dependencies with Homebrew:

```bash
brew install cmake boost gmp pugixml luajit mysql-client
```

Build the server from the repository root:

```bash
mkdir -p build
cd build
export MYSQL_DIR=/opt/homebrew/opt/mysql-client
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/opt/homebrew \
  -DLUA_INCLUDE_DIR=/opt/homebrew/include/luajit-2.1
cmake --build . -j"$(sysctl -n hw.ncpu)"
```

For later C++ changes, rebuild with:

```bash
cd build
cmake --build . -j"$(sysctl -n hw.ncpu)"
```

### Run on macOS

This fork expects a root-level `data/` directory. If your files are under `server/data/`, create a symlink once:

```bash
ln -s server/data data
```

Set the map name in `config.lua` to:

```lua
mapName = "Tibia74"
```

Then start the server:

```bash
./build/tfs
```

### Support

If you need help, please visit the [our OTLand forum thread](https://otland.net/threads/7-4-tfs-1-2.245320/).

### Issues

We use the [issue tracker on GitHub](https://github.com/babymannen/theforgottenserver-7.4/issues).
