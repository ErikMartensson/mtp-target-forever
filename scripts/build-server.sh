#!/usr/bin/env bash
#
# Build MTP Target Forever Server (Linux)
#
# Usage: ./scripts/build-server.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"
cmake --preset server-linux
cmake --build build-server
"$SCRIPT_DIR/post-build.sh" server

echo ""
echo "Server built: build-server/bin/mtp-target-forever-srv"
echo "Run it with:  ./scripts/run-server.sh"
