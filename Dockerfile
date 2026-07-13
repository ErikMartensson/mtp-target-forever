# MTP Target Forever — dedicated game server image
#
# Build:  docker build -t mtp-target-forever-server .
# Run:    docker compose up -d      (see docker-compose.yml)
#
# The server listens on TCP 51574. Config, logs and stats live in /config
# (mount it as a volume to persist them across container updates).

# ---------------------------------------------------------------------------
# Build stage: compile ODE, NeL (server subset) and the game server
# ---------------------------------------------------------------------------
FROM debian:trixie AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake ninja-build g++ git curl ca-certificates jq \
        liblua5.1-0-dev libxml2-dev libcurl4-openssl-dev libssl-dev zlib1g-dev \
        libpng-dev libjpeg-dev libgif-dev libfreetype-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN ./scripts/setup-deps.sh --server-only
RUN ./scripts/setup-ryzomcore.sh --server-only
RUN ./scripts/build-server.sh

# ---------------------------------------------------------------------------
# Runtime stage: just the server binary, its data and the shared libraries
# ---------------------------------------------------------------------------
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        liblua5.1-0 libxml2 zlib1g libpng16-16t64 libjpeg62-turbo libgif7 libfreetype6 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --home /config --shell /usr/sbin/nologin mtp

COPY --from=build /src/build-server/bin /opt/mtp-target/server
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /config && chown mtp:mtp /config

USER mtp
EXPOSE 51574/tcp
VOLUME /config

ENTRYPOINT ["docker-entrypoint.sh"]
