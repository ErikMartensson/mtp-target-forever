# Source Code Modifications

This document details all changes made to the MTP Target source code for compatibility with modern systems (Ubuntu 22.04+, 64-bit, current libraries).

**Last Updated:** December 22, 2025
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

**Total:** 10 files, ~85 lines changed

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

## Future Modifications

Potential future changes:

- **Windows Build:** CMake configuration for Visual Studio
- **Client Compilation:** Apply similar fixes to client code
- **Modern C++:** Update to C++11/14/17 features
- **Cross-platform:** Unified build system (CMake only)
- **Domain Changes:** Replace hardcoded mtp-target.org references

---

## Questions?

If you encounter issues after applying these modifications:

1. Check that you have the correct library versions installed
2. Verify your compiler is GCC 7+ or equivalent
3. Review the [BUILDING.md](BUILDING.md) guide
4. Check for additional system-specific requirements

For protocol debugging and network issues, see [PROTOCOL_NOTES.md](PROTOCOL_NOTES.md).
