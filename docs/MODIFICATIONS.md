# Source Code Modifications

This document details all changes made to the MTP Target source code for compatibility with modern systems (Ubuntu 22.04+, 64-bit, current libraries).

**Last Updated:** February 5, 2026
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

| [client/src/level.cpp](#12-v1519-level-compatibility-bridge) | ~40 | CLevel:init(), textures |
| [client/src/module.cpp](#12-v1519-level-compatibility-bridge) | ~10 | Texture application |
| [client/src/module_lua_proxy.cpp](#12-v1519-level-compatibility-bridge) | ~15 | setTexture method |
| [common/lua_nel.h](#12-v1519-level-compatibility-bridge) | +6 | CLuaVector methods |
| [common/lua_nel.cpp](#12-v1519-level-compatibility-bridge) | ~30 | CLuaVector implementations |
| [server/src/level.cpp](#12-v1519-level-compatibility-bridge) | ~15 | CLevel:init() call |
| [server/src/level.cpp](#13-engine-level-scoring-fixes) | +5 | Default friction for scoring modules |
| [server/src/main.cpp](#13-engine-level-scoring-fixes) | ~5 | Main loop reorder for postUpdate scoring |
| [server/src/entity_lua_proxy.cpp](#14-negative-score-support) | 1 | uint32 → sint32 cast for negative scores |
| [client/src/controler.cpp](#15-v1519-feature-ports) | ~80 | Music, replay, external camera controls |
| [client/src/time_task.h](#15-v1519-feature-ports) | +10 | Time speed control methods |
| [client/src/time_task.cpp](#15-v1519-feature-ports) | ~15 | Time speed implementation |
| [client/src/external_camera_task.h](#15-v1519-feature-ports) | NEW | External camera task header |
| [client/src/external_camera_task.cpp](#15-v1519-feature-ports) | NEW | External camera task implementation |
| [client/src/mtp_target.cpp](#15-v1519-feature-ports) | ~5 | External camera task registration |
| [client/src/sky_task.h](#15-v1519-feature-ports) | +1 | skyScene() accessor for PIP |
| [client/src/entity.h](#15-v1519-feature-ports) | +1 | fontScale param for renderName() |
| [client/src/entity.cpp](#15-v1519-feature-ports) | ~3 | Font scaling in renderName() |
| [client/src/text_editor.h](#17-modern-text-input) | NEW | Shared text editing class |
| [client/src/text_editor.cpp](#17-modern-text-input) | NEW | Text editing state machine |
| [client/src/gui_text.h](#17-modern-text-input) | +3 | CTextEditor member |
| [client/src/gui_text.cpp](#17-modern-text-input) | ~40 | CTextEditor integration, selection rendering |
| [client/src/chat_task.h](#17-modern-text-input) | +2 | CTextEditor member |
| [client/src/chat_task.cpp](#17-modern-text-input) | ~60 | CTextEditor integration, cursor/selection rendering |
| [client/src/font_manager.h](#17-modern-text-input) | +1 | littleStringWidth() declaration |
| [client/src/font_manager.cpp](#17-modern-text-input) | +5 | littleStringWidth() implementation |

**Total:** 64+ files, ~660+ lines changed

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

## 12. v1.5.19 Level Compatibility Bridge

**Files:**
- [client/src/level.cpp](../client/src/level.cpp)
- [server/src/level.cpp](../server/src/level.cpp)
- [client/src/module.cpp](../client/src/module.cpp)
- [client/src/module_lua_proxy.cpp](../client/src/module_lua_proxy.cpp)
- [common/lua_nel.h](../common/lua_nel.h)
- [common/lua_nel.cpp](../common/lua_nel.cpp)
- [common/lua_utility.cpp](../common/lua_utility.cpp)

### Problem
v1.5.19 levels use a fundamentally different architecture - imperative `CLevel:init()` calls instead of static global tables. All 28 new levels (space, sun, city, gates) use this pattern and couldn't load without C++ bridge code.

### Changes

#### CLevel:init() Call (client + server level.cpp)
After `luaOpenAndLoad(filename)`, added code to check for and call `CLevel:init()`:
```cpp
lua_getglobal(LuaState, "CLevel");
if (!lua_isnil(LuaState, -1)) {
    lua_getfield(LuaState, -1, "init");
    if (lua_isfunction(LuaState, -1)) {
        lua_pushvalue(LuaState, -2);
        lua_pcall(LuaState, 1, 0, 0);
    } else { lua_pop(LuaState, 1); }
}
lua_pop(LuaState, 1);
```

#### Module Texture Support (client level.cpp + module.cpp)
Extended the Modules table reader to check for `Texture0`/`Texture1` fields and apply them to loaded shapes via `UInstance::getMaterial()`.

#### Module Proxy setTexture (client module_lua_proxy.cpp)
Added `setTexture(layer, textureName)` method to CModuleProxy for runtime texture changes via `execLuaOnAllClient`.

#### CLuaVector Methods (common lua_nel.h/cpp)
Added `getX`/`getY`/`getZ`/`setX`/`setY`/`setZ` methods to CLuaVector. v1.5.19 scripts call `pos:getX()` etc. which the original CLuaVector didn't support.

#### include() and nlinfo/nlwarning (common lua_utility.cpp)
- Added `include()` C function using `CPath::lookup` for loading scripts from any registered data directory
- Registered `nlinfo` and `nlwarning` as Lua functions for v1.5.19 server scripts

#### moduleById Alias (client level.cpp)
Registered `moduleById` as alias for `getModuleById` for v1.5.19 `execLuaOnAllClient` compatibility.

### Why This Matters
Without these changes, none of the 28 v1.5.19-style levels could load. The bridge enables both architectures to coexist - original v1.2.2a levels work unchanged while new levels execute their `CLevel:init()` to populate the same global tables.

---

## 13. Engine-Level Scoring Fixes

**Files:**
- [server/src/level.cpp](../server/src/level.cpp)
- [server/src/main.cpp](../server/src/main.cpp)

### Problem
Two engine-level issues prevented scoring on v1.5.19 levels:

1. **No friction on scoring targets:** City and space theme targets have Score > 0 but don't set Friction. The v1.5.19 server presumably applied friction automatically; without it, balls roll across targets without slowing down.

2. **Main loop timing bug:** Levels like `city_paint` use per-frame score recalculation: `CEntity:preUpdate()` resets CurrentScore to 0, then `CLevel:postUpdate()` recalculates it. But `CSessionManager::update()` ran between these two steps, reading CurrentScore=0 when checking arrival times and end conditions. Scores were never recognized.

### Changes

#### Default Friction for Scoring Modules (server/src/level.cpp)
After reading module properties from Lua, apply default friction if Score > 0 and Friction == 0:
```cpp
if (ModuleScore > 0 && ModuleFriction == 0)
{
    ModuleFriction = 10;
    nlinfo("Module %d: applying default friction %f (score=%d)", moduleId, ModuleFriction, ModuleScore);
}
```

#### Main Loop Reordering (server/src/main.cpp)
Moved `CSessionManager::update()` to run after `levelPostUpdate()`:
```cpp
// Before (broken):
CEntityManager::getInstance().update();    // preUpdate → score=0
CSessionManager::getInstance().update();   // reads score=0!
CLevelManager::getInstance().update();
CLuaEngine::getInstance().levelPostUpdate(); // postUpdate → score=correct (too late)

// After (fixed):
CEntityManager::getInstance().update();    // preUpdate → score=0
CLevelManager::getInstance().update();
CLuaEngine::getInstance().levelPostUpdate(); // postUpdate → score=correct
CSessionManager::getInstance().update();   // reads correct score
```

### Why This Matters
Without the friction fix, players on city/space levels slide off targets without scoring. Without the main loop fix, `level_city_paint` (and any level using per-frame score recalculation via postUpdate) always reports 0 score — painting works visually but no points are ever awarded.

---

## 14. Negative Score Support

**File:** [server/src/entity_lua_proxy.cpp](../server/src/entity_lua_proxy.cpp)

### Problem
The `setCurrentScore` function in the server's entity Lua proxy cast the score to `uint32` before assigning it to `CurrentScore` (which is declared as `sint32`). This caused negative scores to underflow into large positive numbers.

The `level_bowls1` level uses negative scores for distance-based penalties — the farther you land from the target center, the more negative points you receive. With the unsigned cast, a score of -100 would become 4,294,967,196.

### Change
**Line 263:**
```cpp
// Before (broken):
_entity->CurrentScore = ((uint32)score);

// After (fixed):
_entity->CurrentScore = ((sint32)score);
```

### Why This Matters
The client already used `(sint32)` for the same function. This fix aligns the server with the client and enables levels that use negative scoring mechanics.

---

## 15. v1.5.19 Feature Ports

### Music Controls

**File:** [client/src/controler.cpp](../client/src/controler.cpp)

Added F5/F6/Shift+F7 key bindings for music playback control, replacing the broken addBot/kickBot commands (which crashed the game).

```cpp
// F5: Pause/resume music
if (C3DTask::getInstance().kbPressed(KeyF5))
    CSoundManager::getInstance().switchPauseMusic();

// F6: Previous track
if (C3DTask::getInstance().kbPressed(KeyF6))
    CSoundManager::getInstance().playPreviousMusic();

// Shift+F7: Next track (F7 alone is free look toggle)
if (C3DTask::getInstance().kbDown(KeySHIFT))
    CSoundManager::getInstance().playNextMusic();
```

### Replay Playback Controls

**Files:**
- [client/src/time_task.h](../client/src/time_task.h) - Added `speedTime()`, `getSpeedTime()`, `realDeltaTime()` methods
- [client/src/time_task.cpp](../client/src/time_task.cpp) - Added `TimeSpeed` multiplier to delta time calculation
- [client/src/controler.cpp](../client/src/controler.cpp) - Added replay key bindings

Added time speed control and comprehensive replay playback controls:
- Home: Reset replay
- Z: Pause/resume
- S/X: Gradual slow down / speed up
- A/E/Q/D/W/C: Hold-for-speed controls (replaySetSpeed helper function)

### External Camera Task

**Files:**
- [client/src/external_camera_task.h](../client/src/external_camera_task.h) - NEW
- [client/src/external_camera_task.cpp](../client/src/external_camera_task.cpp) - NEW
- [client/src/mtp_target.cpp](../client/src/mtp_target.cpp) - Task registration
- [client/src/controler.cpp](../client/src/controler.cpp) - Key binding update
- [client/src/sky_task.h](../client/src/sky_task.h) - Added `skyScene()` accessor for PIP sky rendering
- [client/src/entity_manager.h](../client/src/entity_manager.h) - Added `fontScale` parameter to `renderNames()`
- [client/src/entity_manager.cpp](../client/src/entity_manager.cpp) - Pass font scale to entity renderName()
- [client/src/entity.h](../client/src/entity.h) - Added `fontScale` parameter to `renderName()`
- [client/src/entity.cpp](../client/src/entity.cpp) - Apply font scale to printf3D

Ported from v1.5.19: Picture-in-picture camera view rendered in the corner of the screen. Two modes:
1. **Entity-following** - Tracks nearest player within 10m above your position
2. **Fixed position** - Uses level-defined external camera position

v1.5.19 feature parity:
- **CVariable support** - Runtime-configurable viewport (x1/y1/w1/h1), scissor (x2/y2/w2/h2), name scale (sc), and entity tracking distance (DistToFollowInExternalCam)
- **Sky scene rendering** - PIP window renders sky background correctly
- **Font scaling** - Player names render at 4x size in PIP for readability (configurable via `sc` variable)
- **DisplayExternalCamera** - CVariable to enable/disable PIP globally

Key binding: Alt+A toggle

### Graph Visualization

**Files:**
- [client/src/graph.h](../client/src/graph.h) - NEW
- [client/src/graph.cpp](../client/src/graph.cpp) - NEW
- [client/src/chat_task.cpp](../client/src/chat_task.cpp) - Graph rendering integration
- [client/src/main.cpp](../client/src/main.cpp) - DisplayDebug type change
- [client/src/mtp_target.h](../client/src/mtp_target.h) - DisplayDebug type change
- [client/src/controler.cpp](../client/src/controler.cpp) - F4 key binding

Changed `DisplayDebug` from `bool` to `uint8` to support multiple debug modes:
- 0: Off
- 1: Debug info (camera position, FPS)
- 2: Performance graphs
- 3: Trace mode

CGraph class renders real-time graphs with:
- Current values as vertical bars
- Mean line with value label
- Peak line with value label
- Semi-transparent colored background

Graphs include: FPS, MSPF, nbkeys, LCT, packetdt, dt, ping

### Gate System

**Files:**
- [client/src/gate.h](../client/src/gate.h) - NEW
- [client/src/gate.cpp](../client/src/gate.cpp) - NEW
- [client/src/gate_lua_proxy.h](../client/src/gate_lua_proxy.h) - NEW
- [client/src/gate_lua_proxy.cpp](../client/src/gate_lua_proxy.cpp) - NEW
- [client/src/level.h](../client/src/level.h) - Gates vector and functions
- [client/src/level.cpp](../client/src/level.cpp) - Gate loading and Lua registration

Added native C++ gate objects for visual rings in gate-mode levels:
- `CGate` class inheriting from `CEditableElementCommon`
- `CGateProxy` for Lua bindings (position, scale, score, userData)
- Gates stored in `CLevel::Gates` vector
- Lua functions: `addGate()`, `getGateById()`, `gateById()`
- Visual representation using col_box.shape

---

## 16. Lunar Template Metatable Fix (Intermittent Scoring)

**File:** [common/lunar.h](../common/lunar.h)

### Problem
Players intermittently received 0 points when landing on scoring targets. The bug was unpredictable - scoring worked for 10+ rounds, failed for 1-2 rounds, then worked again. Crucially, the bug **disappeared** when debug `print()` statements were added, strongly suggesting a timing/GC-related issue.

### Root Cause
The Lunar template's `push()` function uses a weak "v" table to cache userdata by C++ pointer. When `pushuserdata()` finds existing cached userdata, it returns NULL and the original code only set the metatable when `ud != NULL`. If the cached userdata's metatable became stale after garbage collection, `entity.collideWithModule` would return nil because the method lookup failed.

Player-player collision "fixed" the issue because `entityEntityCollideEvent()` exercises `Lunar::push()` first, which would prime the metatable cache or trigger GC at a safe point.

### Changes

#### Metatable Application (lines 106-130)
**Before:**
```cpp
static int push(lua_State *L, T *obj, bool gc=false) {
    // ...
    userdataType *ud = static_cast<userdataType*>(pushuserdata(L, obj, sizeof(userdataType)));
    if (ud) {
        ud->pT = obj;  // store pointer to object in userdata
        lua_pushvalue(L, mt);
        lua_setmetatable(L, -2);  // Only set metatable for NEW userdata
        // ... gc handling ...
    }
    lua_replace(L, mt);
    lua_settop(L, mt);
    return mt;
}
```

**After:**
```cpp
static int push(lua_State *L, T *obj, bool gc=false) {
    // ...
    userdataType *ud = static_cast<userdataType*>(pushuserdata(L, obj, sizeof(userdataType)));
    if (ud) {
        ud->pT = obj;  // store pointer to object in userdata
        // ... gc handling (moved before metatable set) ...
    }
    // ALWAYS set metatable, not just for new userdata
    lua_pushvalue(L, mt);
    lua_setmetatable(L, -2);  // Ensures cached userdata has valid metatable
    lua_replace(L, mt);
    lua_settop(L, mt);
    return mt;
}
```

### Why This Matters
The fix ensures the metatable is always properly set on the userdata, regardless of cache state. This eliminates the race condition where cached userdata might have a stale metatable reference after garbage collection.

---

## 17. Modern Text Input

**Files:**
- [client/src/text_editor.h](../client/src/text_editor.h) (NEW)
- [client/src/text_editor.cpp](../client/src/text_editor.cpp) (NEW)
- [client/src/gui_text.h](../client/src/gui_text.h)
- [client/src/gui_text.cpp](../client/src/gui_text.cpp)
- [client/src/chat_task.h](../client/src/chat_task.h)
- [client/src/chat_task.cpp](../client/src/chat_task.cpp)
- [client/src/font_manager.h](../client/src/font_manager.h)
- [client/src/font_manager.cpp](../client/src/font_manager.cpp)
- [client/src/CMakeLists.txt](../client/src/CMakeLists.txt)

### Problem
Text input in GUI fields (IP address, username, password) and chat lacked basic PC editing features. No clipboard paste (Ctrl+V), no copy/cut, no text selection, no word navigation. Both input systems (`CGuiText` for GUI fields, `CChatTask` for chat) implemented input handling from scratch with minimal features (just typing, backspace, and arrow keys).

### Changes

#### New CTextEditor Class
Created a shared text editing state machine that encapsulates all text editing logic:
- **State:** text content, cursor position, selection anchor (-1 = no selection), max length, undo stack
- **Editing:** insert, delete back/forward, delete word back, undo (Ctrl+Z)
- **Cursor movement:** left/right/home/end (all with shift for selection), word-level with Ctrl
- **Clipboard:** copy/cut/paste via NeL's `UDriver::copyTextToClipboard/pasteTextFromClipboard`
- **Selection:** select all, clear, get selected text
- **Undo:** up to 50 undo levels, saves state before each edit operation
- **Input processing:** `processInput()` reads keyboard state for one frame, handling all shortcuts
- **Word boundaries:** treats word chars (alphanumeric + underscore), punctuation, and spaces as separate categories for Ctrl+Backspace and Ctrl+Left/Right

#### CGuiText Integration (gui_text.cpp)
Replaced the hand-rolled character-by-character input loop with `_editor.processInput()`. Added external text sync (for Lua-driven text changes) and selection highlight rendering using a custom `CQuad` with `selectionMaterial` (requires `setZFunc(always)` to render above GUI entry backgrounds). Select-all on focus gain for easy text replacement.

#### CChatTask Integration (chat_task.cpp)
Replaced the static `ChatInput` string and manual character loop with `_chatEditor`. Added blinking cursor rendering at the correct pixel position and selection highlight rendering. The `addToInput()` method now delegates to `_chatEditor.insertText()`.

#### CFontManager Addition (font_manager.h/cpp)
Added `littleStringWidth()` method to measure text width in the chat font using `LittleTextContext->getStringInfo()`.

### Why This Matters
Players can now paste server IP addresses, use standard Ctrl+C/X/V clipboard operations, select text with shift+arrows, and navigate by word with Ctrl+arrows. These are basic expectations for any PC application text input.

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
