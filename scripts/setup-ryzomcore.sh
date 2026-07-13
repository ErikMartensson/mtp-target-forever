#!/usr/bin/env bash
#
# MTP Target Forever RyzomCore/NeL Setup (Linux)
#
# Clones and builds the RyzomCore NeL libraries required by MTP Target Forever.
#
# Usage:
#   ./scripts/setup-ryzomcore.sh                # Build to ./ryzomcore/
#   ./scripts/setup-ryzomcore.sh --build-only   # Rebuild without re-cloning
#   ./scripts/setup-ryzomcore.sh --server-only  # Only the libs the server needs (no sound/drivers)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
RYZOMCORE_DIR="${RYZOMCORE_DIR:-$REPO_ROOT/ryzomcore}"
BUILD_DIR="$RYZOMCORE_DIR/build"
BUILD_ONLY=0
SERVER_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --build-only) BUILD_ONLY=1 ;;
        --server-only) SERVER_ONLY=1 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

echo "==========================================="
echo "  MTP Target Forever RyzomCore/NeL (Linux)"
echo "==========================================="
echo ""
echo "RyzomCore path: $RYZOMCORE_DIR"
echo ""

if [ "$BUILD_ONLY" = "0" ] && [ ! -d "$RYZOMCORE_DIR" ]; then
    echo "=== Cloning RyzomCore ==="
    git clone --depth 1 https://github.com/ryzom/ryzomcore.git "$RYZOMCORE_DIR"
    echo ""
fi

echo "=== Applying local patches ==="
for p in "$SCRIPT_DIR"/patches/ryzomcore-*.patch; do
    [ -e "$p" ] || continue
    if git -C "$RYZOMCORE_DIR" apply --reverse --check "$p" >/dev/null 2>&1; then
        echo "[OK] $(basename "$p") (already applied)"
    else
        git -C "$RYZOMCORE_DIR" apply "$p"
        echo "[OK] $(basename "$p")"
    fi
done
echo ""

if [ "$SERVER_ONLY" = "1" ]; then
    WITH_SOUND=OFF
    WITH_DRIVERS=OFF
    TARGETS="nelmisc nelnet nel3d"
    VERIFY_LIBS="libnelmisc.a libnelnet.a libnel3d.a"
else
    WITH_SOUND=ON
    WITH_DRIVERS=ON
    TARGETS="nelmisc nelnet nel3d nelsound nelsnd_lowlevel nelgeorges nelligo nelpacs nel_drv_opengl nel_drv_openal"
    VERIFY_LIBS="libnelmisc.a libnelnet.a libnel3d.a libnelsound.a libnelsnd_lowlevel.a libnelgeorges.a libnelligo.a libnel_drv_opengl.so libnel_drv_openal.so"
fi

echo "=== Configuring RyzomCore (NeL only) ==="
cmake -S "$RYZOMCORE_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_NEL=ON -DWITH_SOUND=$WITH_SOUND -DWITH_GUI=OFF \
    -DWITH_NEL_TOOLS=OFF -DWITH_NEL_TESTS=OFF -DWITH_NEL_SAMPLES=OFF \
    -DWITH_RYZOM=OFF -DWITH_RYZOM_CLIENT=OFF -DWITH_RYZOM_SERVER=OFF -DWITH_RYZOM_TOOLS=OFF \
    -DWITH_NELNS=OFF -DWITH_SNOWBALLS=OFF \
    -DWITH_STATIC=ON -DWITH_STATIC_DRIVERS=OFF \
    -DWITH_DRIVER_OPENGL=$WITH_DRIVERS -DWITH_DRIVER_OPENAL=$WITH_DRIVERS \
    -DWITH_GTK=OFF -DWITH_QT5=OFF -DWITH_QT6=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

echo ""
echo "=== Building NeL libraries ==="
ninja -C "$BUILD_DIR" $TARGETS

echo ""
echo "=== Verifying build ==="
missing=0
for lib in $VERIFY_LIBS; do
    if [ -f "$BUILD_DIR/lib/$lib" ]; then
        echo "[OK] $lib"
    else
        echo "[MISSING] $lib"
        missing=1
    fi
done
[ "$missing" = "0" ] || { echo "Build incomplete"; exit 1; }

echo ""
echo "==========================================="
echo "  RyzomCore/NeL Build Complete!"
echo "==========================================="
echo ""
echo "Next steps:"
echo "  ./scripts/build-server.sh"
echo "  ./scripts/build-client.sh"
