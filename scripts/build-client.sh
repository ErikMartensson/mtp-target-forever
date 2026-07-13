#!/usr/bin/env bash
#
# Build MTP Target Forever Client (Linux)
#
# Usage: ./scripts/build-client.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"
cmake --preset client-linux
cmake --build build-client
"$SCRIPT_DIR/post-build.sh" client

echo ""
echo "Client built: build-client/bin/mtp-target-forever"
echo "Run it with:  ./scripts/run-client.sh --lan localhost --user YourName"
