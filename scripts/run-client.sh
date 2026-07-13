#!/usr/bin/env bash
#
# Run MTP Target Forever Client with Log Rotation (Linux)
#
# Usage: ./scripts/run-client.sh [options]
# Options:
#   --lan <hostname>  Auto-connect to LAN server
#   --user <username> Set username for auto-connect
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CLIENT_DIR="$REPO_ROOT/build-client/bin"
LOG_DIR="$CLIENT_DIR/logs"
MAX_LOGS=5

if [ ! -x "$CLIENT_DIR/mtp-target-forever" ]; then
    echo "Error: client not found at $CLIENT_DIR/mtp-target-forever"
    echo "Build it first with: ./scripts/build-client.sh"
    exit 1
fi

mkdir -p "$LOG_DIR"

rotate_log() {
    local name="$1"
    [ -f "$CLIENT_DIR/$name" ] || return 0
    rm -f "$LOG_DIR/$name.$MAX_LOGS"
    for ((i=MAX_LOGS; i>=2; i--)); do
        [ -f "$LOG_DIR/$name.$((i-1))" ] && mv "$LOG_DIR/$name.$((i-1))" "$LOG_DIR/$name.$i"
    done
    [ -f "$LOG_DIR/$name" ] && mv "$LOG_DIR/$name" "$LOG_DIR/$name.1"
    mv "$CLIENT_DIR/$name" "$LOG_DIR/$name"
    echo "   + Rotated: $name"
}

echo "========================================="
echo "  MTP Target Forever Client"
echo "========================================="
rotate_log "log.log"
rotate_log "chat.log"
rotate_log "nel_debug.dmp"

echo ""
echo "Controls:"
echo "  - Arrow keys: Steer penguin"
echo "  - CTRL: Toggle ball/gliding modes"
echo "  - Enter: Open chat"
echo ""

# The NeL OpenGL/OpenAL drivers are dlopen'ed at runtime; make sure the loader
# can find them (copied next to the binary by post-build.sh).
export LD_LIBRARY_PATH="$CLIENT_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$CLIENT_DIR"
./mtp-target-forever "$@" || true

echo ""
echo "Client exited."
[ -f "$CLIENT_DIR/log.log" ] && mv -f "$CLIENT_DIR/log.log" "$LOG_DIR/"
[ -f "$CLIENT_DIR/chat.log" ] && mv -f "$CLIENT_DIR/chat.log" "$LOG_DIR/"
echo "Logs saved to: $LOG_DIR"
