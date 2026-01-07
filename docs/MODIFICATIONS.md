# Source Code Modifications

This document details all changes made to the MTP Target source code for compatibility with modern systems (Ubuntu 22.04+, 64-bit, current libraries).

**Last Updated:** January 2, 2026
**Status:** All modifications applied and tested

---

## Overview

The original MTP Target code was written in 2003-2004 for:
- Lua 5.0 (now obsolete)
- ODE 0.5 physics engine (2004 release)
- 32-bit systems
- Older NeL framework API

These modifications enable compilation on modern systems without changing game functionality.

---

## Modified Files Summary

| File | Lines Changed | Purpose |
|------|---------------|---------|
| [common/lua_utility.cpp](#1-lua-50--51-migration) | ~10 | Lua 5.1 API |
| [server/src/command.h](#2-modern-nel-command-interface) | +6 | NeL ICommand |
| [server/src/command.cpp](#2-modern-nel-command-interface) | ~3 | NeL ICommand |
| [server/src/physics.cpp](#3-ode-physics-initialization) | ~8 | ODE init, namespace |
| [server/src/welcome.cpp](#4-tserviceid-type-migration) | +46 | TServiceId, debug |
| [server/src/entity_lua_proxy.cpp](#5-64-bit-compatibility-fixes) | 1 | size_t |
| [server/src/module_lua_proxy.cpp](#5-64-bit-compatibility-fixes) | 1 | size_t |
| [server/src/lua_engine.cpp](#5-64-bit-compatibility-fixes) | 5 | size_t |
| [login_service/connection_client.cpp](#6-login-service-64-bit-fixes) | ~4 | uintptr_t, debug |
| [login_service/connection_ws.cpp](#6-login-service-64-bit-fixes) | 1 | uintptr_t |
| [common/lua_utility.cpp](#7-lua-error-logging-enhancement) | 8 | Error messages |
| [14 Lua server scripts](#8-lua-5x-table-declarations) | 1-3 each | Lua 5.x compat |
| [client/src/options_menu.h](#10-pause-menu-and-options-refactoring) | NEW | Options menu class |
| [client/src/options_menu.cpp](#10-pause-menu-and-options-refactoring) | NEW | Options menu impl |
| [client/src/game_task.h](#10-pause-menu-and-options-refactoring) | ~30 | Pause menu |
| [client/src/game_task.cpp](#10-pause-menu-and-options-refactoring) | ~80 | Pause menu impl |
| [client/src/intro_task.h](#10-pause-menu-and-options-refactoring) | ~25 | Options callback |
| [client/src/intro_task.cpp](#10-pause-menu-and-options-refactoring) | ~150 | Options refactor |
| [client/src/mtp_target.cpp](#11-disconnectreconnect-flow-fix) | ~20 | Disconnect fix |
| [client/src/entity_manager.h](#11-disconnectreconnect-flow-fix) | +1 | removeAll decl |
| [client/src/entity_manager.cpp](#11-disconnectreconnect-flow-fix) | +15 | removeAll impl |

**Total:** 35+ files, ~250+ lines changed

---

## 1. Lua 5.0 → 5.1 Migration

**File:** [common/lua_utility.cpp](../common/lua_utility.cpp)

### Problem
Lua 5.0 is no longer available in modern Linux distributions. Lua 5.1 is the oldest supported version.

### Changes

#### Library Initialization (lines 136-137)
**Before:**
```cpp
lua_baselibopen(L);
lua_iolibopen(L);
lua_strlibopen(L);
lua_mathlibopen(L);
lua_dblibopen(L);
lua_tablibopen(L);
```

**After:**
```cpp
// Lua 5.1 equivalent of opening all standard libraries
luaL_openlibs(L);
```

#### Script Loading (line 189)
**Before:**
```cpp
int res = lua_dofile(L, fn.c_str());
if(res > 0)
{
    nlwarning("LUA: lua_dofile(\"%s\") failed with code %d", filename.c_str(), res);
```

**After:**
```cpp
int res = luaL_dofile(L, fn.c_str());
if(res > 0)
{
    nlwarning("LUA: luaL_dofile(\"%s\") failed with code %d", filename.c_str(), res);
```

#### Garbage Collection (line 206)
**Before:**
```cpp
lua_setgcthreshold(L, 0);  // collected garbage
```

**After:**
```cpp
lua_gc(L, LUA_GCCOLLECT, 0);  // collect garbage (Lua 5.1 API)
```

### Why This Matters
Lua 5.0 functions were removed in Lua 5.1. Without these changes, compilation fails with "undefined reference" errors.

---

## 2. Modern NeL Command Interface

**Files:**
- [server/src/command.h](../server/src/command.h)
- [server/src/command.cpp](../server/src/command.cpp)

### Problem
Modern NeL (RyzomCore) changed the `ICommand::execute()` signature to include the raw command string as the first parameter.

### Changes

#### command.h (lines 67-71)
**Added:**
```cpp
// Override for modern NeL ICommand interface
virtual bool execute(const std::string &rawCommandString,
                    const std::vector<std::string> &args,
                    NLMISC::CLog &log, bool quiet, bool human = true)
{
    return execute(args, log, quiet, human);
}
```

#### command.cpp (line 217)
**Before:**
```cpp
if (!icom->execute(commands[u].second, log, quiet, human))
```

**After:**
```cpp
// Modern NeL ICommand::execute requires rawCommandString as first parameter
if (!icom->execute(commands[u].first, commands[u].second, log, quiet, human))
```

### Why This Matters
Without the new signature, compilation fails with "cannot convert" errors. The override adapts the old API to the new one.

---

## 3. ODE Physics Initialization

**File:** [server/src/physics.cpp](../server/src/physics.cpp)

### Problem 1: Modern ODE Requires Explicit Initialization
ODE 0.16+ requires calling `dInitODE()` before using any ODE functions.

**Change (line 544):**
```cpp
void initPhysics()
{
    // Initialize ODE library (required for modern ODE 0.16+)
    dInitODE();  // ← Added this line

    World = dWorldCreate();
    // ... rest of function
}
```

### Problem 2: Namespace Collision
Global variable `thread` conflicts with `std::thread` in modern C++.

**Change (lines 65, 583-586):**

**Before:**
```cpp
IThread *thread = 0;

void releasePhysics()
{
    if(thread)
    {
        thread->terminate();
        delete thread;
```

**After:**
```cpp
IThread *physicsThread = 0;

void releasePhysics()
{
    if(physicsThread)
    {
        physicsThread->terminate();
        delete physicsThread;
```

### Why This Matters
- Without `dInitODE()`: Crash on startup with "ODE not initialized"
- Without namespace fix: Compilation errors in files that include `<thread>`

---

## 4. TServiceId Type Migration

**File:** [server/src/welcome.cpp](../server/src/welcome.cpp)

### Problem
Modern NeL uses `TServiceId` class instead of `uint16` for service identifiers.

### Changes

All callback function signatures updated:

**Before:**
```cpp
void cbLSChooseShard(CMessage &msgin, const std::string &serviceName, uint16 sid)
void cbFailed(CMessage &msgin, const std::string &serviceName, uint16 sid)
void cbLSDisconnectClient(CMessage &msgin, const std::string &serviceName, uint16 sid)
void cbLSConnection(const std::string &serviceName, uint16 sid, void *arg)
```

**After:**
```cpp
void cbLSChooseShard(CMessage &msgin, const std::string &serviceName, TServiceId sid)
void cbFailed(CMessage &msgin, const std::string &serviceName, TServiceId sid)
void cbLSDisconnectClient(CMessage &msgin, const std::string &serviceName, TServiceId sid)
void cbLSConnection(const std::string &serviceName, TServiceId sid, void *arg)
```

**Printf fix (line 256):**
```cpp
// Old: nlinfo("Connected to %s-%hu ...", serviceName.c_str(), sid, shardId);
nlinfo("Connected to %s-%hu ...", serviceName.c_str(), sid.get(), shardId);
```

### Debug Logging (Optional)
Added hex dump logging for SCS messages to aid in protocol debugging (lines 174-191, 298-323). This is optional and can be removed if not needed.

### Why This Matters
Without these changes, compilation fails with type mismatch errors.

---

## 5. 64-bit Compatibility Fixes

**Files:**
- [server/src/entity_lua_proxy.cpp](../server/src/entity_lua_proxy.cpp)
- [server/src/module_lua_proxy.cpp](../server/src/module_lua_proxy.cpp)
- [server/src/lua_engine.cpp](../server/src/lua_engine.cpp)

### Problem
`luaL_checklstring()` requires `size_t*` parameter, not `unsigned int*`. On 64-bit systems, these types have different sizes.

### Changes

**entity_lua_proxy.cpp (line 291):**
```cpp
// Before: unsigned int len;
size_t len;
const char *text = luaL_checklstring(luaSession, 7, &len);
```

**module_lua_proxy.cpp (line 170):**
```cpp
// Before: unsigned int name_len;
size_t name_len;
const char *name = luaL_checklstring(luaSession, 1, &name_len);
```

**lua_engine.cpp (lines 478, 494, 550, 567, 588):**
```cpp
// Before: unsigned int len;
size_t len;
const char *text = luaL_checklstring(L, index, &len);
```

### Why This Matters
On 64-bit systems, passing `unsigned int*` instead of `size_t*` causes:
- Stack corruption
- Potential crashes
- Compiler warnings (-Wconversion)

---

## 6. Login Service 64-bit Fixes

**Files:**
- [login_service/connection_client.cpp](../login_service/connection_client.cpp)
- [login_service/connection_ws.cpp](../login_service/connection_ws.cpp)

### Problem
Casting pointers to `uint32` directly causes truncation on 64-bit systems.

### Changes

#### connection_client.cpp

**Cookie creation (line 263):**
```cpp
// Before: c.set((uint32)from, rand(), uid);
c.set((uint32)(uintptr_t)from, rand(), uid);
```

**Cookie validation (lines 332, 452):**
```cpp
// Before: if(lc.getUserAddr() == (uint32)from)
if(lc.getUserAddr() == (uint32)(uintptr_t)from)
```

#### connection_ws.cpp (line 367)

**Socket ID cast:**
```cpp
// Before: sendToClient(msgout, (TSockId)lc.getUserAddr());
sendToClient(msgout, reinterpret_cast<TSockId>((uintptr_t)lc.getUserAddr()));
```

#### Debug Logging (Optional)
Added message hex dump in `sendToClient()` (lines 79-91) for protocol debugging.

### Why This Matters
- `uintptr_t` is guaranteed to hold a pointer value
- Direct `pointer → uint32` cast truncates on 64-bit systems
- Causes authentication failures and session mismatches

---

## Build System Changes

These changes are in Makefiles/build configuration, not C++ source:

### Variables.mk
- Updated library paths to point to RyzomCore build directory
- Changed Lua from 5.0 to 5.1 paths
- Updated to use system ODE instead of custom build

### server/src/Makefile
- Added `-I$(NEL_INCLUDE)/nel` for dual include path support
- Changed `-llua -llualib` to `-llua5.1`
- Removed `-lstlport_gcc` (no longer needed)
- Changed ODE library path to system location

### login_service/Makefile
- Similar NeL and Lua path updates
- Removed STLport dependency

---

## Testing Checklist

After applying modifications, verify:

- [ ] Server compiles without errors
- [ ] Server starts and initializes physics
- [ ] Server loads Lua scripts successfully
- [ ] Login service compiles (C++ version)
- [ ] Login service handles VLP messages
- [ ] No segfaults or crashes on 64-bit systems
- [ ] ODE physics works correctly
- [ ] Commands execute properly

---

## Compatibility Notes

### What Still Works
- ✅ Original game client (Windows binary)
- ✅ All game levels and Lua scripts
- ✅ Network protocol (NeL binary format)
- ✅ Database schema (MySQL/SQLite)
- ✅ Physics behavior (ODE)

### What Changed
- ❌ Cannot build with original NeL 0.5 (use RyzomCore)
- ❌ Cannot use Lua 5.0 (requires 5.1+)
- ❌ Cannot build on 32-bit without reversing some changes

---

## Reverting Changes

If you need to compile on the original system (2004 Linux, 32-bit):

1. Use original NeL 0.5 framework
2. Install Lua 5.0
3. Use ODE 0.5
4. Revert all changes in this document

However, this is not recommended as those dependencies are no longer available in modern distributions.

---

## 7. Lua Error Logging Enhancement

**File:** [common/lua_utility.cpp](../common/lua_utility.cpp)

### Problem
When Lua scripts failed to load, the server only showed generic error codes without the actual error message. This made debugging Lua issues very difficult.

### Changes

#### Error Message Extraction (lines 184-192)
**Before:**
```cpp
int res = luaL_dofile(L, fn.c_str());
if(res > 0)
{
    nlwarning("LUA: luaL_dofile(\"%s\") failed with code %d", filename.c_str(), res);
    luaClose(L);
    return false;
}
```

**After:**
```cpp
int res = luaL_dofile(L, fn.c_str());
if(res > 0)
{
    const char *msg = lua_tostring(L, -1);
    if (msg == NULL) msg = "(error with no message)";
    nlwarning("LUA: luaL_dofile(\"%s\") failed with code %d: %s", filename.c_str(), res, msg);
    luaClose(L);
    return false;
}
```

### Why This Matters
This change extracts the actual Lua error message from the stack, making it immediately clear what went wrong. For example, instead of "failed with code 1", we now get "failed with code 1: attempt to index a nil value (global 'CEntity')".

This improvement was critical for diagnosing the Lua 5.x compatibility issues.

---

## 8. Lua 5.x Table Declarations

**Files:** 14 Lua server scripts in [mtp-target-src/data/lua/](../mtp-target-src/data/lua/)

### Problem
Lua 5.0 auto-created tables when methods were defined on them. For example, `function CEntity:init()` would automatically create the `CEntity` table.

Lua 5.x changed this behavior - tables must exist before methods can be defined on them. The server crashed with "attempt to index a nil value (global 'CEntity')" errors.

### Changes

Added table declarations at the top of each affected Lua server script:

```lua
CEntity = CEntity or {}  -- Creates table if it doesn't exist
CModule = CModule or {}  -- Only in files that use CModule
CLevel = CLevel or {}    -- Only in files that use CLevel
```

### Files Modified
- level_bowls1_server.lua (added CEntity)
- level_city_paint_server.lua (added CEntity, CModule, CLevel)
- level_darts_server.lua (added CEntity)
- level_default_server.lua (added CEntity)
- level_extra_ball_server.lua (added CEntity)
- level_gates_server.lua (added CEntity)
- level_paint_server.lua (added CEntity, CModule, CLevel)
- level_stairs_server.lua (added CEntity)
- level_sun_extra_ball_server.lua (added CEntity)
- level_team_server.lua (added CEntity, CModule)
- And 4 more with similar patterns

### Why This Matters
Without these declarations, the server crashed during level transitions when loading Lua server scripts. This fix enables stable gameplay through all 71 levels without crashes.

**Note:** These are Lua runtime files, not C++ source code, but they're essential for the game to function with Lua 5.x.

---

## 9. ODE Trimesh Edge Collision Fix (Momentum Loss)

**File:** [server/src/physics.cpp](../server/src/physics.cpp)

### Problem
Players would lose momentum at slope-to-ramp transitions. Debug logging revealed that at triangle mesh edges, ODE's collision response was absorbing up to 50% of velocity without any code explicitly zeroing it.

### Root Cause
ODE's `dContactMu2` mode with infinite friction treats edge contacts as head-on collisions. When a sphere crosses from one triangle to another at a mesh edge, ODE can generate contact normals pointing into the velocity direction, causing momentum absorption.

### Changes

#### Contact Surface Mode (lines 243-257)
**Before:**
```cpp
if(module->bounce())
{
    contact[i].surface.mode = dContactBounce;
    contact[i].surface.mu = dInfinity;
    contact[i].surface.mu2 = 0;
    // ...
}
else
{
    contact[i].surface.mode = dContactMu2;
    contact[i].surface.mu = dInfinity;
    contact[i].surface.mu2 = dInfinity;
}
```

**After:**
```cpp
if(module->bounce())
{
    // Use dContactApprox1 to prevent momentum loss at trimesh edges
    contact[i].surface.mode = dContactBounce | dContactApprox1;
    contact[i].surface.mu = dInfinity;
    contact[i].surface.mu2 = 0;
    // ...
}
else
{
    // Use dContactApprox1 to prevent momentum loss at trimesh edges
    // This uses friction pyramid approximation which preserves tangential velocity
    contact[i].surface.mode = dContactApprox1;
    contact[i].surface.mu = dInfinity;
    contact[i].surface.mu2 = 0;
}
```

### Why This Matters
- `dContactApprox1` uses a friction pyramid approximation instead of explicit friction forces
- This mode is more forgiving at triangle edges where normals can be ambiguous
- Preserves tangential velocity (sliding motion) while still allowing normal collision response

### Debug Logging (Optional)
Added `PhysicsDebugLog` flag and `[COLLISION]`, `[VEL-ZERO]`, `[VELOCITY]` logging for future physics debugging. Disabled by default.

---

## 10. Pause Menu and Options Refactoring

**Files:**
- [client/src/options_menu.h](../client/src/options_menu.h) (NEW)
- [client/src/options_menu.cpp](../client/src/options_menu.cpp) (NEW)
- [client/src/game_task.h](../client/src/game_task.h)
- [client/src/game_task.cpp](../client/src/game_task.cpp)
- [client/src/intro_task.h](../client/src/intro_task.h)
- [client/src/intro_task.cpp](../client/src/intro_task.cpp)
- [client/data/gui/pause_menu.xml](../client/data/gui/pause_menu.xml) (NEW)

### Problem
The original game had no pause menu - pressing ESC immediately quit to desktop. Options were only accessible from the main menu. Additionally, options menu code was duplicated between intro_task and game_task after adding pause menu options.

### Changes

#### New COptionsMenu Class
Created a shared `COptionsMenu` singleton class with callback interface:
```cpp
class IOptionsMenuCallback
{
public:
    virtual void onOptionsBack() = 0;
    virtual void onOptionsApply() = 0;
};

class COptionsMenu : public NLMISC::CSingleton<COptionsMenu>
{
public:
    void load();
    void show(IOptionsMenuCallback *callback);
    void hide();
    bool isActive() const;
    bool update();
    // ...
};
```

#### Pause Menu (game_task.cpp)
Added pause menu accessible via ESC key during gameplay:
- Resume - return to game
- Options - access video/audio settings
- Disconnect - clean disconnect and return to main menu
- Quit Game - exit application

#### Callback Behavior
- `CIntroTask::onOptionsApply()` - Restarts game to apply video settings (safe in main menu)
- `CGameTask::onOptionsApply()` - Only saves settings, no restart (would disconnect player)

### Why This Matters
- Players can now pause the game and adjust settings mid-session
- Volume can be changed without disconnecting from server
- Clean disconnect flow prevents crashes when reconnecting
- Code deduplication reduces maintenance burden (~350 lines removed)

---

## 11. Disconnect/Reconnect Flow Fix

**File:** [client/src/mtp_target.cpp](../client/src/mtp_target.cpp)

### Problem
Disconnecting from a server and reconnecting would crash the client due to:
1. Task manager assertion failures (tasks already registered)
2. Entity manager assertion failures (entities still existed)
3. Error flag not being reset (level wouldn't load)

### Changes

#### Task Cleanup (_error() function)
```cpp
void CMtpTarget::_error()
{
    nlinfo("error occurred : stop all and reset");
    reset();
    // Clear all entities so they can be re-added when reconnecting
    CEntityManager::getInstance().removeAll();
    // Immediately remove CGameTask and its child tasks
    CTaskManager::getInstance().remove(CLevelManager::instance());
    CTaskManager::getInstance().remove(CHudTask::instance());
    CTaskManager::getInstance().remove(CScoreTask::instance());
    CTaskManager::getInstance().remove(CChatTask::instance());
    CTaskManager::getInstance().remove(CGameTask::instance());
    // ... rest of cleanup
    DoError = false;
    Error = false;  // Reset error flag so reconnection can work
}
```

#### Entity Manager (entity_manager.cpp)
Added `removeAll()` method:
```cpp
void CEntityManager::removeAll()
{
    CMtpTarget::getInstance().controler().Camera.setFollowedEntity(255);
    for(uint i = 0; i < 255; i++)
    {
        if(entities()[i]->Type != CEntity::Unknown)
            entities()[i]->reset();
    }
}
```

### Why This Matters
- Players can now disconnect and reconnect without restarting the game
- Server errors display properly and can be dismissed
- Clean state transitions prevent memory leaks and crashes

---

## Future Modifications

Potential future changes:

- **Modern C++:** Update to C++11/14/17 features where beneficial
- **Domain Changes:** Replace hardcoded mtp-target.org references (if hosting publicly)
- **Scoring System:** Fix broken scoring logic (critical priority)
- **Water Rendering:** Fix WaterPoolManager initialization or find correct textures

---

## Questions?

If you encounter issues after applying these modifications:

1. Check that you have the correct library versions installed
2. Verify your compiler is GCC 7+ (Linux) or Visual Studio 2022 (Windows)
3. Review the [BUILDING.md](BUILDING.md) guide
4. Check for additional system-specific requirements
5. For Lua errors, check that table declarations are present in level scripts

For protocol debugging and network issues, see [PROTOCOL_NOTES.md](PROTOCOL_NOTES.md).

For runtime crashes and configuration issues, see [RUNTIME_FIXES.md](RUNTIME_FIXES.md).
