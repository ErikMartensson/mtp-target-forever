# Known Issues and Future Tasks

This document tracks known issues and planned improvements for MTP Target Forever.

## High Priority

### 1. Intermittent Scoring Failure (Game-Breaking)
**Status:** Fix Applied (February 8, 2026) - Requires Testing
**Severity:** Game-breaking - players get 0 points when they should score
**Affected Levels:** At least `level_bowls1` (likely affects all levels using `collideWithModule`)

**Description:**
Players intermittently receive 0 points when landing on scoring targets, even when collision detection confirms the player is on the target. The bug is unpredictable - scoring may work for 10+ consecutive rounds, then fail for 1-2 rounds, then work again.

**Symptoms:**
- Player lands on scoring target but receives 0 points
- Bots also affected (not player-specific)
- Works correctly for several rounds, then fails, then works again
- No error messages in logs when failure occurs
- Pattern is completely unpredictable

**Key Observation (Critical Clue):**
Adding debug `print()` statements in the Lua scoring callback or debug logging in C++ code **prevents the bug from occurring**. The bug only appears when NOT debugging. This strongly suggests:
- Race condition or timing-dependent issue
- Compiler optimization eliminating necessary operations
- Memory ordering/visibility issue between threads or between C++ and Lua

**Reproduction Steps:**
1. Set server playlist to only `level_bowls1`
2. Connect with client and play rounds
3. Land on the green target bar in the center
4. Score should be distance-based (closer = higher score)
5. After ~5-15 rounds, scoring randomly stops working
6. Continue playing - it will randomly start working again

**Technical Investigation (February 2026):**

1. **Collision Detection Layer (`physics.cpp`):**
   - `dCollide()` returns 1 (collision detected) ✓
   - Module is added to `collideModules` set ✓
   - This layer appears to work correctly

2. **Entity Update Layer (`entity.cpp`):**
   - `collideModules` set is iterated
   - `entitySceneCollideEvent()` is called for each module
   - Lua callback `collideWithModule(module)` should be invoked

3. **Lua Scoring Layer (`level_bowls1_server.lua`):**
   - `CEntity:collideWithModule(module)` calculates distance-based score
   - Calls `self:setCurrentScore(score, false)`
   - When bug occurs, this callback may not be executing or score not being set

**Code Flow:**
```
physics.cpp:dCollide() → entity.cpp:collideModules set →
lua_engine.cpp:entitySceneCollideEvent() → Lua:collideWithModule() →
entity_lua_proxy.cpp:setCurrentScore()
```

**Attempted Fixes (All Failed):**

1. **Volatile memory barrier in physics.cpp:**
   ```cpp
   volatile int numContacts = numc;  // Force memory barrier
   if(numContacts > 0) { ... }
   ```
   Result: Bug still occurs

2. **Volatile memory barrier in entity.cpp:**
   ```cpp
   volatile uint32 moduleScore = (*mit)->score();
   (void)moduleScore;  // Force read before Lua callback
   CLuaEngine::getInstance().entitySceneCollideEvent(this,*mit);
   ```
   Result: Bug still occurs

3. **Debug print statements in Lua:**
   ```lua
   print("collideWithModule called, module score: " .. module:getScore())
   ```
   Result: Bug STOPS occurring (but adds log spam)

**Possible Root Causes to Investigate:**

1. **Lua State Corruption:**
   - Lua garbage collection running at wrong time
   - Metatable or userdata being collected prematurely
   - Stack corruption between C++ and Lua calls

2. **Threading/Timing Issue:**
   - Physics runs in separate thread from Lua?
   - Race between collision detection and Lua callback
   - Entity state changing between collision detect and score set

3. **Compiler Optimization (MSVC):**
   - Aggressive optimization eliminating "unnecessary" operations
   - Try building with `/Od` (disable optimization) to confirm
   - May need `#pragma optimize("", off)` around critical sections

4. **ODE Physics Library:**
   - Trimesh collision detection returning stale data
   - Contact geom data being overwritten before processing
   - dCollide internal state issue

5. **Bot Replay System:**
   - Bots replaying forces that interfere with collision
   - First round (no replays) vs subsequent rounds (with replays)
   - However, bug also affects human players

**Files Involved:**
- `server/src/physics.cpp` - ODE collision detection, `nearCallback()`
- `server/src/entity.cpp` - `collideModules` set processing, lines ~318-327
- `server/src/lua_engine.cpp` - `entitySceneCollideEvent()` Lua invocation
- `server/src/entity_lua_proxy.cpp` - `setCurrentScore()` C++/Lua bridge
- `data/lua/level_bowls1_server.lua` - Distance-based scoring logic
- `data/lua/helpers.lua` - Lua utility functions

**Fix Applied (February 8, 2026):**

Root cause identified: **Lunar template's userdata caching with weak table GC**. The `Lunar::push()` function uses a weak "v" table to cache userdata by C++ pointer. When cached userdata is reused, `pushuserdata()` returns NULL, and the metatable was NOT re-applied. If the cached userdata's metatable state became stale after GC, `entity.collideWithModule` would return nil.

Why player-player collision "fixed" it: `entityEntityCollideEvent()` exercises the same `Lunar::push()` path first, which would prime the cache or trigger GC at a safe point.

**Changes Applied:**

1. **`common/lunar.h`** - Modified `Lunar::push()` to ALWAYS set metatable, not just for new userdata. This ensures cached userdata from the weak table always has a valid metatable reference.

2. **`data/lua/helpers.lua`** - Added silent debug counters to track method lookup success/failure:
   - `_dbg_collideWithModule_called` / `_dbg_collideWithModule_nil`
   - `_dbg_collideWithEntity_called` / `_dbg_collideWithEntity_nil`
   - `_dbg_collideWithWater_called` / `_dbg_collideWithWater_nil`

3. **`server/src/lua_engine.cpp`** - Added metatable verification diagnostic in `entitySceneCollideEvent()` (DEBUG builds only).

**Verification Steps:**
1. Build server with changes
2. Set playlist to only `level_bowls1`
3. Play 20+ rounds solo (no player-player collisions)
4. Check Lua counters: `_dbg_collideWithModule_nil` should stay at 0
5. Scoring should work consistently

**Current State of Codebase:**
The metatable fix in lunar.h should eliminate the intermittent failure. Silent counters remain in helpers.lua for monitoring. Volatile memory barriers in physics.cpp and entity.cpp are also still in place.

---

### ~~2. Missing Maps~~ (FIXED)
**Status:** ✅ 60 playable levels (32 original + 28 restored from v1.5.19)
**Description:** All levels have been ported. Built a Lua compatibility bridge to support v1.5.19-style `CLevel:init()` levels alongside the original v1.2.2a global-table format.

**Restored Levels (28):**
- Space: 10 levels (`level_space_asteroids`, `fleet`, `atomium`, `calbren`, `cargo_inside`, `hangar18`, `havoc`, `hotwings`, `imo_rings`, `stabilo`)
- Sun: 4 levels (`level_sun_target`, `cross`, `extra_ball`, `paint`)
- City: 5 levels (`level_city_easy`, `darts`, `paint`, `destroy`, `precision`)
- Gates: 4 levels (`level_gates_easy`, `hard`, `ramp`, `zig_zag`)
- Other: 5 levels (`level_bowls1`, `donuts2`, `mtp_paint`, `snow_line`, `team_space`)

**Note:** Space levels use ReleaseLevel 6, which may need to be added to the server's allowed ReleaseLevel list. New levels require runtime testing to verify textures, scoring, and theme rendering.

---

### 2. New v1.5.19 Levels Need Per-Level Fixes
**Status:** In Progress (engine-level fixes applied; per-level testing ongoing)
**Description:** All 28 restored v1.5.19 levels load without crashing. Engine-level fixes for friction and score timing have been applied. Individual levels need testing to verify gameplay.

**Engine-level fixes applied:**
- ~~**Missing friction on landing platforms**~~ ✅ FIXED - Scoring modules (Score > 0) with no friction now auto-apply friction=10 in C++ level loader
- ~~**postUpdate scoring broken**~~ ✅ FIXED - Reordered main loop so session manager runs after levelPostUpdate. Fixes city_paint and similar per-frame score recalculation levels.

**Remaining issues:**

**a) ~~Missing level Name~~ ✅ FIXED**
- ~~New levels didn't display a name in chat or match bot replay files~~
- Fixed: Added `Name = "Display Name"` global to all 31 v1.5.19 levels

**b) ~~Bot behavior erratic on new levels~~ ✅ FIXED**
- ~~Bots loaded wrong replay data because level Name was empty, causing `string::find("")` to match every replay file~~
- Fixed: Adding level names prevents cross-level replay file matching. Bots are now passive (no matching replays) rather than erratic

**Per-level testing checklist:**

| Level | Loads | Ramp OK | Scoring | Bots | Notes |
|-------|-------|---------|---------|------|-------|
| `level_space_asteroids` | ✓ | ✓ | ✓ | Passive | Maybe too fast, but playable |
| `level_space_atomium` | ? | ? | ? | ? | |
| `level_space_calbren` | ? | ? | ? | ? | |
| `level_space_cargo_inside` | ? | ? | ? | ? | |
| `level_space_fleet` | ? | ? | ? | ? | |
| `level_space_hangar18` | ? | ? | ? | ? | |
| `level_space_havoc` | ? | ? | ? | ? | |
| `level_space_hotwings` | ? | ? | ? | ? | |
| `level_space_imo_rings` | ? | ? | ? | ? | |
| `level_space_stabilo` | ? | ? | ? | ? | |
| `level_sun_target` | ✓ | ✓ | ✓ | Passive | Works fine |
| `level_sun_cross` | ? | ? | ? | ? | |
| `level_sun_extra_ball` | ? | ? | ? | ? | |
| `level_sun_paint` | ? | ? | ? | ? | |
| `level_city_easy` | ✓ | ✓ | ✓ | Passive | Fixed with engine-level friction |
| `level_city_darts` | ? | ? | ? | ? | |
| `level_city_paint` | ✓ | ✓ | ✓ | Passive | Painting and scoring work (fixed with main loop reorder) |
| `level_city_destroy` | ? | ? | ? | ? | |
| `level_city_precision` | ? | ? | ? | ? | |
| `level_gates_easy` | ✓ | ✓ | ✓ | Passive | Works fine, gate scoring works |
| `level_gates_hard` | ? | ? | ? | ? | |
| `level_gates_ramp` | ? | ? | ? | ? | |
| `level_gates_zig_zag` | ? | ? | ? | ? | |
| `level_bowls1` | ✓ | ✓ | **BUG** | Passive | See Issue #1 - Intermittent scoring failure |
| `level_donuts2` | ? | ? | ? | ? | |
| `level_mtp_paint` | ? | ? | ? | ? | |
| `level_snow_line` | ? | ? | ? | ? | |
| `level_team_space` | ? | ? | ? | ? | |

**Related Files:**
- `data/lua/utilities.lua` - Base CLevel shim (addModule defaults)
- `data/lua/utilities_snow.lua` - `setRamp()`, `setTeamRamp()`
- `data/lua/utilities_sun.lua` - `setSunRamp()`
- `data/lua/utilities_space.lua` - `setSpaceRamp()`
- `server/src/level.cpp` - Reads Name, Author, Modules from Lua globals (+ default friction)
- `server/src/main.cpp` - Main loop ordering (session manager after postUpdate)

---

### ~~3. Team Level Scoring Inconsistencies~~ (FIXED)
**Status:** ✅ FIXED (February 9, 2026)
**Description:** Multiple issues with team levels (`level_team_90`, `level_team_all_on_one`, `level_team_classic`, `level_team_mirror`).

**Issues Fixed:**
1. **Always assigned to red team** - Team assignment algorithm always picked team 0 when packs were tied in size. Fixed by collecting tied candidates and randomly selecting one.
2. **Bots fly wrong direction on opposite team** - Fallback replays from the wrong side were loaded on split-ramp levels. Fixed with distance-based validation (>5 units = wrong side, discard).
3. **Team score text persists to non-team levels** - Off-by-one bug in `levelEndSession()` caused a Lua error before cleanup lines executed. Fixed loop bound to `entityCount-1`.
4. **Score reset in level_team_all_on_one** - Applied `scoringHappenedThisFrame` guard (same fix as level_team_server.lua) and added missing cleanup lines.

**Files Modified:**
- `server/src/entity_manager.cpp` - Randomize team pack selection when tied
- `server/src/bot.cpp` - Distance-based replay validation for fallback replays
- `data/lua/level_team_server.lua` - Fix off-by-one in `levelEndSession()` loop
- `data/lua/level_team_all_on_one_server.lua` - Fix off-by-one, add cleanup, add scoring fix

---

### 4. ~~Bot AI Erratic on v1.5.19 Levels~~ (FIXED)
**Status:** ✅ FIXED (February 4, 2026)
**Description:** Bots were erratically flying around on v1.5.19 levels, loading wrong replay data.

**Root Cause:**
The bot replay system (`server/src/bot.cpp:135-141`) matches replay files by level name using `string::find(CurrentLevel)`. When a level's `Name` global was empty (all 31 v1.5.19 levels), `string::find("")` returns 0 for every filename, so bots loaded replay data from completely wrong levels — replaying forces intended for different geometry.

**Fix Applied:**
Added `Name = "Display Name"` to all 31 v1.5.19 level files. With proper names set, bots search for matching replay files (e.g., "Space Fleet.6.000.mtr") and find none, making them passive rather than erratic.

**Note:** Bots are now passive on v1.5.19 levels (no replay data exists). To make bots actively play these levels, players would need to record replays. Bots still work on original snow levels that have matching replay files.

**Files Modified:**
- 31 level files in `data/level/` — added `Name` global

---

## Medium Priority

### 5. High Ping on Local Server
**Status:** Not Started
**Description:** Playing on a locally-hosted server results in 17-19ms ping. Modern games typically have near-zero ping for local connections.

**Note:** Network update rate was changed from 40ms to 20ms (50 Hz) in `server/src/network.cpp:142`, but this did not significantly reduce ping.

**Possible Causes:**
- Client-side interpolation adding latency
- Sleep/wait calls in network loop
- Inefficient packet handling

**Investigation Areas:**
- `client/src/interpolator.cpp` - Client-side position smoothing
- `server/src/network.cpp` - Network tick rate and packet handling
- Client-side prediction settings

---

### 6. Input Delay / Steering Lag
**Status:** Not Started
**Description:** There's a noticeable delay between steering inputs and the penguin actually changing direction. This may be related to the high ping issue.

**Symptoms:**
- Delayed response to arrow key/WASD input
- Penguin takes time to turn
- Feels "laggy" even on local server

**Possible Causes:**
- Client-side input buffering
- Server-side input processing delay
- Interpolation smoothing too aggressive
- Network update rate too low

**Related Files:**
- `client/src/interpolator.cpp` - Client-side movement interpolation
- `client/src/mtp_target.cpp` - Input handling
- `server/src/entity.cpp` - Server-side entity updates

---

### 7. ~~Momentum Loss on Ramp Transition~~ (FIXED)
**Status:** ✅ FIXED (January 2, 2026)
**Description:** Players would lose momentum at slope-to-ramp transitions, stopping abruptly at angle changes.

**Root Cause Identified:**
ODE's trimesh collision response was absorbing momentum at triangle mesh edges. When the sphere crossed from one triangle to another, ODE generated contact normals pointing into the velocity direction, treating edge crossings as frontal collisions.

**Debug evidence showed:**
```
Before: pos(-0.149,-3.360,4.245) vel(-0.038,0.557,-0.376)
After:  pos(-0.149,-3.360,4.245) vel(-0.036,0.480,-0.188)
```
Velocity dropped 50% at the same position with no code-triggered velocity zeroing.

**Fix Applied:**
Changed contact surface mode from `dContactMu2` to `dContactApprox1` in `server/src/physics.cpp`:
- `dContactMu2` with infinite friction treated edge contacts as head-on collisions
- `dContactApprox1` uses friction pyramid approximation that preserves tangential velocity

**Files Modified:**
- `server/src/physics.cpp:243-257` - Contact mode changed to dContactApprox1

**Failed Approaches (for reference):**
1. Fix dBodySetAngularVel bug - No improvement (still valid bug fix)
2. Reduce network throttle 40ms→5ms - No improvement
3. Reduce CFM 1e-2→1e-4 - Made worse
4. High bounce (0.9) + low threshold - Made worse
5. Reduced friction (mu=100) - Made worse
6. Slip mode contacts - No improvement

---

### 8. ~~Darts Map Spawn Position~~ (FIXED)
**Status:** ✅ FIXED
**Description:** level_darts is now working correctly with proper acceleration, visibility, and scoring.

---

### 9. ~~Team Mirror Level Scoring~~ (FIXED)
**Status:** ✅ FIXED
**Description:** Team levels now work correctly with original scoring logic restored.

**Fix Applied:**
Restored original scoring behavior in `level_team_server.lua`:
- Landing on your own team's target gives positive points
- Landing on enemy team's target gives negative points (subtracted from team score)

The level layout is correct - targets are on opposite sides of Y=0 (red team at negative Y, blue team at positive Y), not overlapping.

**Files Modified:**
- `data/lua/level_team_server.lua` - Restored original negative scoring for enemy targets

---

## Technical Notes

### Level Geometry and Z-Offset Collision Behavior
**Category:** Documentation / Quirk

When creating stacked target zones (like in `level_snow_pyramid`), the collision boxes can use very small Z offsets (0.01 units) to create proper collision separation, even when this seems mathematically impossible given the Z scale (0.5 units).

**Example from level_snow_pyramid:**
```lua
{ Position = CVector(0, -15, 3),    Scale = CVector(14, 14, 0.5), Score = 50 }
{ Position = CVector(0, -15, 3.01), Scale = CVector(7, 7, 0.5),   Score = 100 }
{ Position = CVector(0, -15, 3.02), Scale = CVector(3, 3, 0.5),   Score = 300 }
```

Despite boxes extending 0.5 units in Z (from Z to Z+0.5), they behave as distinct collision surfaces. The ODE physics engine appears to handle contact detection in a way that the first contact "wins" even when shapes technically overlap. This behavior is correct and should be preserved.

**Takeaway:** When porting levels, preserve the original small Z offsets - they work correctly in-game even if they appear overlapping on paper.

---

## Low Priority / Nice to Have

### 10. /reset Command Broken
**Status:** Not Started
**Description:** The `/reset` command (Ctrl+F6) behaves identically to `/forceend` (Ctrl+F5) - it advances to the next level instead of restarting the current session.

**Expected Behavior:** Reset should restart the current level from the beginning without advancing to the next map.

**Actual Behavior:** Both commands advance to the next level in the rotation.

**Related Files:**
- `server/src/session_manager.cpp` - Contains the reset() function
- `server/src/net_callbacks.cpp` - Command handling

---

### 11. Non-functional Debug Keys
**Status:** Partially Fixed
**Description:** Several client debug keys don't work as expected.

**Fixed Keys:**
| Key | Action | Status |
|-----|--------|--------|
| F4 | Cycle debug display modes (off/debug/graphs/trace) | ✅ Fixed |

**Non-functional Keys:**
| Key | Expected Action |
|-----|-----------------|
| Shift+F1 | Toggle start positions display |
| Ctrl+F4 | Toggle debug info overlay |

**Related Files:**
- `client/src/controler.cpp` - Key handling
- `client/src/editor_task.cpp` - Editor mode

---

### 12. Bot Commands Cause Server Crashes
**Status:** Workaround Applied
**Description:** The F5 (addBot) and F6 (kick bot) commands cause the server to crash when executed during gameplay.

**Root Cause:** The bot system requires replay data and proper session state that isn't available during active gameplay.

**Workaround Applied:** Both commands are now blocked at the server level in `net_callbacks.cpp`. Users receive a message explaining the command is disabled.

**Files Modified:**
- `server/src/net_callbacks.cpp:180-191` - Added blocks for addBot and kick commands

---

### 13. Water Rendering Disabled
**Status:** Workaround Applied
**Description:** Water rendering is currently disabled because the required water textures or shaders are missing.

**Current Workaround:** Water task falls back gracefully when `water_light.shape` is missing.

---

### 14. ~~Snow Particles Not Loading on Some Systems~~ (FIXED)
**Status:** ✅ FIXED (January 8, 2026)
**Description:** The snow particle effect (`snow.ps`) was not loading on some systems.

**Root Causes Found:**
1. Particle files were marked as "optional" in CI build system, causing them to be excluded from artifacts
2. Missing null checks in external camera code caused crashes when particles weren't loaded

**Fixes Applied:**
1. Changed `particle` from optional to required in `scripts/assets-manifest.json` so CI builds include particles
2. Added null checks before LevelParticle hide/show calls in `client/src/3d_task.cpp`
3. Added Particles toggle to Options menu for easy enable/disable (requires restart)

**Files Modified:**
- `scripts/assets-manifest.json` - particle now in required directories
- `client/src/3d_task.cpp:337-350` - LevelParticle.empty() checks
- `client/src/options_menu.cpp` - Particle toggle
- `client/data/gui/options.xml` - Particle toggle UI

---

### 15. Version Compatibility
**Status:** Mostly Resolved
**Description:** The current build uses v1.2.2a source code with a Lua compatibility bridge for v1.5.19 levels. All v1.5.19 level files are now loadable.

**Remaining gaps:**
- `setAdvancedLevel(true)` - Stubbed as no-op (unknown effect, used by space levels)
- ~~`level():teamMode()` - Not yet implemented~~ ✅ Implemented in utilities.lua (February 4, 2026)
- ~~Gate AABB collision used wrong CLuaVector API~~ ✅ Fixed `.x/.y/.z` → `:getX()/:getY()/:getZ()` (February 4, 2026)
- ~~userData not transferred from CLevelModule to CModuleProxy~~ ✅ Fixed in levelInit() (February 4, 2026)
- ~~Negative scores may underflow (C++ `setCurrentScore` casts to `uint32` - affects bowls1)~~ ✅ Fixed cast to `sint32` (February 5, 2026)

---

## Completed

- [x] Fix client crash when connecting to server
- [x] Fix server crash on client connection
- [x] Fix ODE physics assertion crash
- [x] Fix missing textures (snow, water, etc.)
- [x] Fix penguin visual size matching collision sphere
- [x] Fix keyboard controls (chat no longer captures arrow keys)
- [x] Implement Lua include() function for level files
- [x] Add build automation scripts
- [x] Consolidate game assets in data/ directory
- [x] **Fix momentum loss on ramp transitions** (January 2, 2026) - Changed ODE contact mode to dContactApprox1
- [x] **Fix team level scoring** (January 4, 2026) - Restored original negative enemy scoring in level_team_server.lua
- [x] **Fix level_team_mirror** (January 4, 2026) - Fixed camera direction and added fallback team detection from module names
- [x] **Port level_team_classic** (January 4, 2026) - Replaced broken level_team with proper level_team_classic from original sources
- [x] **All 32 playable levels tested** (January 4, 2026) - Every level verified working with scoring, friction, and slope steering fixes applied
- [x] **Fixed F5/F6 server crashes** (January 4, 2026) - Blocked addBot and kick commands from clients to prevent crashes
- [x] **Add pause menu** (January 7, 2026) - ESC key opens pause menu with Resume, Options, Disconnect, Quit
- [x] **Add options to pause menu** (January 7, 2026) - Volume controls accessible mid-game without disconnecting
- [x] **Fix disconnect/reconnect crashes** (January 7, 2026) - Proper cleanup of tasks, entities, and GUI on disconnect
- [x] **Refactor options menu** (January 7, 2026) - Consolidated duplicate code into COptionsMenu class with callback interface
- [x] **Fix sound effects** (January 7, 2026) - All game sounds working: countdown, open/close, impact, splash. Added distance-based volume for other players, user volume scaling, and client-side water collision detection
- [x] **Fix external camera crash** (January 8, 2026) - Added null checks for LevelParticle before hide/show to prevent crash when snow particles aren't loaded
- [x] **Fix snow particles in CI builds** (January 8, 2026) - Moved particle directory from optional to required in assets-manifest.json
- [x] **Add particle toggle to options menu** (January 8, 2026) - Users can enable/disable snow particles via Options menu (requires restart)
- [x] **Fix unknown command server crash** (January 8, 2026) - Typing non-existent commands like `/forcelevel` no longer crashes the server. Fixed NULL pointer dereference in command.cpp and improved command validation in net_callbacks.cpp
- [x] **Restore all missing v1.5.19 levels** (February 2, 2026) - Ported 28 levels across space, sun, city, and gate themes via Lua compatibility bridge. Added CLevel:init() support, module texture application, CLuaVector methods, gate AABB collision, and v1.5.19 naming aliases
- [x] **Fix utilities.lua double-include crash** (February 2, 2026) - Levels including multiple theme utilities (e.g. utilities_snow + utilities_sun) would crash because the second include reset `CLevel = {}`. Added include guard.
- [x] **Fix CRGBA 3-argument crash** (February 2, 2026) - v1.5.19 levels use `CRGBA(r,g,b)` without alpha. Changed `luaL_checknumber` to `luaL_optnumber` with default 255 for the alpha parameter in `common/lua_nel.h`.
- [x] **Add nil guard for Modules table** (February 2, 2026) - Server and client would panic if a level's Lua failed and Modules table was nil. Added nil checks before `lua_next` iteration in both `server/src/level.cpp` and `client/src/level.cpp`.
- [x] **Fix gate AABB collision bug** (February 4, 2026) - Gate collision detection used `.x`/`.y`/`.z` property access on CLuaVector, but CLuaVector is a userdata type that only supports `:getX()`/`:getY()`/`:getZ()` methods. Fixed in `data/lua/helpers.lua`.
- [x] **Add userData transfer for city_paint** (February 4, 2026) - CModulePaintBloc objects stored on CLevelModule proxies during `CLevel:init()` weren't accessible on CModuleProxy objects created later. Added transfer logic in `levelInit()` in `data/lua/helpers.lua`.
- [x] **Implement level():teamMode()** (February 4, 2026) - Added team mode detection in `utilities.lua` by checking entity name prefixes. Used by `level_city_paint_server.lua`.
- [x] **Add Entity/Module/Level class name aliases** (February 4, 2026) - Bridged v1.5.19 naming (`CEntity`/`CModule`/`CLevel`) to v1.2.2a registered names (`Entity`/`Module`/`Level`) via aliases in `utilities.lua`.
- [x] **Engine-level default friction for scoring modules** (February 4, 2026) - Modules with Score > 0 and Friction == 0 now auto-apply friction=10 in `server/src/level.cpp`. Fixes city and space targets where balls would roll across without stopping.
- [x] **Fix main loop scoring timing** (February 4, 2026) - Moved `CSessionManager::update()` after `levelPostUpdate()` in `server/src/main.cpp`. Levels using per-frame score recalculation (e.g. city_paint) had CurrentScore=0 when the session manager checked it, because preUpdate reset score before postUpdate recalculated it.
- [x] **Fix bot erratic behavior on v1.5.19 levels** (February 4, 2026) - Added `Name` global to all 31 v1.5.19 levels. Bots were loading wrong replay files because `string::find("")` matched every file. With proper names, bots are passive (no matching replays) instead of erratic.
- [x] **Fix negative score underflow** (February 5, 2026) - Server's `setCurrentScore` cast `lua_Number` to `uint32` instead of `sint32`, causing negative scores (used by bowls1) to underflow into large positive numbers. Fixed in `server/src/entity_lua_proxy.cpp`.
- [x] **Fix paint level crashes** (February 5, 2026) - `level_sun_paint` and `level_mtp_paint` crashed because they used `CModulePaintBloc` which was only defined in `level_city_paint_server.lua`. Replaced v1.2.2a `level_paint_server.lua` with v1.5.19 version that includes the class definition.
- [x] **Fix level_team_space crash** (February 5, 2026) - Level called undefined `CModuleBase:new(team)`. Changed to use `CModule:new(module, team)` which is defined in `level_team_server.lua`.
- [x] **Fix CVector comma bug** (February 5, 2026) - `utilities_sun.lua` had `CVector(-15, -50, 3,5)` where the comma should be a decimal point. Fixed to `CVector(-15, -50, 3.5)`.
- [x] **Add missing level names** (February 5, 2026) - Added `Name = "Gates Zig Zag"` to `level_gates_zig_zag.lua` which was missing it.
- [x] **Fix F4 graph visualization crash** (February 8, 2026) - Pressing F4 twice crashed the client because graph.cpp referenced non-existent config variable "Font" instead of "LittleFont". Fixed in `client/src/graph.cpp`.
- [x] **Populate debug graphs with data** (February 8, 2026) - Graphs were showing all zeros. Added data population for FPS, MSPF, Ping, NbKeys, LCT, and DT graphs in `time_task.cpp`, `net_callbacks.cpp`, and `interpolator.cpp`.
- [x] **Fix external camera entity filtering** (February 8, 2026) - External camera's 10m entity-following mode now correctly excludes crashed/water-collided entities. Added `Collided` flag to CEntity.
- [x] **Fix PIP font scaling** (February 8, 2026) - Player names in PIP window had wrong letter spacing. Fixed printf3D to scale quad size with the scale parameter in `font_manager.cpp`.
- [x] **Fix team level issues** (February 9, 2026) - Six fixes: cached team assignment (consistent & balanced), random tied-team selection, bot replay distance validation, off-by-one fix in levelEndSession, scoringHappenedThisFrame guard for level_team_all_on_one, blue 50-point platform color.

---

## Contributing

If you'd like to help fix any of these issues:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with your fix

Please include:
- Description of the fix
- Testing steps
- Any relevant screenshots or logs
