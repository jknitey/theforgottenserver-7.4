## syntax=docker/dockerfile:1.7
FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV CCACHE_DIR=/root/.cache/ccache

ARG TFS_BUILD_TYPE=MinSizeRel
ARG TFS_BUILD_JOBS=2

RUN apt-get update && apt-get install -y \
    build-essential \
    ccache \
    cmake \
    libboost-system-dev \
    libgmp-dev \
    libluajit-5.1-dev \
    libmariadb-dev-compat \
    libpugixml-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY . .

RUN --mount=type=cache,target=/root/.cache/ccache \
    arch="$(dpkg-architecture -qDEB_HOST_MULTIARCH)" \
 && cmake -S . -B build -DCMAKE_BUILD_TYPE="${TFS_BUILD_TYPE}" \
    -DENABLE_COTIRE=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DLUA_INCLUDE_DIR=/usr/include/luajit-2.1 \
    -DLUA_LIBRARY="/usr/lib/${arch}/libluajit-5.1.so" \
 && cmake --build build --parallel "${TFS_BUILD_JOBS}" \
 && ccache --show-stats

FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libboost-system1.83.0 \
    libgmp10 \
    libluajit-5.1-2 \
    libmariadb3 \
    libpugixml1v5 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/tfs

COPY --from=build /src/build/tfs /opt/tfs/tfs
COPY schema.sql /opt/tfs/schema.sql
COPY config.lua /opt/tfs/config.lua.template
COPY server/data /opt/tfs/data
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 7171 7172

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./tfs"]
