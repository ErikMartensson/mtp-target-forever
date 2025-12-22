# MTP Target Server Restoration Project

## Project Goal
Restore the MTP Target game to playable state by setting up a local server that the game client can connect to, bypassing the now-offline official servers at mtp-target.dyndns.org.

## User Requirements
- Be able to play the game again, even if just against self
- Ideally: Set up a server for friends to join
- Theory: Re-implement the PHP backend logic and redirect hardcoded URLs via hosts file

---

## Architecture Overview

MTP Target uses a **three-tier architecture**:

1. **Client** (C++ with NeL framework) - The game executable
2. **Login Service** (C++ service) - Authentication and server list management
3. **Game Server** (C++ service) - Actual gameplay
4. **Web Backend** (PHP + MySQL) - Statistics, user management, content delivery

### Connection Flow
```
Client -> Login Service (port 49997) -> Authenticates against MySQL
       -> Gets list of available game servers
       -> Connects to Game Server (port 51574/51575)
       -> Game Server verifies with Login Service
```

---

## Critical Hardcoded URLs

### In Client Config (`client/mtp_target_default.cfg`)
- **LSHost = "mtp-target.dyndns.org"** - Login service host
- **HTTP Updates**: `http://mtp-target.dyndns.org/mtp-target/export`
- **CRC Checks**: `http://mtp-target.dyndns.org/mtp-target/crc.php`

### In Server Config (`server/mtp_target_service_default.cfg`)
- **LSHost = "mtp-target.dyndns.org"** - Login service host

### In Server List (`server/data/misc/shard_list.xml`)
```xml
<server name="Easy" address="mtp-target.dyndns.org">
  <port>51574</port>
</server>
```

---

## Network Ports

| Service | Port | Purpose |
|---------|------|---------|
| Login Service (Client) | 49997 | Client authentication |
| Login Service (Web) | 49998 | Web API |
| Login Service (Welcome) | 49999 | Game server registration |
| Game Server (Easy) | 51574 | Gameplay |
| Game Server (Expert) | 51575 | Gameplay |
| Chat Server | 4000 | Optional chat bot |

---

## Database Schema

### Database: `nel` (Game Database)

**user table** - Player accounts
- UId (INT, Primary Key, Auto Increment)
- Login (VARCHAR)
- Password (VARCHAR) - Encrypted (Unix crypt on Linux, plaintext on Windows)
- Score (INT) - Total score
- State (ENUM) - Account status
- ShardId (INT) - Current server
- Cookie (VARCHAR) - Session token
- Texture (INT) - Custom skin ID
- Registered (DATETIME) - Registration date
- NbInvitations (INT) - Invitations sent

**shard table** - Game servers
- ShardId (INT, Primary Key)
- Name (VARCHAR)
- NbPlayers (INT)
- State (ENUM)
- InternalId (INT)
- Address (VARCHAR)
- Port (INT)

**session table** - Game sessions
- Id (INT, Primary Key)
- Date (DATETIME)
- Duration (INT)
- LevelName (VARCHAR)
- NbPlayers (INT)

**user_session table** - Player scores per session
- SessionId (INT)
- UId (INT)
- Score (INT)
- Duration (INT)

**map table** - Level information
- Id (INT, Primary Key)
- LevelName (VARCHAR)

**texture table** - Custom player skins
- Id (INT, Primary Key)
- Name (VARCHAR)
- UploadBy (INT) - User ID

**invitation table** - Invitation system
- (Details in mtp-target-web PHP code)

**report table** - Player reports/moderation
- (Details in mtp-target-web PHP code)

### Database: `mtptarge` (Web Database)
- news - News articles
- todo - Development tasks
- game_user - User mirror/cache

---

## PHP Web Backend (mtp-target-web)

**Key Files:**
- `config.default.php` - Database configuration template
- `mysql-func.php` - Database abstraction layer
- `index.php` - Main website
- `stats.php` - Statistics pages (daily, monthly, global)
- `upload_texture.php` - Custom skin uploads
- `crc.php` - Client version verification

**Functions:**
- User authentication and registration
- Leaderboards and statistics
- Texture/skin management
- Server status monitoring
- News system

---

## Dependencies

### Core Framework
- **NeL (Nevrax Engine Library)** - The biggest dependency
  - 3D rendering, networking, services framework
  - Source: http://www.nevrax.org (may be archived)

### Other Libraries
- **ODE 0.5** - Physics engine
- **Lua 5.0** - Scripting
- **FMOD 3.72** - Sound (optional)
- **STLport 4.5** - C++ Standard Library
- **libxml2** - XML parsing
- **freetype** - Font rendering
- **OpenGL 1.2** - Graphics
- **MySQL** - Database

---

## Restoration Strategy - Possible Approaches

### Option 1: Full Server Setup (Most Complex)
**Requirements:**
1. Compile Login Service (C++ with NeL)
2. Compile Game Server (C++ with NeL)
3. Set up MySQL database with proper schema
4. Set up PHP web backend
5. Modify client config to point to localhost
6. Edit hosts file: `127.0.0.1 mtp-target.dyndns.org`

**Pros:**
- Full functionality
- Friends can connect over LAN/VPN

**Cons:**
- Requires compiling old C++ code with NeL framework
- NeL framework may be hard to obtain/compile
- Complex setup

### Option 2: Minimal PHP Backend (Simpler)
**Theory:**
- Client might have offline/LAN mode
- Only need PHP backend for initial login
- Game servers might be optional for single-player

**Requirements:**
1. Set up MySQL with minimal schema
2. Set up PHP web backend
3. Modify client config
4. Edit hosts file

**Pros:**
- No C++ compilation needed
- Simpler setup

**Cons:**
- Unknown if client supports offline play
- May not work without game server

### Option 3: Reverse Engineer Client (Most Flexible)
**Approach:**
- Patch the Windows executable to bypass authentication
- Modify hardcoded URLs in binary
- Enable offline/debug mode

**Pros:**
- No server setup needed
- Can play immediately

**Cons:**
- Requires reverse engineering skills
- May violate game's license (though it's open source)
- No multiplayer

---

## Questions to Investigate

1. Can we find/compile NeL framework?
2. Does the client have any offline/debug modes?
3. What's the minimal setup to get past the login screen?
4. Can we examine the compiled client binary for more clues?
5. Is there existing documentation for setting up a private server?
6. What exactly happens when you try to login now? (Error message?)

---

## Next Steps

### Research Phase (Current)
- [x] Map out codebase structure
- [ ] Find MySQL schema creation scripts
- [ ] Examine compiled client for hardcoded values
- [ ] Test what happens with login attempts
- [ ] Search for NeL framework availability
- [ ] Look for existing private server documentation

### Implementation Phase
- [ ] Set up MySQL database
- [ ] Create database schema
- [ ] Configure PHP backend
- [ ] Compile login service (if possible)
- [ ] Compile game server (if possible)
- [ ] Modify client configuration
- [ ] Test connection flow

---

## Findings Log

### 2025-12-14 - Initial Exploration
- Mapped complete codebase architecture
- Identified all hardcoded server URLs
- Documented network protocol and ports
- Found database schema details in PHP code
- Confirmed PHP backend is complete and present
- Login service and game server source code is available
- Main blocker: NeL framework compilation dependency

### 2025-12-14 - TypeScript Login Service Implementation
**Built Deno-based login service**

Created a TypeScript reimplementation of the login service in `login-service-deno/`:
- `nel-protocol.ts` - NeL binary message protocol implementation
- `main.ts` - TCP server handling VLP and CS messages
- `db-setup.ts` - SQLite database initialization
- Uses Deno v2.6.0 with native SQLite support

**Features:**
- Listens on port 49997 (same as original)
- Auto-creates user accounts on first login
- Handles VLP (Verify Login Password) messages
- Handles CS (Choose Shard) messages
- Returns list of online game servers from database
- Plaintext passwords for Windows compatibility

**Testing Steps:**
1. `cd login-service-deno`
2. `deno run --allow-read --allow-write db-setup.ts` (creates database)
3. `deno run --allow-net --allow-read --allow-write main.ts` (starts login service)
4. `deno run --allow-net http-server.ts` (starts HTTP server as admin)
5. Edit hosts file: `127.0.0.1 mtp-target.dyndns.org` AND `127.0.0.1 www.mtp-target.org`
6. Launch game and try to login

**Debugging discoveries:**
- Game config is at `C:\Program Files (x86)\Mtp Target\client\mtp_target_default.cfg`
- User config overrides at `C:\Users\User\AppData\Roaming\Mtp Target\mtp_target.cfg`
- Installed game uses `LSHost = "www.mtp-target.org"` (NOT `mtp-target.dyndns.org`)
- Game checks HTTP server during startup - added `http-server.ts` to handle this
- Need BOTH servers running: login service (port 49997) AND HTTP server (port 80)

### 2025-12-14 - Login Flow Analysis
**Critical Discovery: How the client actually connects**

1. Client connects to **Login Service** (C++ service) on port **49997**
2. Client sends "VLP" (Verify Login Password) message with login, password, and client version
3. Login Service queries MySQL `nel` database `user` table
4. If `AcceptNewUsers` is true, it auto-creates accounts on first login (no web registration needed!)
5. Login Service checks password (Unix crypt on Linux, plaintext on Windows)
6. Login Service queries `shard` table for servers with `State='Online'`
7. If authentication succeeds and shards exist, returns list of available game servers
8. Client then sends "CS" (Choose Shard) message to select a server
9. Login Service responds with "SCS" containing shard IP address and login cookie
10. Client connects to game server with the cookie

**Error Messages Explained:**
- "Good news, the server is down..." = Can't connect to Login Service on port 49997 OR no online shards
- "The registration failed..." = Client trying to hit the web registration (http://www.mtp-target.org)

**Key Code Locations:**
- Client auth: [login_client.cpp](mtp-target/client/src/login_client.cpp#L122-L200)
- Server auth: [connection_client.cpp](mtp-target/login_service/connection_client.cpp#L166-L287)

**Database Requirements (Minimal):**
```sql
-- User table
CREATE TABLE user (
    UId INT PRIMARY KEY AUTO_INCREMENT,
    Login VARCHAR(64),
    Password VARCHAR(128),  -- Unix crypt hash
    State ENUM('Offline', 'Authorized', 'Online') DEFAULT 'Offline',
    Cookie VARCHAR(256),
    ShardId INT DEFAULT -1,
    Score INT DEFAULT 0,
    Texture INT DEFAULT 0,
    Registered DATETIME,
    NbInvitations INT DEFAULT 0
);

-- Shard table (game servers)
CREATE TABLE shard (
    ShardId INT PRIMARY KEY,
    Name VARCHAR(64),
    NbPlayers INT DEFAULT 0,
    State ENUM('Offline', 'Online') DEFAULT 'Offline',
    InternalId INT,
    Address VARCHAR(128),
    Port INT
);

-- Ban table (optional)
CREATE TABLE ban (
    Ip VARCHAR(64),
    Reason VARCHAR(256),
    Date DATETIME,
    Duration INT
);
```

---

## User Context (2025-12-14)

**User Skillset:**
- Primary language: TypeScript
- Comfortable with: Docker, Deno (v2.6.0), MySQL basics (rusty), editing hosts file
- NOT comfortable with: Compiling C++ on Windows, PHP (old/rusty)
- Prefers: Step-by-step incremental approach

**User Wishes:**
- Use Deno as runtime (has v2.6.0 installed)
- Use Deno's native SQLite instead of MySQL
- Avoid compiling C++ code if possible
- Get the game playable, even if just solo
- Ideally: Set up server for friends to join

**Current Status (2025-12-14 Late Evening):**
- ✅ Game client installed and working
- ✅ Login service (TypeScript/Deno) working perfectly
- ✅ Authentication successful - client receives shard list
- ❌ Client freezes after receiving shard list (waiting for game server)
- ❌ No game server binary found in installed files
- ⏳ **IN PROGRESS:** Compiling game server in Ubuntu/WSL
  - ✅ RyzomCore NeL libraries built successfully
  - ✅ ODE 0.5 physics engine built successfully
  - ⏳ Fixing include path issues for MTP Target compilation

---

### 2025-12-14 - Login Service Success + Client Freeze Investigation

**✅ Login Service Working Perfectly:**
- Deno-based login service successfully authenticates clients
- VLP (Verify Login Password) message handling works
- Shard list correctly returned to client
- Message format verified with hex dumps

**Protocol Details (NeL Binary Format):**
```
Header: 00 00 01 8e 01 (5 bytes)
Then: string length (4 bytes, little-endian) + string data

VLP Response format:
- Header (5 bytes)
- "VLP" message type string
- Empty reason string (0x00 0x00 0x00 0x00 = success)
- Shard count (uint32)
- For each shard:
  - Shard name (string)
  - NbPlayers (uint8)
  - ShardId (uint32)
```

**Example Response (hex):**
```
00 00 01 8e 01          - Header
03 00 00 00 56 4c 50    - "VLP"
00 00 00 00             - Empty reason (success)
01 00 00 00             - 1 shard
11 00 00 00 4c 6f...    - "Local Test Server"
00                      - 0 players
01 00 00 00             - ShardId = 1
```

**❌ Client Freeze Issue:**
- Client receives shard list successfully
- Client **never sends CS (Choose Shard) message**
- Client disconnects/freezes immediately after VLP response
- No crash report generated (only startup GPU warning)
- Theory: Client trying to connect to game server (port 51574) and hangs waiting

**Files Created:**
- `login-service-deno/main.ts` - Login service with VLP/CS handlers
- `login-service-deno/nel-protocol-v2.ts` - NeL binary protocol implementation
- `login-service-deno/db-setup.ts` - SQLite database setup
- `login-service-deno/http-server.ts` - HTTP server for startup checks
- `login-service-deno/mtp_target.db` - SQLite database

**Hosts File Configuration:**
```
127.0.0.1 mtp-target.dyndns.org
127.0.0.1 www.mtp-target.org
```

**Database Setup:**
```bash
cd login-service-deno
deno run --allow-read --allow-write --allow-env --allow-ffi db-setup.ts
deno run --allow-read --allow-write --allow-env --allow-ffi set-shard-online.ts
```

**Starting Services:**
```bash
# Terminal 1 - Login service (port 49997)
cd login-service-deno
deno run --allow-net --allow-read --allow-write --allow-env --allow-ffi main.ts

# Terminal 2 - HTTP server (port 80) - run as Administrator
cd login-service-deno
deno run --allow-net --allow-read http-server.ts
```

**Test Account:**
- Username: `test`
- Password: `test`

---

### 2025-12-14 - Game Server Analysis

**Investigated game server complexity:**

**Server Source:** `mtp-target/server/src/main.cpp` (9,039 lines of C++)

**Critical Components:**
1. **ODE Physics Engine v0.5** - 3D collision detection and rigid body dynamics
   - Sphere-on-sphere collision (players bumping)
   - Module collision (hitting targets for points)
   - Real-time physics simulation at 1ms timesteps
   - Cannot be replicated with JavaScript physics engines (different behavior)

2. **NeL Networking** - Custom binary protocol
   - TCP server on port 51574/51575
   - Sends position updates every 40ms (25 FPS)
   - Delta compression for bandwidth optimization
   - `CBufServer`, `CMessage` serialization

3. **Lua 5.0 Scripting** - Game logic per level
   - 24+ level scripts with scoring rules
   - Collision event handlers
   - Team mode support

4. **Session Management**
   - State machine: WaitingClients → WaitingReady → WaitingStart → Running → Ending
   - Minimum players configuration
   - Timeout handling

**Conclusion: TypeScript Reimplementation NOT FEASIBLE**
- ODE physics cannot be replicated authentically
- 9,000+ lines of tightly coupled C++ code
- Binary protocol requires exact NeL compatibility
- Level scripts depend on exact physics behavior

**MUST compile the C++ server to play the game.**

---

### 2025-12-14 - Ubuntu/WSL Compilation Progress

**Environment Setup:**
- Ubuntu on WSL2
- Working directory: `/mnt/c/Users/User/Playground/mtp_target`

**Dependencies Installed:**
```bash
sudo apt install -y \
    build-essential cmake git \
    libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev libmysqlclient-dev \
    lua5.1 liblua5.1-0-dev \
    libcurl4-openssl-dev libluabind-dev
```
**Note:** Lua 5.0 unavailable in modern Ubuntu, using Lua 5.1 (backward compatible)

**NeL Framework (RyzomCore):**
- Cloned from https://github.com/ryzom/ryzomcore.git (modern NeL successor)
- Built with CMake + Ninja (687 files compiled successfully)
- Libraries installed in `ryzomcore/build/lib/`:
  - libnel3d.so.4.1.0.1062 (7.9 MB)
  - libnelmisc.so.4.1.0.1062 (2.1 MB)
  - libnelnet.so.4.1.0.1062 (1.5 MB)
  - Plus 6 more NeL modules

**ODE 0.5 Physics Engine:**
- Downloaded from SourceForge (2004 release)
- Extracted to `ode-0.5/`
- Built successfully: `ode-0.5/lib/libode.a` (406 KB static library)

**Include Path Issues Fixed:**
- Modern NeL uses `ryzomcore/nel/include/nel/` structure
- Old MTP Target code uses two include styles:
  - `#include <nel/misc/types_nl.h>` (needs parent directory)
  - `#include "3d/mesh.h"` (needs nel subdirectory)
- **Solution:** Modified Makefiles to include BOTH paths:
  - `-I$(NEL_INCLUDE)` = `.../nel/include`
  - `-I$(NEL_INCLUDE)/nel` = `.../nel/include/nel`

**Files Modified:**
- [Variables.mk](mtp-target/Variables.mk) - Updated all library paths for modern build
- [client/src/Makefile](mtp-target/client/src/Makefile) - Added dual NeL include paths
- [server/src/Makefile](mtp-target/server/src/Makefile) - Added dual NeL include paths

**Build Progress:**
- ⏳ Running `make update` to generate dependency files
- Once complete, will compile with `make -C server all`

**Key Challenges Solved:**
1. ✅ Lua package unavailability → Upgraded to Lua 5.1
2. ✅ Missing libcurl → Installed libcurl4-openssl-dev
3. ✅ Missing Luabind → Installed libluabind-dev (pulls in Boost)
4. ✅ CMake sound module errors → Disabled sound support
5. ✅ NL_RELEASE_DEBUG removed → Changed to NL_RELEASE
6. ✅ Include path conflicts → Added dual NeL include paths

---

## Next Steps: Ubuntu/WSL Compilation Strategy

**Why Ubuntu/WSL:**
- Linux compilation usually easier for old C++ projects
- Better package manager support for dependencies
- NeL framework was primarily developed for Linux
- User has Ubuntu available in WSL

**Dependencies to Install (Ubuntu):**
1. **NeL Framework** - Main dependency
2. **ODE 0.5** - Physics engine
3. **Lua 5.0** - Scripting
4. **MySQL client library** - Database (or we can patch to use our SQLite)
5. **Build tools** - gcc, g++, make, cmake
6. **libxml2, freetype** - Supporting libraries

**Compilation Plan:**
1. Find/compile NeL framework first
2. Check if NeL source is in this repository
3. Compile login service (simpler than game server)
4. Compile game server
5. Run server in WSL (accessible from Windows via localhost)

**Files to Transfer to Ubuntu:**
- Entire `mtp-target/` directory (source code)
- SQLite database from `login-service-deno/mtp_target.db`
- This CLAUDE.md file

**Port Forwarding (WSL → Windows):**
- WSL2 automatically forwards localhost ports
- Game client on Windows can connect to `localhost:51574`
- No special configuration needed

---

## Recommended Approach: Hybrid Setup

**Final Architecture:**
1. **Login Service** - Keep Deno version (already working perfectly!)
   - Runs on Windows or WSL
   - Port 49997

2. **HTTP Server** - Keep Deno version
   - Runs on Windows (needs admin for port 80)
   - Port 80

3. **Game Server** - Compile C++ version in Ubuntu/WSL
   - Port 51574
   - Handles actual gameplay with ODE physics

**Advantages:**
- Login service already proven to work
- Only need to compile game server
- Can iterate quickly on login/auth without C++ recompilation
- TypeScript easier to modify for debugging

---

## Quick Reference

**Current Working Services:**
- ✅ Deno Login Service - `login-service-deno/main.ts`
- ✅ Deno HTTP Server - `login-service-deno/http-server.ts`
- ✅ **Game Server - SUCCESSFULLY COMPILED!** - `mtp-target/server/src/mtp_target_service`

**Game Installation Paths:**
- Installed game: `C:\Program Files (x86)\Mtp Target 2\`
- User config: `C:\Users\User\AppData\Roaming\Mtp Target\mtp_target.cfg`
- Game logs: `C:\Users\User\AppData\Local\Temp\Mtp Target\log.log`
- Copied files: `game_install/Mtp Target/`

**Important Config Values:**
- Client version: `708117`
- LSHost in user config: `www.mtp-target.org`
- Game version: `1.5.19`

---

### 2025-12-14 - Game Server Compilation SUCCESS! 🎉

**Status: MTP Target game server successfully compiled and running in Ubuntu/WSL!**

**Compilation Summary:**
- ✅ All 34 source files compiled successfully
- ✅ Binary linked: `mtp-target/server/src/mtp_target_service` (20 MB, 64-bit ELF)
- ✅ Server starts and initializes correctly
- ✅ Physics engine (ODE) working
- ✅ Ready to accept client connections on port 51574

**Major Compatibility Fixes Applied:**

1. **Lua 5.0 → 5.1 API Migration**
   - File: `mtp-target/common/lua_utility.cpp`
   - Changes:
     - `lua_baselibopen()`, `lua_iolibopen()`, etc. → `luaL_openlibs()`
     - `lua_dofile()` → `luaL_dofile()`
     - `lua_setgcthreshold()` → `lua_gc(LUA_GCCOLLECT, 0)`

2. **Modern NeL Command System Compatibility**
   - File: `mtp-target/server/src/command.h`
   - Added missing override for modern NeL ICommand interface:
   ```cpp
   virtual bool execute(const std::string &rawCommandString,
                       const std::vector<std::string> &args,
                       NLMISC::CLog &log, bool quiet, bool human = true)
   ```
   - File: `mtp-target/server/src/command.cpp`
   - Fixed: `Commands` → `ICommand::LocalCommands`
   - Fixed: Added rawCommandString parameter to ICommand::execute() calls

3. **NeL Network Service ID Type Changes**
   - Files: `mtp-target/server/src/welcome.cpp`
   - Changed all callback signatures from `uint16 sid` to `TServiceId sid`
   - Functions affected:
     - `cbLSChooseShard()`
     - `cbLSDisconnectClient()`
     - `cbFailed()`
     - `cbLSConnection()`
   - Fixed printf format: `sid` → `sid.get()`

4. **64-bit Size Type Compatibility**
   - Files affected:
     - `mtp-target/server/src/entity_lua_proxy.cpp` (line 290)
     - `mtp-target/server/src/module_lua_proxy.cpp` (line 169)
     - `mtp-target/server/src/lua_engine.cpp` (lines 477, 493, 549, 566, 587)
   - Changed: `unsigned int len` → `size_t len` for `luaL_checklstring()` calls

5. **Namespace Collision Fix**
   - File: `mtp-target/server/src/physics.cpp`
   - Renamed: `IThread *thread` → `IThread *physicsThread` (conflict with std::thread)

6. **ODE Library Upgrade**
   - Switched from ODE 0.5 (2004) to system ODE 0.16.2 (2024)
   - Installed: `sudo apt install -y libode-dev`
   - Files modified:
     - `mtp-target/server/src/Makefile`:
       - Include path: `-I$(ODE_INCLUDE)` → `-I/usr/include`
       - Library path: `-L$(ODE_LIB)` removed (using system path)
       - Removed `-L$(OPCODE_LIB)` and `-lstlport_gcc`
       - Changed `-llua -llualib` → `-llua5.1`
     - `mtp-target/server/src/physics.cpp`:
       - Added `dInitODE()` call in `initPhysics()` (required for modern ODE)
       - Cleanup already had `dCloseODE()` call

**Dependencies Installed:**
```bash
# System packages
sudo apt install -y \
    build-essential cmake git ninja-build \
    libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev libmysqlclient-dev \
    lua5.1 liblua5.1-0-dev \
    libcurl4-openssl-dev libluabind-dev \
    libode-dev  # ODE 0.16.2 with OPCODE/trimesh support
```

**Libraries Built:**
1. **RyzomCore NeL (Modern NeL Framework)**
   - Location: `/mnt/c/Users/User/Playground/mtp_target/ryzomcore/`
   - Built with: `cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DWITH_SOUND=OFF`
   - Libraries (in `ryzomcore/build/lib/`):
     - `libnel3d.so.4.1.0.1062` (7.9 MB)
     - `libnelmisc.so.4.1.0.1062` (2.1 MB)
     - `libnelnet.so.4.1.0.1062` (1.5 MB)

2. **ODE Physics Engine**
   - Using system package: `/usr/lib/x86_64-linux-gnu/libode.so.8.0.2`
   - Includes OPCODE trimesh collision support
   - Required for module (level geometry) collision

**Build Commands:**

```bash
# Full rebuild from scratch
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target

# Generate dependency files (first time only)
make -C server update

# Build the server
make -C server all

# Result: mtp-target/server/src/mtp_target_service
```

**Running the Server:**

```bash
cd /mnt/c/Users/User/Playground/mtp_target/mtp-target/server/src

# Set NeL library path and run
LD_LIBRARY_PATH=/mnt/c/Users/User/Playground/mtp_target/ryzomcore/build/lib:$LD_LIBRARY_PATH \
./mtp_target_service
```

**Server Output (Success!):**
```
INF: SERVICE: Starting Service 'MTS' using NeL (Dec 14 2025 13:06:11)
INF: set gravity : off
INF: Running server in LAN mode
INF: SERVICE: Service ready
INF: Adding bot eid 0 name 'alice'
INF: Adding bot eid 1 name 'starfox'
INF: Adding bot eid 2 name 'chikant'
INF: Adding bot eid 3 name 'bill'
INF: Adding bot eid 4 name 'ringo'
```

**Configuration Files:**
- Config: `mtp-target/server/src/mtp_target_service.cfg` (copied from `mtp-target/server/mtp_target_service_default.cfg`)
- Data directory: Server expects `data/` directory relative to working directory
  - Currently looking in: `mtp-target/server/src/data/` (WARNING shown)
  - Actual location: `mtp-target/server/data/`
  - **TODO:** Create symlink or adjust working directory

**Network Configuration:**
- Game server listens on port: **51574** (Easy mode)
- Alternative port: **51575** (Expert mode)
- Login service connection: Not configured (LAN mode)
- Client connections: Ready to accept

**Modified Files List:**
```
mtp-target/Variables.mk              - Updated library paths for RyzomCore
mtp-target/server/src/Makefile       - Updated to use system ODE, Lua 5.1
mtp-target/server/src/command.h      - Added modern NeL ICommand override
mtp-target/server/src/command.cpp    - Fixed Commands → LocalCommands
mtp-target/server/src/welcome.cpp    - TServiceId type migration
mtp-target/server/src/physics.cpp    - Added dInitODE(), renamed thread var
mtp-target/server/src/entity_lua_proxy.cpp    - size_t fix
mtp-target/server/src/module_lua_proxy.cpp    - size_t fix
mtp-target/server/src/lua_engine.cpp          - size_t fixes (5 instances)
mtp-target/common/lua_utility.cpp             - Lua 5.1 API migration
```

**Known Issues / Warnings:**
1. ⚠️ Data directory not found: Server looks for `data/` in current dir
   - Fix: Create symlink or run from `mtp-target/server/` directory
2. ⚠️ user_texture directory not found: `../user_texture`
   - Not critical for basic gameplay
3. ℹ️ fgets failed warning: stdin monitoring (non-critical)
4. ℹ️ Format warnings: time_t printf formats (warnings only, not errors)

---

### 2025-12-14 - Login Protocol Debugging

**Issue:** Client freezes or crashes during login process.

**Findings:**
1. **Header Format:** The client expects a **4-byte Big-Endian Length** header, followed by a **1-byte Format** field.
   - Fixed in `nel-protocol-v2.ts`.
   - This resolved the initial freeze (where client waited for more data).

2. **String Encoding:**
   - **Shard Name:** MUST be **Wide String** (UTF-16LE). If sent as ASCII, client crashes with `Stream Overflow` (expects more bytes).
   - **Cookie:** MUST be **ASCII**. If sent as Wide String, client reads ASCII length, then reads garbage length from the rest of the string, causing `Stream Overflow` (huge allocation).
   - **Address:** MUST be **ASCII**. If sent as Wide String, client crashes (Runtime Error).

3. **Current Status:**
   - Login works: Client receives shard list and displays "Test" server.
   - Shard Selection: Client sends "CS" message. Server replies with "SCS".
   - **Crash:** Client crashes with "Runtime Error" immediately after receiving SCS response.

**Hypothesis for Crash:**
- The `Address` format might be wrong (tried "127.0.0.1", "127.0.0.1:51574", "localhost:51574").
- The `Cookie` format might be wrong (tried random string, tried `XXXXXXXX|YYYYYYYY|ZZZZZZZZ` format).
- The client might be failing to connect to the Game Server address provided.

**Next Steps:**
- Verify the exact format of `Address` expected by the client.
- Verify if `Cookie` needs to be valid for the Game Server (Game Server log shows no connection attempts, so client crashes *before* connecting).
- Try **ASCII Cookie (Correct Format) + ASCII Address**.
