# Building MTP Target Forever

This guide covers building the MTP Target Forever game server and client from source on Windows.

---

## Table of Contents

- [Quick Start (Windows)](#quick-start-windows)
- [Prerequisites](#prerequisites)
- [Step 1: Setup Dependencies](#step-1-setup-dependencies)
- [Step 2: Build RyzomCore (NeL)](#step-2-build-ryzomcore-nel)
- [Step 3: Build Game](#step-3-build-game)
- [Running the Game](#running-the-game)
- [GitHub Actions CI](#github-actions-ci)
- [Troubleshooting](#troubleshooting)

---

## Quick Start (Windows)

```powershell
# 1. Install dependencies (downloads ~1.3GB, installs ODE via vcpkg)
.\scripts\setup-deps.ps1

# 2. Build RyzomCore/NeL (one-time, ~5 min with Ninja)
.\scripts\setup-ryzomcore.ps1

# 3. Build client and server (auto-detects MSVC environment)
.\scripts\build-client.bat
.\scripts\build-server.bat

# 4. Run the game
.\scripts\run-server.bat          # Terminal 1
.\scripts\run-client.bat --lan localhost --user YourName  # Terminal 2
```

---

## Prerequisites

### Windows

**Required:**
- Visual Studio 2022 Build Tools (or full VS2022) with C++ Desktop Development
- CMake 3.20+
- Ninja build system
- Git for Windows / Git Bash
- PowerShell 5.1+
- vcpkg (for ODE physics library - required for server builds)

### Installing Visual Studio Build Tools

1. Download from https://visualstudio.microsoft.com/downloads/
2. Select "Build Tools for Visual Studio 2022"
3. In installer, select "Desktop development with C++"

### Installing Ninja

```powershell
# Using Chocolatey (recommended)
choco install ninja

# Or download from https://ninja-build.org/
```

### Installing vcpkg (for server builds)

```powershell
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat
```

---

## Step 1: Setup Dependencies

The `setup-deps.ps1` script downloads the same pre-built dependencies used by CI:

```powershell
# Full setup (client + server)
.\scripts\setup-deps.ps1

# Client only (skip ODE physics library)
.\scripts\setup-deps.ps1 -SkipODE

# Force re-download
.\scripts\setup-deps.ps1 -Force

# Verify existing installation
.\scripts\setup-deps.ps1 -Verify
```

### What gets installed

Dependencies are installed to `deps/` in the repository (git-ignored):

| Library | Purpose |
|---------|---------|
| libxml2 | XML parsing |
| zlib | Compression |
| lua | Scripting (5.1) |
| luabind | Lua/C++ binding |
| curl | HTTP client |
| openssl | SSL/TLS |
| freetype | Font rendering |
| libpng | PNG images |
| libjpeg | JPEG images |
| ogg/vorbis | Audio codecs |
| openal-soft | 3D audio |
| boost | C++ libraries |
| ODE | Physics (server only, via vcpkg) |

### Custom dependency location

To use a different location, set `MTPDEPS_PATH`:

```powershell
$env:MTPDEPS_PATH = "D:\my-deps"
.\scripts\build-client.bat
```

---

## Step 2: Build RyzomCore (NeL)

RyzomCore provides the NeL game engine libraries. This is a one-time build.

### Automated Setup (Recommended)

```powershell
# Auto-detects MSVC environment - no special shell required
.\scripts\setup-ryzomcore.ps1

# Force rebuild
.\scripts\setup-ryzomcore.ps1 -Force

# Just rebuild (don't re-clone)
.\scripts\setup-ryzomcore.ps1 -BuildOnly
```

The script:
- Clones RyzomCore to `ryzomcore/` in the repo (git-ignored)
- Uses Ninja for fast builds (~5 minutes)
- Automatically finds dependencies from `deps/`
- Auto-detects and configures MSVC environment

### Manual Setup

If you prefer manual control:

```powershell
# Clone RyzomCore
git clone --depth 1 https://github.com/ryzom/ryzomcore.git ryzomcore
cd ryzomcore
mkdir build
cd build

# Configure with Ninja (point to our dependencies)
cmake .. -G Ninja `
    -DCMAKE_BUILD_TYPE=Release `
    -DWITH_SOUND=ON `
    -DWITH_NEL=ON `
    -DWITH_NEL_TOOLS=OFF `
    -DWITH_NEL_TESTS=OFF `
    -DWITH_NEL_SAMPLES=OFF `
    -DWITH_RYZOM=OFF `
    -DWITH_STATIC=ON `
    -DCMAKE_PREFIX_PATH="$(pwd)/../deps"

# Build (takes ~5 minutes)
cmake --build . --parallel 4 --target nelmisc nel3d nelnet nelsound nelsnd_lowlevel nelgeorges nelligo
cmake --build . --parallel 2 --target nel_drv_opengl_win nel_drv_openal_win
```

### Verify RyzomCore build

Check that these files exist (Ninja outputs to `lib/` and `bin/`, not `lib/Release/`):
- `ryzomcore/build/lib/nelmisc_r.lib`
- `ryzomcore/build/lib/nel3d_r.lib`
- `ryzomcore/build/bin/nel_drv_opengl_win_r.dll`
- `ryzomcore/build/bin/nel_drv_openal_win_r.dll`

### Custom RyzomCore location

To use a different location, set `NEL_PREFIX_PATH`:

```powershell
$env:NEL_PREFIX_PATH = "D:\my-ryzomcore\build"
.\scripts\build-client.bat
```

---

## Step 3: Build Game

### Build Scripts

| Script | Purpose |
|--------|---------|
| `scripts\build-client.bat` | Build client to `build-client/` |
| `scripts\build-server.bat` | Build server to `build-server/` |
| `scripts\post-build.bat` | Copy runtime files (called automatically) |
| `scripts\run-client.bat` | Start client |
| `scripts\run-server.bat` | Start server |

### Build Client

```powershell
.\scripts\build-client.bat

# Clean build
.\scripts\build-client.bat --clean

# Skip post-build file copying
.\scripts\build-client.bat --skip-post-build
```

### Build Server

```powershell
.\scripts\build-server.bat

# Clean build
.\scripts\build-server.bat --clean
```

### Output Structure

Ninja outputs to `bin/` (not `bin/Release/` like Visual Studio):

```
build-client/bin/
├── mtp-target-forever.exe
├── *.dll (runtime dependencies)
├── data/
│   ├── font/
│   ├── gui/
│   ├── level/
│   ├── shape/
│   └── texture/
└── mtp_target_default.cfg

build-server/bin/
├── mtp-target-forever-srv.exe
├── *.dll (runtime dependencies)
├── data/
│   ├── level/
│   └── lua/
└── mtp_target_service.cfg
```

---

## Running the Game

### Using Run Scripts

```powershell
# Terminal 1: Start server
.\scripts\run-server.bat

# Terminal 2: Start client
.\scripts\run-client.bat --lan localhost --user YourName
```

### Direct Execution

```powershell
# Server
cd build-server\bin
.\mtp-target-forever-srv.exe

# Client
cd build-client\bin
.\mtp-target-forever.exe
```

### In-Game

1. Select "Play on LAN"
2. Enter `localhost` for server address
3. Enter any username
4. Enjoy!

---

## GitHub Actions CI

The project has automated CI builds on GitHub Actions.

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | Push/PR to main | Build client and server |

### Caching

CI builds cache:
- External dependencies (~1.5GB compressed)
- RyzomCore libraries (~200MB)

First build takes ~20 minutes; subsequent builds use cached dependencies.

### Download Artifacts

After a successful CI build:
1. Go to Actions tab on GitHub
2. Select the build run
3. Download `mtp-target-forever-client-windows-Release` or `mtp-target-forever-server-windows-Release`

---

## Troubleshooting

### Dependency Errors

**"Dependencies not found"**
```powershell
# Run setup script
.\scripts\setup-deps.ps1

# Or verify existing installation
.\scripts\setup-deps.ps1 -Verify
```

**"ODE not found" (server build)**
```powershell
# Install vcpkg first
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat

# Then re-run setup
.\scripts\setup-deps.ps1 -Force
```

### CMake Errors

**"Could NOT find NeL"**
- Run `.\scripts\setup-ryzomcore.ps1` first
- Or set: `$env:NEL_PREFIX_PATH = "D:\your\path\to\ryzomcore\build"`

**"Could NOT find CURL"**
- Run `.\scripts\setup-deps.ps1 -Verify` to check dependencies
- The setup script should have downloaded curl

### Linker Errors

**"unresolved external symbol curl_*"**
- Both `CURL_LIBRARY` and `CURL_LIBRARIES` must be set
- The build scripts handle this automatically

**"unresolved external symbol ode*" (server)**
- ODE physics library not installed
- Run: `.\scripts\setup-deps.ps1` (requires vcpkg)

### Runtime Errors

**Missing DLL errors**
- Run post-build script: `.\scripts\post-build.bat --client-only`
- DLLs are copied from `deps/*/bin/`

**"nel_drv_opengl_win_r.dll not found"**
- Run post-build script
- Or manually copy from `ryzomcore/build/bin/`

**"data not found"**
- Run from the build directory (where `data/` exists)
- Or run post-build script to copy data files

### Log Files

Logs are in the build directory:
- `mtp_target_service.log` - Server log
- `log.log` - Client log

---

## See Also

- [README.md](../README.md) - Project overview
- [RUNTIME_FIXES.md](RUNTIME_FIXES.md) - Runtime issues and fixes
- [CONTROLS.md](CONTROLS.md) - Game controls
- [LEVELS.md](LEVELS.md) - Level list and commands
