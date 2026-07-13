#!/bin/sh
#
# MTP Target Forever server container entrypoint.
#
# The server reads mtp_target_service.cfg from its working directory and
# rewrites it at runtime (level stats, accounts), so the working directory
# is /config — a volume — while the immutable install stays in /opt.
#
set -eu

SERVER_DIR=/opt/mtp-target/server
CONFIG_DIR="${CONFIG_DIR:-/config}"

mkdir -p "$CONFIG_DIR/logs"

if [ ! -f "$CONFIG_DIR/mtp_target_service.cfg" ]; then
    cp "$SERVER_DIR/mtp_target_service.cfg" "$CONFIG_DIR/mtp_target_service.cfg"
    echo "Created default config at $CONFIG_DIR/mtp_target_service.cfg"
fi

# Game assets resolved relative to the working directory
ln -sfn "$SERVER_DIR/data" "$CONFIG_DIR/data"

cd "$CONFIG_DIR"
exec "$SERVER_DIR/mtp-target-forever-srv" "$@"
