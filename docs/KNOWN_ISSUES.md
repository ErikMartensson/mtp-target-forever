# Known Issues and Future Tasks

This document tracks known issues and planned improvements for the Tux Target game.

## High Priority

### 1. ~~Missing Maps~~ (MOSTLY FIXED)
**Status:** ✅ 32 of 32 playable levels working
**Description:** All snow-theme levels have been ported and tested. Remaining levels require space/sun/city theme assets.

**Working Levels (32):**
All playable levels (ReleaseLevel 1-5) have been tested and verified working. See [docs/LEVELS.md](LEVELS.md) for the complete list.

**Unavailable Levels (30):**
These require missing theme assets (space, sun, city) or gate mechanics:
- Space: `level_space_*` (12 levels)
- Sun: `level_sun_*` (7 levels)
- City: `level_city_*` (6 levels)
- Gates: `level_gates_*` (4 levels)
- Other: `level_bowls1` (1 level)

**Solution:** Import missing assets from original game data or create replacements.

---

### 2. Team Level Scoring Inconsistencies
**Status:** Partially Fixed
**Description:** Team level scoring can be unreliable in certain situations. Points may not always be counted correctly, especially with negative scores (landing on enemy targets).

**Symptoms:**
- Score display in top-left corner may show 0 when players stop actively colliding with targets
- Score display may persist into the next non-team level
- Negative scores (from landing on enemy targets) may not subtract correctly in some cases

**Root Cause:**
The team scoring system resets `currentTeamRedScore`/`currentTeamBlueScore` to 0 every frame, then accumulates scores from active collisions. When players stop colliding (ball stops on target), the frame score is 0, which can overwrite the accumulated total.

**Partial Fixes Applied:**
- Added nil-safety checks in `Module:collide()` for `entity:parent()` and `self:getScore()`
- Added text clearing in `levelEndSession()` to reduce persistence to next level
- Fixed `level_team_all_on_one` to use shared `level_team_server.lua` script

**Files Affected:**
- `data/lua/level_team_server.lua` - Main team scoring logic
- `data/lua/level_team_all_on_one_server.lua` - Unused (level now uses level_team_server.lua)

---

### 3. Bot AI Not Working on All Maps
**Status:** Not Started
**Description:** Bots aren't deploying (playing) correctly on all maps. This appears to be a per-map issue where bot behavior may depend on level-specific scripting.

**Symptoms:**
- Bots may not move properly
- Bots may not aim for targets correctly
- Some maps work better than others

**Solution:** Review and fix bot behavior on a per-map basis. May require updating Lua server scripts for each level.

---

## Medium Priority

### 4. High Ping on Local Server
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

### 5. Input Delay / Steering Lag
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

### 6. ~~Momentum Loss on Ramp Transition~~ (FIXED)
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

### 7. ~~Darts Map Spawn Position~~ (FIXED)
**Status:** ✅ FIXED
**Description:** level_darts is now working correctly with proper acceleration, visibility, and scoring.

---

### 8. ~~Team Mirror Level Scoring~~ (FIXED)
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

### 9. /reset Command Broken
**Status:** Not Started
**Description:** The `/reset` command (Ctrl+F6) behaves identically to `/forceend` (Ctrl+F5) - it advances to the next level instead of restarting the current session.

**Expected Behavior:** Reset should restart the current level from the beginning without advancing to the next map.

**Actual Behavior:** Both commands advance to the next level in the rotation.

**Related Files:**
- `server/src/session_manager.cpp` - Contains the reset() function
- `server/src/net_callbacks.cpp` - Command handling

---

### 10. Non-functional Debug Keys
**Status:** Not Started
**Description:** Several client debug keys don't work as expected.

**Non-functional Keys:**
| Key | Expected Action |
|-----|-----------------|
| Shift+F1 | Toggle start positions display |
| F4 | Toggle editor mode |
| Ctrl+F4 | Toggle debug info overlay |

**Related Files:**
- `client/src/controler.cpp` - Key handling
- `client/src/editor_task.cpp` - Editor mode

---

### 11. Bot Commands Cause Server Crashes
**Status:** Workaround Applied
**Description:** The F5 (addBot) and F6 (kick bot) commands cause the server to crash when executed during gameplay.

**Root Cause:** The bot system requires replay data and proper session state that isn't available during active gameplay.

**Workaround Applied:** Both commands are now blocked at the server level in `net_callbacks.cpp`. Users receive a message explaining the command is disabled.

**Files Modified:**
- `server/src/net_callbacks.cpp:180-191` - Added blocks for addBot and kick commands

---

### 12. Water Rendering Disabled
**Status:** Workaround Applied
**Description:** Water rendering is currently disabled because the required water textures or shaders are missing.

**Current Workaround:** Water task falls back gracefully when `water_light.shape` is missing.

---

### 13. ~~Snow Particles Not Loading on Some Systems~~ (FIXED)
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

### 14. Version Compatibility
**Status:** Ongoing
**Description:** The current build uses v1.2.2a source code. Some features from v1.5.19 are not available.

**Future Goal:** Port v1.5.19 features while maintaining stability, or create a compatibility layer.

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
