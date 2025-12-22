# MTP Target Server Restoration - Complete Summary

**Date Range:** December 14-22, 2025
**Goal:** Restore MTP Target game to playable state with local server setup
**Status:** Login service and game server operational; client SCS message format incompatible with installed binary

---

## Executive Summary

We successfully:
- ✅ Compiled and ran the game server (C++ with NeL framework)
- ✅ Built a working Deno-based login service that handles VLP (login) and CS (shard selection) messages
- ✅ Set up complete database schema with SQLite
- ✅ Fixed compilation issues for modern systems (64-bit, ODE 0.16, Lua 5.1, modern NeL)
- ❌ **BLOCKED:** SCS (Shard Choose Shard) response crashes the installed client v1.5.19 (build 708117)

**Root Cause:** The compiled client binary does NOT match the source code. Our SCS bytes match the C++ source exactly, but the binary expects a different format.

**Next Step:** Compile the client from source to ensure binary/source compatibility.

---

## Architecture Overview

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Client    │────────>│Login Service │────────>│   Database   │
│ (Windows)   │  VLP    │  (Deno/TS)   │  Query  │  (SQLite)    │
│             │<────────│   Port 49997 │<────────│              │
└─────────────┘  Shards └──────────────┘         └──────────────┘
       │                                                   │
       │ CS (Choose Shard)                                │
       v                                                   v
┌─────────────┐                                    ┌──────────────┐
│Login Service│                                    │    Shard     │
│             │                                    │    Table     │
└─────────────┘                                    └──────────────┘
       │
       │ SCS (Response) ❌ CRASHES HERE
       v
┌─────────────┐
│   Client    │
│  (CRASH)    │
└─────────────┘
```

---

## What We Built

### 1. Deno Login Service (`login-service-deno/`)

**Files:**
- `login-only.ts` - Main TCP server (port 49997)
- `http-only.ts` - HTTP server for client startup checks (port 80)
- `nel-protocol-v2.ts` - NeL binary protocol implementation
- `db-setup.ts` - SQLite database initialization
- `mtp_target.db` - SQLite database with user and shard tables

**Features:**
- ✅ Handles VLP (Verify Login Password) - client authentication
- ✅ Returns shard list with Wide strings (UTF-16LE) for shard names
- ✅ Handles CS (Choose Shard) - shard selection
- ❌ SCS (Shard Choose Shard) response crashes client

**Starting the Services:**
```bash
# Terminal 1 - HTTP Server (requires sudo for port 80)
cd /mnt/c/Users/User/Playground/mtp_target/login-service-deno
sudo deno run --allow-net --allow-env http-only.ts

# Terminal 2 - Login Service
cd /mnt/c/Users/User/Playground/mtp_target/login-service-deno
deno run --allow-net --allow-read --allow-write --allow-env --allow-ffi --watch-exclude='*.db' login-only.ts
```

### 2. Game Server (`mtp-target/server/`)

**Built successfully with:**
- RyzomCore NeL libraries (modern fork)
- System ODE 0.16.2 (physics engine)
- Lua 5.1 (scripting)
- MySQL client libraries

**Starting the Game Server:**
```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server/src
LD_LIBRARY_PATH=/mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib:$LD_LIBRARY_PATH ./mtp_target_service
```

**Status:** ✅ Runs successfully, waiting for client connections on port 51574

### 3. Database Schema

**Tables:**
- `user` - Player accounts (UID, Login, Password, Cookie, Score, etc.)
- `shard` - Game servers (ShardId, Name, State, Address, Port)

**Test Data:**
- User: `test` / `test` (UID: 1)
- Shard: `Easy` (ID: 100, port 51574, State: Online)

---

## Critical Discoveries

### 1. Binary vs Source Mismatch

The installed client (`C:\Program Files (x86)\Mtp Target\client\mtp_target.exe`) v1.5.19 (build 708117) does **NOT** match the source code:

| Field | Source Code | Binary Behavior |
|-------|-------------|-----------------|
| VLP Login | `std::string` | Sends as Wide (UTF-16LE) ✓ |
| VLP ShardName | `std::string` | **Expects Wide (UTF-16LE)** ✓ |
| SCS Cookie | `std::string` | Unknown - all formats crash ❌ |
| SCS Address | `std::string` | Unknown - all formats crash ❌ |

### 2. NeL Protocol Details

**Message Format:**
```
[4 bytes BE: Length] [1 byte: Format] [String: MessageType] [Payload...]
```

**String Serialization:**
- `std::string` (ASCII): `[4 bytes LE: length] [N bytes: ASCII data]`
- `ucstring` (Wide): `[4 bytes LE: char count] [N×2 bytes: UTF-16LE data]`

**VLP Response (Working):**
```
Header: 00 00 00 21 (33 bytes, BE)
Format: 01
MsgType: "VLP" (ASCII)
Reason: "" (empty = success)
NbShards: 1
ShardName: "Easy" (WIDE - UTF-16LE) ← Key discovery!
NbPlayers: 0
ShardId: 100
```

### 3. SCS Message Investigation

**What We Tried (16 tests total):**

| Test | Reason | Cookie | Address | Result |
|------|--------|--------|---------|--------|
| 1-13 | Various combinations | A/W/B | A/W | All crashed |
| 14 | A (empty) | A | A | Crashed (matches C++ exactly!) |
| 15 | A (empty) | A | A | Crashed (cookie always sent) |
| 16 | A (empty) | A | A | Crashed (cookie only on success) |

**Legend:**
- A = ASCII string
- W = Wide string (UTF-16LE)
- B = Binary (3×uint32)

**Byte-for-Byte Match Confirmed:**
Our Deno service generates **EXACTLY** the same bytes as the C++ `CMessage` class:
```
00 00 00 3d 01 03 00 00 00 53 43 53 00 00 00 00
1a 00 00 00 30 30 30 30 30 30 30 30 7c 36 30 37
41 39 38 38 30 7c 30 30 30 30 30 30 30 31 0f 00
00 00 31 32 37 2e 30 2e 30 2e 31 3a 35 31 35 37
34
```

Yet the client still crashes with "Stream Overflow Error".

**Conclusion:** The binary expects a completely different format than the source code shows.

---

## Compilation Fixes Applied

### Game Server (`mtp-target/server/`)

**1. Lua 5.0 → 5.1 Migration** ([lua_utility.cpp](mtp-target/common/lua_utility.cpp))
```cpp
// Old Lua 5.0 API
lua_baselibopen(L);
lua_dofile(L, filename);

// New Lua 5.1 API
luaL_openlibs(L);
luaL_dofile(L, filename);
```

**2. Modern NeL Command System** ([command.h](mtp-target/server/src/command.h), [command.cpp](mtp-target/server/src/command.cpp))
- Added `ICommand::execute()` override with new signature
- Changed `Commands` → `ICommand::LocalCommands`

**3. TServiceId Type Changes** ([welcome.cpp](mtp-target/server/src/welcome.cpp))
```cpp
// Old: uint16 sid
void cbLSChooseShard(CMessage &msgin, const std::string &serviceName, TServiceId sid)
```

**4. 64-bit Size Types** ([entity_lua_proxy.cpp](mtp-target/server/src/entity_lua_proxy.cpp), [module_lua_proxy.cpp](mtp-target/server/src/module_lua_proxy.cpp), [lua_engine.cpp](mtp-target/server/src/lua_engine.cpp))
```cpp
// Old: unsigned int len
size_t len;
luaL_checklstring(L, index, &len);
```

**5. ODE Initialization** ([physics.cpp](mtp-target/server/src/physics.cpp))
```cpp
void initPhysics() {
    dInitODE();  // Required for modern ODE
    // ...
}
```

**6. Namespace Collision** ([physics.cpp](mtp-target/server/src/physics.cpp))
```cpp
// Renamed to avoid std::thread conflict
IThread *physicsThread;
```

### Login Service (`mtp-target/login_service/`)

**1. 64-bit Pointer Casting** ([connection_client.cpp](mtp-target/login_service/connection_client.cpp))
```cpp
// Old: (uint32)from
c.set((uint32)(uintptr_t)from, rand(), uid);
```

**2. TServiceId API** ([connection_ws.cpp](mtp-target/login_service/connection_ws.cpp))
```cpp
// All callbacks updated from uint16 to TServiceId
void cbWSShardChooseShard(CMessage &msgin, const std::string &serviceName, TServiceId sid)
```

---

## Modified Files Summary

### Keep These Files

**Core Services:**
- `login-service-deno/login-only.ts` - Working login service
- `login-service-deno/http-only.ts` - HTTP server
- `login-service-deno/nel-protocol-v2.ts` - NeL protocol implementation
- `login-service-deno/db-setup.ts` - Database setup
- `login-service-deno/mtp_target.db` - Database with test data
- `login-service-deno/deno.json` - Deno tasks configuration

**Server Compilation:**
- `mtp-target/Variables.mk` - Updated library paths
- `mtp-target/server/src/Makefile` - Build configuration
- `mtp-target/server/src/mtp_target_service` - Compiled binary (20 MB)
- `mtp-target/server/src/mtp_target_service.cfg` - Server config
- `mtp-target/common/lua_utility.cpp` - Lua 5.1 migration
- `mtp-target/server/src/command.h` - Modern NeL commands
- `mtp-target/server/src/command.cpp` - Command implementation
- `mtp-target/server/src/welcome.cpp` - Modified for debugging
- `mtp-target/server/src/physics.cpp` - ODE initialization
- `mtp-target/server/src/entity_lua_proxy.cpp` - 64-bit fixes
- `mtp-target/server/src/module_lua_proxy.cpp` - 64-bit fixes
- `mtp-target/server/src/lua_engine.cpp` - 64-bit fixes

**Login Service Compilation:**
- `mtp-target/login_service/Makefile` - Build configuration
- `mtp-target/login_service/login_service` - Compiled binary
- `mtp-target/login_service/connection_client.cpp` - 64-bit fixes
- `mtp-target/login_service/connection_ws.cpp` - TServiceId migration

**Documentation:**
- `CLAUDE.md` - Original project documentation
- `LOGIN_SERVICE_DEBUG.md` - SCS debugging log
- `UBUNTU_SETUP.md` - Build environment setup
- `SERVER_RESTORATION_SUMMARY.md` - This file

### Delete These Files

**Test Scripts (no longer needed):**
- `login-service-deno/test-scs-match.ts`
- `login-service-deno/test-cpp-login.ts`
- `login-service-deno/test-cpp-simple.ts`
- `test-scs-v2.ts`
- `test_scs.cpp`
- `test_scs` (compiled binary)

**Old Versions:**
- `login-service-deno/nel-protocol.ts` (superseded by v2)
- `login-service-deno/main.ts` (superseded by login-only.ts)

**Build Artifacts (can be regenerated):**
- `mtp-target/server/src/*.o` (object files)
- `mtp-target/server/src/Dependencies.mk`
- `mtp-target/server/src/Objects.mk`
- `mtp-target/login_service/*.o` (object files)

**Log Files:**
- `mtp-target/login_service/log.log`
- `mtp-target/login_service/login_service.log`
- `mtp-target/server/src/log.log`
- `mtp-target/server/src/mtp_target_service.log`
- `/tmp/deno_login.log`
- `/tmp/game_server.log`

---

## Dependencies Installed (Ubuntu/WSL)

```bash
# Build tools
sudo apt install -y build-essential cmake git ninja-build

# NeL dependencies
sudo apt install -y libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev

# Database
sudo apt install -y libmysqlclient-dev mysql-server

# Scripting
sudo apt install -y lua5.1 liblua5.1-0-dev libluabind-dev

# Physics
sudo apt install -y libode-dev  # ODE 0.16.2

# Misc
sudo apt install -y libcurl4-openssl-dev
```

**External Libraries Built:**
- RyzomCore NeL: `/mnt/c/Users/User/Playground/mtp_target/ryzomcore/`
  - `libnelmisc.so`, `libnelnet.so`, `libnel3d.so`, etc.

---

## Network Ports

| Service | Port | Protocol | Status |
|---------|------|----------|--------|
| HTTP Server | 80 | HTTP | ✅ Working |
| Login Service | 49997 | TCP (NeL) | ✅ Working |
| Game Server (Easy) | 51574 | TCP (NeL) | ✅ Working |
| Game Server (Expert) | 51575 | TCP (NeL) | Not tested |

---

## Hosts File Configuration

**Windows:** `C:\Windows\System32\drivers\etc\hosts`
```
127.0.0.1 mtp-target.dyndns.org
127.0.0.1 www.mtp-target.org
```

---

## Database Queries (Useful)

```sql
-- Check user
SELECT * FROM user WHERE Login = 'test';

-- Check shards
SELECT * FROM shard;

-- Set shard online
UPDATE shard SET State = 'Online' WHERE ShardId = 100;

-- View all tables
.tables

-- View schema
.schema user
```

---

## Why Compiling Client is the Right Next Step

1. **Source/Binary Match:** Ensure the binary we run matches the source code we have
2. **Debugging Control:** We can add debug prints, modify behavior, etc.
3. **Domain Name Changes:** We can change hardcoded domains from `mtp-target.org` to our own
4. **Protocol Investigation:** We can instrument the client to see exactly what it expects
5. **Future Modifications:** Potentially add offline mode, bypass login, etc.

---

## Migration Plan to New Repository

### Option 1: Fork tux_target and Import Our Work

**Advantages:**
- Latest potential fixes from Ryzom
- Clean commit history
- GitHub Actions ready

**Steps:**
1. Fork https://github.com/ryzom/tux_target
2. Clone your fork locally (Windows)
3. Copy our modifications:
   - All `login-service-deno/` files
   - Modified `mtp-target/` files listed above
   - Documentation files
4. Commit changes with clear messages
5. Test compilation on Windows

### Option 2: Continue with skeetmtp/mtp-target

**Advantages:**
- Already set up and working
- Known state

**Disadvantages:**
- Older codebase
- May be missing fixes

### Recommended: Option 1 (Fork tux_target)

---

## Files to Copy to New Repository

### Essential Login Service
```
login-service-deno/
├── login-only.ts
├── http-only.ts
├── nel-protocol-v2.ts
├── db-setup.ts
├── deno.json
└── README.md (create new)
```

### Server Modifications
```
mtp-target/
├── Variables.mk
├── common/
│   └── lua_utility.cpp
├── server/src/
│   ├── Makefile
│   ├── command.h
│   ├── command.cpp
│   ├── welcome.cpp
│   ├── physics.cpp
│   ├── entity_lua_proxy.cpp
│   ├── module_lua_proxy.cpp
│   └── lua_engine.cpp
└── login_service/
    ├── Makefile
    ├── connection_client.cpp
    └── connection_ws.cpp
```

### Documentation
```
docs/
├── SERVER_RESTORATION_SUMMARY.md (this file)
├── UBUNTU_SETUP.md
└── LOGIN_SERVICE_DEBUG.md
```

---

## Next Steps Checklist

- [ ] Clean up test scripts and build artifacts
- [ ] Create migration script for copying files to new repo
- [ ] Fork tux_target repository
- [ ] Set up Windows build environment
- [ ] Install Visual Studio 2019/2022 with C++ workload
- [ ] Install NeL dependencies on Windows
- [ ] Compile client from source
- [ ] Test connection with our login service
- [ ] Debug SCS message with source-matched binary
- [ ] Set up GitHub Actions for automated builds

---

## Key Lessons Learned

1. **Binary/Source Mismatch is Real:** Never assume the binary matches the source
2. **Protocol Debugging is Hard:** Binary protocols require byte-level precision
3. **Modern Libraries Help:** Using Deno + SQLite was much easier than C++ + MySQL
4. **Documentation Matters:** LOGIN_SERVICE_DEBUG.md was invaluable for tracking tests
5. **Incremental Progress:** We got 95% of the way - just need the matching client

---

## Contact & Resources

**Original Source:**
- https://github.com/skeetmtp/mtp-target (current)
- https://github.com/ryzom/tux_target (recommended next)

**Dependencies:**
- NeL/RyzomCore: https://github.com/ryzom/ryzomcore
- ODE Physics: https://www.ode.org/
- Deno Runtime: https://deno.land/

**Tools Used:**
- Ubuntu/WSL2 for compilation
- Deno v2.6.0 for login service
- Visual Studio Code with Claude Code extension

---

**End of Summary**
Last Updated: December 22, 2025
