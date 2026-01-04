# Building MTP Target

This guide covers building the MTP Target game server and client from source on modern systems.

---

## Table of Contents

- [Quick Start (Windows)](#quick-start-windows)
- [Prerequisites](#prerequisites)
- [Build Scripts](#build-scripts)
- [CMake Presets](#cmake-presets)
- [Manual Build](#manual-build)
- [Post-Build Setup](#post-build-setup)
- [Running the Game](#running-the-game)
- [GitHub Actions CI](#github-actions-ci)
- [Troubleshooting](#troubleshooting)

---

## Quick Start (Windows)

If you have all dependencies installed, use the build scripts:

```bash
# Build client only (to build-client/)
./scripts/build-client.sh

# Build server only (to build-server/)
./scripts/build-server.sh

# Build both
./scripts/build-all.sh

# Clean build
./scripts/build-client.sh --clean
```

Or use CMake presets:

```bash
# Configure and build client
cmake --preset client
cmake --build --preset client

# Configure and build server
cmake --preset server
cmake --build --preset server
```

---

## Prerequisites

### Windows

**Required:**
- Visual Studio 2022 with C++ Desktop Development workload
- CMake 3.21+ (for CMake presets support)
- Git for Windows / Git Bash

**Dependencies (must be pre-built):**
- NeL/RyzomCore libraries (`C:\ryzomcore`)
- Third-party libs (`C:\tux_target_deps`):
  - ODE 0.16.5 (physics engine)
  - Lua 5.1
  - libxml2
  - libcurl
  - OpenSSL
  - FreeType, libjpeg, libpng
  - libogg, libvorbis, OpenAL

### Linux (Future)

```bash
sudo apt update
sudo apt install -y \
    build-essential cmake git ninja-build \
    libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev \
    lua5.1 liblua5.1-0-dev \
    libcurl4-openssl-dev libode-dev
```

---

## Build Scripts

### Available Scripts

| Script | Purpose |
|--------|---------|
| `scripts/build-client.sh` | Build client to `build-client/` |
| `scripts/build-server.sh` | Build server to `build-server/` |
| `scripts/build-all.sh` | Build both client and server |
| `scripts/post_build.sh` | Copy runtime files to build directory |
| `scripts/run-client.sh` | Start client with log rotation |
| `scripts/run-server.sh` | Start server with log rotation |

Windows batch equivalents (`.bat`) are also provided.

### Script Options

```bash
# Clean build (removes build directory first)
./scripts/build-client.sh --clean

# Skip post-build file copying
./scripts/build-client.sh --skip-post-build

# Both options
./scripts/build-server.sh --clean --skip-post-build
```

### Post-Build Script Options

```bash
# Setup for client only
./scripts/post_build.sh --client-only

# Setup for server only
./scripts/post_build.sh --server-only

# Custom build directory
./scripts/post_build.sh --build-dir /path/to/build/bin/Release

# Combined
./scripts/post_build.sh --client-only --build-dir ./my-client/Release
```

---

## CMake Presets

The project includes `CMakePresets.json` for easy builds:

### Available Presets

| Preset | Description | Output Directory |
|--------|-------------|------------------|
| `client` | Windows client only | `build-client/` |
| `server` | Windows server only | `build-server/` |
| `both` | Client and server | `build/` |
| `client-linux` | Linux client only | `build-client/` |
| `server-linux` | Linux server only | `build-server/` |

### Usage

```bash
# Configure
cmake --preset client

# Build
cmake --build --preset client

# Or combined (configure if needed, then build)
cmake --preset server && cmake --build --preset server
```

---

## Manual Build

If you prefer manual CMake commands:

### Build Client Only

```bash
mkdir build-client && cd build-client

cmake .. \
    -G "Visual Studio 17 2022" \
    -DBUILD_CLIENT=ON \
    -DBUILD_SERVER=OFF \
    -DWITH_STATIC=ON \
    -DWITH_STATIC_LIBXML2=ON \
    -DWITH_STATIC_CURL=ON

cmake --build . --config Release -j8
```

### Build Server Only

```bash
mkdir build-server && cd build-server

cmake .. \
    -G "Visual Studio 17 2022" \
    -DBUILD_CLIENT=OFF \
    -DBUILD_SERVER=ON

cmake --build . --config Release -j8
```

### Build Both (Legacy)

```bash
mkdir build && cd build

cmake .. \
    -G "Visual Studio 17 2022" \
    -DBUILD_CLIENT=ON \
    -DBUILD_SERVER=ON

cmake --build . --config Release -j8
```

---

## Post-Build Setup

After building, runtime files must be copied to the build directory:

```bash
# Automatic (run from project root)
./scripts/post_build.sh --client-only
./scripts/post_build.sh --server-only

# Or manually copy:
# - NeL driver DLLs (nel_drv_opengl_win_r.dll, nel_drv_openal_win_r.dll)
# - Font files to data/font/
# - Level files to data/level/
# - Server Lua scripts to data/lua/
# - Config files
```

### Directory Structure After Build

```
build-client/bin/Release/
├── tux-target.exe
├── *.dll (runtime dependencies)
├── data/
│   ├── font/
│   ├── gui/
│   ├── level/
│   └── shape/
├── logs/
├── cache/
├── replay/
└── mtp_target_default.cfg

build-server/bin/Release/
├── tux-target-srv.exe
├── *.dll (runtime dependencies)
├── data/
│   ├── level/
│   └── lua/
├── logs/
└── mtp_target_service.cfg
```

---

## Running the Game

### With Log Rotation (Recommended)

```bash
# Start server
./scripts/run-server.sh

# Start client (in another terminal)
./scripts/run-client.sh
```

These scripts:
- Rotate old log files (keeps last 5)
- Move logs to `logs/` subdirectory
- Check for running services

### Direct Execution

```bash
# Server
cd build-server/bin/Release
./tux-target-srv.exe

# Client
cd build-client/bin/Release
./tux-target.exe
```

### In-Game

1. Select "Play on LAN"
2. Enter `localhost` for server address
3. Enter any username/password
4. Enjoy!

---

## GitHub Actions CI

The project includes GitHub Actions workflows for automated builds:

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | Push/PR to main branches | Build and test |
| `release.yml` | Tag push (`v*`) | Create GitHub release |

### Caching

CI builds cache:
- RyzomCore libraries (~500MB)
- Third-party dependencies (~200MB)

First build takes longer; subsequent builds use cached dependencies.

### Manual Release

1. Push a tag: `git tag v1.2.2a && git push origin v1.2.2a`
2. Or use workflow dispatch in GitHub Actions

---

## Troubleshooting

### CMake Configuration Errors

**"Could NOT find LibXml2"** or similar dependency errors
- Check that `C:\tux_target_deps` exists and contains subdirectories for each library
- Verify library names match: `libxml2.lib`, `libpng16.lib`, `jpeg.lib`, `freetype.lib`, `lua.lib`, `ode_doubles.lib`
- Set environment variables to override default paths:
  ```powershell
  $env:NEL_PREFIX_PATH = "C:/your/path/to/ryzomcore/build"
  $env:TUXDEPS_PREFIX_PATH = "C:/your/path/to/tux_target_deps"
  ```
- Then rebuild:
  ```bash
  ./scripts/build-client.bat --clean
  ```

**"cannot find -lnel3d" or similar NeL errors**
- Ensure RyzomCore is built at `C:\ryzomcore` (or set `NEL_PREFIX_PATH`)
- Check that `C:\ryzomcore\build\lib\Release\` contains:
  - `nelmisc_r.lib`, `nel3d_r.lib`, `nelsound_r.lib`, `nelnet_r.lib`, etc.
- The build scripts explicitly reference these libraries, so verify the exact filenames

**"Could NOT find Lua50"** but you have Lua 5.1
- We use Lua 5.1, not Lua 5.0
- Check `C:\tux_target_deps\lua\lib\lua.lib` exists
- The build scripts set `-DLUA_LIBRARIES` (plural) to resolve this

**"Could NOT find SSLEAY"** or OpenSSL errors
- OpenSSL library files are named `libssl.lib` and `libcrypto.lib` (not `ssleay32.lib`)
- Check `C:\tux_target_deps\openssl\lib\` for the correct filenames
- The build scripts use explicit paths: `-DSSLEAY_LIBRARY=%TUXDEPS_PREFIX_PATH%/openssl/lib/libssl.lib`

**CMake preset not found**
- Requires CMake 3.21+
- Check `CMakePresets.json` exists in project root
- Run from project root: `cmake --preset client`

### Compilation/Linking Errors

**"unresolved external symbol" for PNG, JPEG, or FreeType functions**
- These are required by NeL libraries but may not be explicitly linked
- Ensure `C:\tux_target_deps` contains:
  - `libpng/lib/libpng16.lib`
  - `libjpeg/lib/jpeg.lib`
  - `freetype/lib/freetype.lib`
- The build scripts include these explicitly for the server build
- If you see: `png_set_write_fn`, `jpeg_std_error`, `FT_Init_FreeType` - check these paths

**"undefined reference to ODE functions"** (on Linux)
- Ensure ODE is properly built and `libode.a` exists
- Check ODE_LIBRARY path points to the correct ODE build
- On Windows: check for `ode_doubles.lib` (not `ode.lib`)

**Slow parallel compilation**
- On Windows, the build scripts use MSBuild flag `/m:N` (not `-j`)
- Verify the correct flag is used:
  - Windows: `cmake --build . --config Release -- /m:32`
  - Linux/macOS: `cmake --build . --config Release -j32`
- If still slow, check `CMakeLists.txt` for `-j` flags in custom build rules

### Runtime Errors

**Missing DLL errors (zlib.dll, lua.dll, etc.)**
- Run post-build script: `.\scripts\post-build.bat --client-only` or `--server-only`
- The script copies DLLs from `C:\tux_target_deps\<library>\bin\`
- See [Runtime DLLs](#runtime-dlls) section below for the complete list

**"nel_drv_opengl_win_r.dll not found"**
- Run post_build script: `./scripts/post_build.sh --client-only`
- Or manually copy from `C:\ryzomcore\build\bin\Release\nel_drv_opengl_win_r.dll`
- Also need: `nel_drv_openal_win_r.dll`

**"data not found" warnings**
- Run from the correct directory (where `data/` exists)
- Or run post_build script to copy data files
- Build scripts run this automatically with `--skip-post-build` to disable

**Logs growing infinitely**
- Use `run-client.sh` / `run-server.sh` scripts
- They auto-rotate logs on startup
- Logs are stored in `logs/` subdirectory with automatic rotation (keeps 5 versions)

### Log Files

Logs are stored in `logs/` subdirectory:
- `log.log` - Main application log
- `mtp_target_service.log` - Server log
- `chat.log` - Chat history
- `nel_debug.dmp` - Crash dumps

Old logs are numbered: `log.log.1`, `log.log.2`, etc.

### Runtime DLLs

The post-build script (`scripts/post-build.bat`) copies these DLLs from `C:\tux_target_deps`.

**Server DLLs** (required for `tux-target-srv.exe`):

| DLL | Source Path | Library |
|-----|-------------|---------|
| `lua.dll` | `lua/bin/` | Lua 5.1 scripting |
| `zlib.dll` | `zlib/bin/` | Compression |
| `freetype.dll` | `freetype/bin/` | Font rendering |
| `libpng16.dll` | `libpng/bin/` | PNG image loading |
| `jpeg62.dll` | `libjpeg/bin/` | JPEG image loading |

**Client DLLs** (all server DLLs plus these):

| DLL | Source Path | Library |
|-----|-------------|---------|
| `libxml2.dll` | `libxml2/bin/` | XML parsing |
| `libcurl.dll` | `curl/bin/` | HTTP client |
| `libcrypto-1_1-x64.dll` | `openssl/bin/` | OpenSSL crypto |
| `libssl-1_1-x64.dll` | `openssl/bin/` | OpenSSL SSL/TLS |
| `ogg.dll` | `ogg/bin/` | Ogg container |
| `vorbis.dll` | `vorbis/bin/` | Vorbis audio codec |
| `vorbisfile.dll` | `vorbis/bin/` | Vorbis file I/O |
| `OpenAL32.dll` | `openal-soft/bin/` | 3D audio |

**NeL Driver DLLs** (from `C:\ryzomcore\build\bin\Release\`):

| DLL | Purpose |
|-----|---------|
| `nel_drv_opengl_win_r.dll` | OpenGL graphics driver |
| `nel_drv_openal_win_r.dll` | OpenAL sound driver |

---

## Building Dependencies

### RyzomCore (NeL)

```bash
git clone https://github.com/ryzom/ryzomcore.git C:/ryzomcore
cd C:/ryzomcore
mkdir build && cd build

cmake .. -G "Visual Studio 17 2022" -A x64 \
    -DWITH_SOUND=ON \
    -DWITH_NEL=ON \
    -DWITH_NEL_TOOLS=OFF \
    -DWITH_RYZOM=OFF \
    -DWITH_STATIC=ON

cmake --build . --config Release -j8
```

### ODE (Physics)

Download ODE 0.16.5 from https://ode.org/ and build with CMake.

### Other Dependencies

Consider using vcpkg for: libxml2, libcurl, openssl, freetype, libjpeg, libpng, lua, libogg, libvorbis.

---

## See Also

- [README.md](../README.md) - Project overview
- [RUNTIME_FIXES.md](RUNTIME_FIXES.md) - Runtime issues and fixes
- [MODIFICATIONS.md](MODIFICATIONS.md) - Source code changes
- [LEVELS.md](LEVELS.md) - Level list and commands
