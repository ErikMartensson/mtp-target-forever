# MTP Target - Ubuntu/WSL Setup Guide

## ✅ COMPILATION SUCCESSFUL!

**Status:** Game server successfully compiled and running in Ubuntu/WSL!

This document records the actual steps that worked to compile the MTP Target game server.

---

## System Environment

- **OS:** Ubuntu on WSL2 (Windows Subsystem for Linux)
- **Working Directory:** `/mnt/c/Users/User/Playground/mtp_target`
- **Compiler:** g++ (Ubuntu 13.2.0)
- **Build System:** Make (GNU Make 4.3)

---

## Step 1: Install Build Dependencies

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    libxml2-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxxf86vm-dev \
    libxrandr-dev \
    libxrender-dev \
    libmysqlclient-dev \
    lua5.1 \
    liblua5.1-0-dev \
    libcurl4-openssl-dev \
    libluabind-dev \
    libode-dev
```

**Key Dependencies:**
- `lua5.1` - Lua 5.0 not available, 5.1 is compatible
- `libode-dev` - Modern ODE 0.16.2 (replaces old ODE 0.5)
- `libluabind-dev` - Brings in Boost dependencies
- `ninja-build` - For building RyzomCore NeL

---

## Step 2: Build RyzomCore NeL Framework

NeL (Nevrax Engine Library) is the core framework. We used RyzomCore, the modern successor:

```bash
cd /mnt/c/Users/User/Playground/mtp_target

# Clone RyzomCore
git clone https://github.com/ryzom/ryzomcore.git
cd ryzomcore

# Create build directory
mkdir build
cd build

# Configure with Ninja (disable sound to avoid FMOD dependency)
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_SOUND=OFF \
    ..

# Build (takes ~5-10 minutes, compiles 687 files)
ninja

# Libraries are now in: ryzomcore/build/lib/
# - libnel3d.so.4.1.0.1062 (7.9 MB)
# - libnelnet.so.4.1.0.1062 (1.5 MB)
# - libnelmisc.so.4.1.0.1062 (2.1 MB)
```

---

## Step 3: Update MTP Target Build Configuration

### Update Variables.mk

File: `mtp-target/Variables.mk`

```makefile
# Updated paths for modern build environment
NEL_INCLUDE = /mnt/c/Users/User/Playground/mtp_target/ryzomcore/nel/include
NEL_LIB     = /mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib
NEL_SOURCE  = /mnt/c/Users/User/Playground/mtp_target/ryzomcore/nel/src

LUA_INCLUDE = /usr/include/lua5.1
LUA_LIB     = /usr/lib/x86_64-linux-gnu

LIBXML2_INCLUDE = /usr/include/libxml2
LIBXML2_LIB     = /usr/lib/x86_64-linux-gnu
```

### Update Server Makefile

File: `mtp-target/server/src/Makefile`

**CXXFLAGS changes:**
```makefile
CXXFLAGS = $(FLAGS_CMN) $(FLAGS_DBG_$(DBG)) \
    -DMTPT_SERVER \
    -I../../common \
    -I/usr/include \          # System ODE headers
    -I$(LIBXML2_INCLUDE) \
    -I$(NEL_INCLUDE) \
    -I$(NEL_INCLUDE)/nel \    # Dual include for NeL compatibility
    -I$(NEL_SOURCE) \
    -I$(LUA_INCLUDE)
```

**LDFLAGS changes:**
```makefile
LDFLAGS = -L$(HOME)/install/$(DIR_DBG_$(DBG))/lib \
    -L/usr/lib/x86_64-linux-gnu \    # System ODE library
    -L$(NEL_LIB) \
    -L$(LUA_LIB) \
    -L$(LIBXML2_LIB) \
    -lnel3d \
    -lnelnet \
    -lnelmisc \
    -L/usr/lib \
    -L/usr/X11R6/lib \
    -llua5.1 \                       # Changed from -llua -llualib
    -lc \
    -lxml2 \
    -lz \
    -lm \
    -lpthread \
    -lcrypt \
    -ljpeg \
    -lode                            # System ODE library
```

---

## Step 4: Fix Source Code Compatibility Issues

### Lua 5.0 → 5.1 API Migration

**File:** `mtp-target/common/lua_utility.cpp`

```cpp
// OLD (Lua 5.0):
lua_baselibopen(L);
lua_iolibopen(L);
lua_strlibopen(L);
// ... etc

// NEW (Lua 5.1):
luaL_openlibs(L);  // Opens all standard libraries
```

```cpp
// OLD:
lua_dofile(L, fn.c_str());

// NEW:
luaL_dofile(L, fn.c_str());
```

```cpp
// OLD:
lua_setgcthreshold(L, 0);

// NEW:
lua_gc(L, LUA_GCCOLLECT, 0);
```

### Modern NeL Command Interface

**File:** `mtp-target/server/src/command.h`

Added missing override for modern NeL ICommand:
```cpp
class CCommand : public NLMISC::ICommand
{
public:
    // ... existing methods ...

    // Override for modern NeL ICommand interface
    virtual bool execute(const std::string &rawCommandString,
                        const std::vector<std::string> &args,
                        NLMISC::CLog &log, bool quiet, bool human = true)
    {
        return execute(args, log, quiet, human);
    }
};
```

**File:** `mtp-target/server/src/command.cpp`

```cpp
// OLD:
TCommand::iterator comm = (*Commands).find(commands[u].first);

// NEW:
TCommand::iterator comm = ICommand::LocalCommands->find(commands[u].first);
```

```cpp
// OLD:
if (!icom->execute(commands[u].second, log, quiet, human))

// NEW (add rawCommandString parameter):
if (!icom->execute(commands[u].first, commands[u].second, log, quiet, human))
```

### Network Service ID Type Changes

**File:** `mtp-target/server/src/welcome.cpp`

Changed all callback signatures from `uint16` to `TServiceId`:
```cpp
// OLD:
void cbLSChooseShard(CMessage &msgin, const std::string &serviceName, uint16 sid)

// NEW:
void cbLSChooseShard(CMessage &msgin, const std::string &serviceName, TServiceId sid)
```

Fixed printf format:
```cpp
// OLD:
nlinfo("Connected to %s-%hu ...", serviceName.c_str(), sid, shardId);

// NEW:
nlinfo("Connected to %s-%hu ...", serviceName.c_str(), sid.get(), shardId);
```

### 64-bit Size Type Compatibility

Changed `unsigned int` to `size_t` for `luaL_checklstring()`:

**Files affected:**
- `mtp-target/server/src/entity_lua_proxy.cpp:290`
- `mtp-target/server/src/module_lua_proxy.cpp:169`
- `mtp-target/server/src/lua_engine.cpp:477,493,549,566,587`

```cpp
// OLD:
unsigned int len;
const char *text = luaL_checklstring(L, 1, &len);

// NEW:
size_t len;
const char *text = luaL_checklstring(L, 1, &len);
```

### Namespace Collision Fix

**File:** `mtp-target/server/src/physics.cpp`

```cpp
// OLD:
IThread *thread = 0;  // Conflicts with std::thread

// NEW:
IThread *physicsThread = 0;
```

### ODE Initialization

**File:** `mtp-target/server/src/physics.cpp`

```cpp
void initPhysics()
{
    // Initialize ODE library (required for modern ODE 0.16+)
    dInitODE();

    World = dWorldCreate();
    // ... rest of function
}
```

---

## Step 5: Build the Server

```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target

# Generate dependency files (first time only)
make -C server update

# Build the server
make -C server all

# Success! Binary created:
# mtp-target/server/src/mtp_target_service (20 MB, 64-bit ELF)
```

**Build output summary:**
- ✅ All 34 source files compiled
- ✅ Zero errors
- ✅ Only format warnings (non-critical)
- ✅ Binary linked successfully

---

## Step 6: Configure and Run the Server

### Copy Configuration File

```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server/src

# Copy default config
cp ../mtp_target_service_default.cfg mtp_target_service.cfg
```

### Run the Server

```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server/src

# Set NeL library path and run
LD_LIBRARY_PATH=/mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib:$LD_LIBRARY_PATH \
./mtp_target_service
```

### Expected Output (Success!)

```
INF: CCommandRegistry : adding commands handler for class 'CModuleManager'
INF: Adding module 'LocalGateway' factory
INF: Adding module 'StandardGateway' factory
INF: SERVICE: Starting Service 'MTS' using NeL (Dec 14 2025)
INF: set gravity : off
INF: Running server in LAN mode
INF: SERVICE: Service ready
INF: Adding bot eid 0 name 'alice'
INF: Adding bot eid 1 name 'starfox'
INF: Adding bot eid 2 name 'chikant'
INF: Adding bot eid 3 name 'bill'
INF: Adding bot eid 4 name 'ringo'
```

---

## Known Issues and Solutions

### Issue: Data Directory Not Found

**Warning:**
```
WRN: PATH: CPath::addSearchFile(data, 0, ''): 'data' is not found
```

**Solution (choose one):**

Option A - Run from server directory:
```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server
LD_LIBRARY_PATH=/mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib \
./src/mtp_target_service
```

Option B - Create symlink:
```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server/src
ln -s ../data data
```

### Issue: fgets Failed Warning

**Warning:**
```
WRN: fgets failed
```

**Cause:** stdin monitoring thread (non-critical)

**Solution:** Ignore - does not affect server functionality

---

## Complete Service Stack

### Terminal 1: Login Service (Deno)

```bash
cd /mnt/c/Users/User/Playground/mtp_target/login-service-deno
deno run --allow-net --allow-read --allow-write --allow-env --allow-ffi main.ts
```

- Listens on: **Port 49997**
- Purpose: Authenticate clients, return shard list

### Terminal 2: HTTP Server (Deno, Windows as Admin)

```bash
cd login-service-deno
deno run --allow-net --allow-read http-server.ts
```

- Listens on: **Port 80**
- Purpose: Client startup checks

### Terminal 3: Game Server (C++, WSL)

```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server
LD_LIBRARY_PATH=/mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib \
./src/mtp_target_service
```

- Listens on: **Port 51574**
- Purpose: Actual gameplay

### Hosts File (Windows)

`C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 mtp-target.dyndns.org
127.0.0.1 www.mtp-target.org
```

---

## Verification Checklist

Before launching the game client:

- [x] Login service running on port 49997
- [x] HTTP server running on port 80 (as admin)
- [x] Game server running on port 51574
- [x] Hosts file configured
- [x] SQLite database has online shard entry
- [x] All services showing "ready" in logs

---

## Next Steps

1. **Test Client Connection:**
   - Launch game client: `C:\Program Files (x86)\Mtp Target 2\mtp_target_client.exe`
   - Login with: username=`test`, password=`test`
   - Client should connect to game server

2. **Monitor Server Logs:**
   - Watch for client connection messages
   - Check for authentication success
   - Verify level loading

3. **Troubleshooting:**
   - If connection fails, check firewall
   - Verify WSL networking (should auto-forward ports)
   - Check server logs for errors

---

## File Locations Quick Reference

**Source:**
- `mtp-target/server/src/` - Server source code
- `mtp-target/common/` - Shared code

**Built:**
- `mtp-target/server/src/mtp_target_service` - Game server binary (20 MB)
- `ryzomcore/build/lib/` - NeL libraries

**Config:**
- `mtp-target/server/src/mtp_target_service.cfg` - Server config
- `login-service-deno/mtp_target.db` - User database (SQLite)

**Data:**
- `mtp-target/server/data/` - Levels, modules, Lua scripts

---

## Success Criteria

✅ **Compilation:**
- [x] All dependencies installed
- [x] RyzomCore NeL compiled
- [x] Game server compiled without errors
- [x] Binary created and executable

✅ **Runtime:**
- [x] Server starts without crashes
- [x] ODE physics initialized
- [x] Bots loaded
- [x] Network listener on port 51574

⏳ **Testing:**
- [x] Client connects to Login Service
- [x] Client receives Shard List
- [x] Client selects Shard
- [ ] Client connects to Game Server (Crashes with Runtime Error)

---

## Summary of Achievements

**What We Built:**
- ✅ Modern NeL framework (RyzomCore)
- ✅ MTP Target game server (20 MB binary)
- ✅ Full compatibility with Ubuntu/WSL
- ✅ Deno-based Login Service with correct NeL protocol

**Compatibility Fixes Applied:**
- ✅ Lua 5.0 → 5.1 migration (3 API changes)
- ✅ Modern NeL command interface (2 files)
- ✅ TServiceId type migration (4 functions)
- ✅ 64-bit size_t compatibility (7 instances)
- ✅ Namespace collision resolution (1 file)
- ✅ ODE 0.5 → 0.16 upgrade
- ✅ NeL Protocol Header (Big-Endian Length)
- ✅ NeL Protocol String Encoding (Wide Strings for Shard Name)

**Time Investment:**
- Build system setup: ~15 minutes
- Dependency compilation: ~10 minutes
- Source fixes: ~45 minutes
- Protocol debugging: ~60 minutes
- Total: ~130 minutes to working server + login

---

For full project context and history, see **CLAUDE.md**.
