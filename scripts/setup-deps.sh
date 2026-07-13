#!/usr/bin/env bash
#
# MTP Target Forever Dependencies Setup (Linux)
#
# Most dependencies come from system packages. This script checks they are
# present and builds ODE (double precision, static) from source into deps/ode,
# matching the precision used by the Windows build (ode_doubles.lib).
#
# Usage:
#   ./scripts/setup-deps.sh                # client + server
#   ./scripts/setup-deps.sh --server-only  # skip client-only checks (audio, GL, curl)
#
set -euo pipefail

SERVER_ONLY=0
[ "${1:-}" = "--server-only" ] && SERVER_ONLY=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ODE_VERSION="0.16.6"
ODE_URL="https://bitbucket.org/odedevs/ode/downloads/ode-${ODE_VERSION}.tar.gz"
DEPS_DIR="$REPO_ROOT/deps"

echo "==========================================="
echo "  MTP Target Forever Dependencies (Linux)"
echo "==========================================="
echo ""

# --- Check required tools and system libraries -------------------------------
echo "=== Checking prerequisites ==="
missing=()
for tool in cmake ninja g++ git curl; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool"
    else
        missing+=("$tool")
    fi
done

check_header() {
    local name="$1"; shift
    for p in "$@"; do
        if [ -e "$p" ]; then
            echo "[OK] $name"
            return 0
        fi
    done
    missing+=("$name")
}

check_header "lua 5.1 headers"  /usr/include/lua5.1/lua.h
check_header "libxml2 headers"  /usr/include/libxml2/libxml/parser.h
check_header "libpng headers"   /usr/include/png.h
check_header "libjpeg headers"  /usr/include/jpeglib.h
check_header "giflib headers"   /usr/include/gif_lib.h
check_header "freetype headers" /usr/include/freetype2/ft2build.h

if [ "$SERVER_ONLY" = "0" ]; then
    check_header "libcurl headers"  /usr/include/curl/curl.h
    check_header "openal headers"   /usr/include/AL/al.h
    check_header "vorbis headers"   /usr/include/vorbis/vorbisfile.h
    check_header "GL headers"       /usr/include/GL/gl.h
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    echo "Missing dependencies: ${missing[*]}"
    echo ""
    echo "Arch Linux:    sudo pacman -S --needed cmake ninja gcc git base-devel lua51 libxml2 curl libpng libjpeg-turbo giflib freetype2 openal libvorbis libogg mesa libx11 libxxf86vm libxrandr"
    echo "Debian/Ubuntu: sudo apt install cmake ninja-build g++ git liblua5.1-0-dev libxml2-dev libcurl4-openssl-dev libpng-dev libjpeg-dev libgif-dev libfreetype-dev libopenal-dev libvorbis-dev libogg-dev libgl-dev libx11-dev libxxf86vm-dev libxrandr-dev"
    exit 1
fi
echo ""

# --- Build ODE into deps/ode -------------------------------------------------
if [ -f "$DEPS_DIR/ode/lib/libode.a" ]; then
    echo "[OK] ODE already built at deps/ode"
else
    echo "=== Building ODE $ODE_VERSION (static, double precision) ==="
    workdir="$(mktemp -d)"
    trap 'rm -rf "$workdir"' EXIT

    curl -sL -o "$workdir/ode.tar.gz" "$ODE_URL"
    tar -xzf "$workdir/ode.tar.gz" -C "$workdir"

    cmake -S "$workdir/ode-$ODE_VERSION" -B "$workdir/build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DODE_DOUBLE_PRECISION=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DODE_WITH_DEMOS=OFF -DODE_WITH_TESTS=OFF \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_INSTALL_PREFIX="$DEPS_DIR/ode"
    ninja -C "$workdir/build" install
    echo "[OK] ODE installed to deps/ode"
fi

echo ""
echo "Dependencies ready. Next: ./scripts/setup-ryzomcore.sh"
