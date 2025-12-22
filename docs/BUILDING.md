# Building MTP Target

This guide covers building the MTP Target game server and client from source on modern systems.

---

## Prerequisites

### Common Requirements (All Platforms)
- C++ compiler (GCC 7+ or Visual Studio 2019+)
- CMake 3.10+
- Git

### Platform-Specific Requirements

#### Ubuntu/Linux (tested on Ubuntu 22.04/WSL2)
```bash
sudo apt update
sudo apt install -y \
    build-essential cmake git ninja-build \
    libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev libmysqlclient-dev \
    lua5.1 liblua5.1-0-dev \
    libcurl4-openssl-dev libluabind-dev \
    libode-dev
```

#### Windows (TODO - not yet tested)
- Visual Studio 2019 or 2022 with C++ Desktop Development workload
- Windows SDK
- Git for Windows
- Dependencies (pre-built or via vcpkg):
  - NeL/RyzomCore libraries
  - Lua 5.1
  - ODE physics engine
  - libxml2, freetype, etc.

---

## Step 1: Build NeL Framework (RyzomCore)

The NeL (Nevrax Engine Library) framework is required for both the server and client.

### Ubuntu/Linux

```bash
# Clone RyzomCore (modern NeL fork)
git clone https://github.com/ryzom/ryzomcore.git
cd ryzomcore

# Create build directory
mkdir build && cd build

# Configure (disable sound to avoid FMOD dependency)
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_SOUND=OFF \
    ..

# Build (takes ~5-10 minutes)
ninja

# Libraries will be in: ryzomcore/build/lib/
# Headers are in: ryzomcore/nel/include/
```

### Windows
```powershell
# TODO: Add Windows CMake build instructions
# May need to use Visual Studio generator instead of Ninja
```

---

## Step 2: Build Game Server

### Ubuntu/Linux

```bash
cd tux_target  # or wherever you cloned this repo

# Update Makefiles with your RyzomCore paths
# Edit Variables.mk if needed (should auto-detect)

# Generate dependency files
make -C server update

# Build the server
make -C server all

# Binary will be: server/src/mtp_target_service
```

**Running the server:**
```bash
cd server/src

# Set NeL library path
export LD_LIBRARY_PATH=/path/to/ryzomcore/build/lib:$LD_LIBRARY_PATH

# Run server
./mtp_target_service

# Server will listen on port 51574 (Easy mode) and 51575 (Expert mode)
```

### Windows
```powershell
# TODO: Add Windows build instructions
# Will likely use CMake + Visual Studio solution
```

---

## Step 3: Build Login Service (C++)

The C++ login service is optional - we have a working Deno/TypeScript version. Build only if you need the original.

### Ubuntu/Linux

```bash
cd login_service

# Update Makefile with your NeL paths if needed
make clean
make all

# Binary will be: login_service/login_service
```

**Running:**
```bash
cd login_service

# Set NeL library path
export LD_LIBRARY_PATH=/path/to/ryzomcore/build/lib:$LD_LIBRARY_PATH

# Run (requires MySQL database)
./login_service
```

---

## Step 4: Build Client (TODO)

Client compilation instructions coming soon. Requires:
- All the same dependencies as the server
- Additional graphics libraries (OpenGL, etc.)
- Potentially FMOD for sound

---

## Troubleshooting

### Common Build Errors

**"cannot find -lnel3d"**
- Ensure RyzomCore is built successfully
- Check Variables.mk has correct NEL_LIB path
- Verify LD_LIBRARY_PATH includes the NeL library directory

**"Lua 5.0 not found"**
- Lua 5.0 is obsolete - use Lua 5.1 instead
- Our source code patches are already applied for 5.1 compatibility

**"ODE headers not found"**
- Install libode-dev (Ubuntu) or build ODE from source
- We support both old ODE 0.5 and modern ODE 0.16+

**"undefined reference to dInitODE"**
- You're using ODE 0.16+ which requires explicit initialization
- Our patches already include this fix

**Format warnings about time_t**
- These are non-critical warnings, safe to ignore
- They don't affect functionality

### Runtime Warnings

**"PATH: CPath::addSearchFile(data, 0, ''): 'data' is not found"**
- Server expects `data/` directory in current working directory
- Solution: Run from `server/` directory instead of `server/src/`
- Or: Create symlink `ln -s ../data data` in `server/src/`

**"fgets failed"**
- Non-critical stdin monitoring warning
- Safe to ignore

---

## Source Code Modifications

All modern compatibility fixes have been applied. See [MODIFICATIONS.md](MODIFICATIONS.md) for details:
- Lua 5.0 → 5.1 API migration
- 64-bit compatibility (size_t fixes, pointer casts)
- Modern NeL API (ICommand interface, TServiceId)
- ODE 0.16 support (dInitODE call)
- Namespace collision fixes

---

## Alternative: Deno Login Service (Recommended)

Instead of building the C++ login service, use our TypeScript implementation:

**Requirements:**
- Deno 2.6.0+ ([install](https://deno.land/))

**Setup:**
```bash
cd login-service-deno

# Initialize database
deno task db-setup

# Start login service (port 49997)
deno task login

# Start HTTP server (port 80, requires admin/sudo)
sudo deno task http
```

**Advantages:**
- No C++ compilation needed
- SQLite instead of MySQL
- Easier to debug and modify
- Proven to work with the game client

---

## Next Steps

1. **Test the Server:** Start the game server and verify it initializes
2. **Set up Login Service:** Either build C++ version or use Deno version
3. **Configure Hosts File:** Point game domains to localhost
4. **Test Connection:** Try connecting with the game client

See the main [README.md](../README.md) for full setup instructions.
