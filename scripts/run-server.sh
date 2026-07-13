#!/usr/bin/env bash
#
# Run MTP Target Forever Server with Log Rotation (Linux)
#
# Usage: ./scripts/run-server.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SERVER_DIR="$REPO_ROOT/build-server/bin"
LOG_DIR="$SERVER_DIR/logs"
MAX_LOGS=5

if [ ! -x "$SERVER_DIR/mtp-target-forever-srv" ]; then
    echo "Error: server not found at $SERVER_DIR/mtp-target-forever-srv"
    echo "Build it first with: ./scripts/build-server.sh"
    exit 1
fi

mkdir -p "$LOG_DIR"

rotate_log() {
    local name="$1"
    [ -f "$SERVER_DIR/$name" ] || return 0
    rm -f "$LOG_DIR/$name.$MAX_LOGS"
    for ((i=MAX_LOGS; i>=2; i--)); do
        [ -f "$LOG_DIR/$name.$((i-1))" ] && mv "$LOG_DIR/$name.$((i-1))" "$LOG_DIR/$name.$i"
    done
    [ -f "$LOG_DIR/$name" ] && mv "$LOG_DIR/$name" "$LOG_DIR/$name.1"
    mv "$SERVER_DIR/$name" "$LOG_DIR/$name"
    echo "   + Rotated: $name"
}

echo "========================================="
echo "  MTP Target Forever Server"
echo "========================================="
rotate_log "mtp_target_service.log"
rotate_log "log.log"
rotate_log "nel_debug.dmp"

echo ""
echo "Server commands (in-game chat):"
echo "  /help       - Show available commands"
echo "  /v <level>  - Vote for a level"
echo "  /forcemap   - Force next level (admin)"
echo "  /forceend   - End current session (admin)"
echo ""

cd "$SERVER_DIR"
./mtp-target-forever-srv "$@" || true

echo ""
echo "Server exited."
[ -f "$SERVER_DIR/log.log" ] && mv -f "$SERVER_DIR/log.log" "$LOG_DIR/"
[ -f "$SERVER_DIR/mtp_target_service.log" ] && mv -f "$SERVER_DIR/mtp_target_service.log" "$LOG_DIR/"
echo "Logs saved to: $LOG_DIR"
