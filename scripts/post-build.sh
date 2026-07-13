#!/usr/bin/env bash
#
# MTP Target Forever Post-Build Script (Linux)
#
# Copies all required runtime files to the build directory after compiling.
# Mirrors scripts/post-build.ps1.
#
# Usage:
#   ./scripts/post-build.sh client
#   ./scripts/post-build.sh server
#   ./scripts/post-build.sh both
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
RYZOMCORE_DIR="${RYZOMCORE_DIR:-$REPO_ROOT/ryzomcore}"
MANIFEST="$SCRIPT_DIR/assets-manifest.json"
BUILD_TYPE="${1:-both}"

copy_assets() {
    local build_type="$1" dest="$2"
    mkdir -p "$dest"
    local dirs
    dirs=$(jq -r ".directories.$build_type.required[]" "$MANIFEST")
    for dir in $dirs; do
        if [ -d "$REPO_ROOT/data/$dir" ]; then
            mkdir -p "$dest/$dir"
            cp -r "$REPO_ROOT/data/$dir/." "$dest/$dir/"
            echo "   + data/$dir"
        else
            echo "   ! data/$dir (not found)"
        fi
    done
}

setup_client() {
    local dest="$REPO_ROOT/build-client/bin"
    echo "=== Setting up Client ($dest) ==="

    # 1. NeL drivers (dlopen'ed at runtime; run-client.sh adds this dir to LD_LIBRARY_PATH)
    for drv in libnel_drv_opengl.so libnel_drv_openal.so; do
        if [ -f "$RYZOMCORE_DIR/build/lib/$drv" ]; then
            cp "$RYZOMCORE_DIR/build/lib/$drv" "$dest/"
            echo "   + $drv"
        else
            echo "   ! Missing: $drv (run scripts/setup-ryzomcore.sh)"
        fi
    done

    # 2. Game assets
    copy_assets client "$dest/data"

    # 3. Fonts from RyzomCore samples
    mkdir -p "$dest/data/font"
    [ -f "$RYZOMCORE_DIR/nel/samples/3d/cegui/datafiles/n019003l.pfb" ] && \
        cp "$RYZOMCORE_DIR/nel/samples/3d/cegui/datafiles/n019003l.pfb" "$dest/data/font/" && \
        echo "   + n019003l.pfb"
    [ -f "$RYZOMCORE_DIR/nel/samples/3d/font/beteckna.ttf" ] && \
        cp "$RYZOMCORE_DIR/nel/samples/3d/font/beteckna.ttf" "$dest/data/font/bigfont.ttf" && \
        echo "   + bigfont.ttf"

    # 4. GUI files
    if [ -d "$REPO_ROOT/client/data/gui" ]; then
        mkdir -p "$dest/data/gui"
        cp -r "$REPO_ROOT/client/data/gui/." "$dest/data/gui/"
        echo "   + GUI files"
    fi

    # 5. Config files
    if [ -f "$REPO_ROOT/data/config/mtp_target_default.cfg" ]; then
        cp "$REPO_ROOT/data/config/mtp_target_default.cfg" "$dest/"
    elif [ -f "$REPO_ROOT/client/mtp_target_default.cfg" ]; then
        cp "$REPO_ROOT/client/mtp_target_default.cfg" "$dest/"
    fi
    if [ ! -f "$dest/mtp-target.cfg" ]; then
        printf '// This file tells the client where to find the main config\nRootConfigFilename = "mtp_target_default.cfg";\n' > "$dest/mtp-target.cfg"
        echo "   + Created mtp-target.cfg"
    fi

    # 6. Runtime directories
    mkdir -p "$dest/cache" "$dest/replay" "$dest/logs"
    echo "Client setup complete."
}

setup_server() {
    local dest="$REPO_ROOT/build-server/bin"
    echo "=== Setting up Server ($dest) ==="

    copy_assets server "$dest/data"

    if [ -f "$REPO_ROOT/server/data/misc/helpers.lua" ]; then
        cp "$REPO_ROOT/server/data/misc/helpers.lua" "$dest/data/"
        echo "   + helpers.lua"
    fi

    # Server config: only copied on first build, edit build-server/bin/mtp_target_service.cfg afterwards
    if [ ! -f "$dest/mtp_target_service.cfg" ]; then
        cp "$REPO_ROOT/server/mtp_target_service_default.cfg" "$dest/mtp_target_service.cfg"
        echo "   + mtp_target_service.cfg"
    fi

    mkdir -p "$dest/logs"
    echo "Server setup complete."
}

case "$BUILD_TYPE" in
    client) setup_client ;;
    server) setup_server ;;
    both)   setup_client; setup_server ;;
    *) echo "Usage: $0 [client|server|both]"; exit 1 ;;
esac
