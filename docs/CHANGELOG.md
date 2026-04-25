# Changelog

All notable improvements and changes from the original MTP Target v1.2.2a.

## Gate Trigger Volume + Visual Sync (April 25, 2026)

### Fix: Gates scored on frame hits and near-misses; visible gate didn't move when AABB teleported (KI #20)

Two combined bugs in the gate-collision system on `level_sun_extra_ball` (and the four `level_gates_*` levels): the trigger volume was 14×3×14 — many times larger than the actual visible opening — so brushing the frame or flying past close enough triggered a score. Compounding this, `CGateProxy:setPosition` only updated the level-load entry table (a no-op on a loaded level) so the visible gate mesh never actually moved when the AABB teleported, making bouncing-the-frame yield repeated +300 hits as the invisible AABB landed in the bouncer's trajectory.

**Fix:**
- `CGateProxy:setPosition` now also calls the runtime `Module:setPos(pos)`, which moves the ODE physics geom and broadcasts `UpdateElement` to clients so the rendered mesh re-renders at the new position
- Added explicit `OpeningHalfExtents = CVector(0.05, 0.05, 0.05)` to the gate table (default for `addGatePS` and `addGate90PS`, override per-gate via `CGateProxy:setOpeningHalfExtents`); `_isInsideGateAABB` uses it instead of the legacy `Scale/2`

**Deployment trap also discovered:** stale shadow copies of `helpers.lua`, `level_bowls1_server.lua`, and `level_team_server.lua` at `build-server/bin/data/` (root) were being loaded by the server's `CPath::lookup` ahead of the canonical `data/lua/` versions. Multiple iterations of the AABB fix appeared to have no effect for this reason. Shadows have been overwritten to match — a cleanup pass to delete them outright is worth doing.

**Files changed:** `data/lua/utilities.lua`, `data/lua/helpers.lua`

---

## Live Scoreboard Updates (April 25, 2026)

### Fix: Scoreboard didn't update mid-round and showed stale scores from previous round (KI #17b/c)

The Tab scoreboard never updated during a round on cumulative-scoring levels (`level_gates_*`, `level_sun_extra_ball`, `level_donuts2`), and at the start of each new round it still displayed the previous round's final score. Standard-scoring levels (e.g. `level_classic`) appeared to work only because rounds end quickly there.

**Root cause:** `EndSession` (sent at round-end) was the only server→client message carrying score data. Cumulative levels run the full timer, so the client never learned about scoring during the round, and the previous round's `EndSession` value lingered on the scoreboard until the next one arrived.

**Fix:** Added a new lightweight `ScoreUpdate` network message that carries `(eid, currentScore)` pairs. The server broadcasts it from its existing 50 Hz network tick whenever an entity's `CurrentScore` differs from a new `LastSentScore` field — catching every writer (Lua proxy, physics resets, end-of-round bonuses, per-round `Entity:init` resets) via comparison rather than setter wrapping. Per-round reset propagation is automatic.

**Files changed:** `common/net_message.h`, `server/src/entity.h`, `server/src/entity.cpp`, `server/src/network.cpp`, `client/src/net_callbacks.cpp`

### Polish: Bottom-right HUD score now shows current round score

The bottom-right corner used to show `totalScore` (cumulative session total), which was both easy to confuse with the Tab scoreboard's per-round `score` column and rarely the number players cared about mid-round. Switched to `currentScore` so the HUD ticks up live per scoring event. The session total is still visible in the Tab scoreboard's `total` column.

**File changed:** `client/src/hud_task.cpp`

---

## Sun-Themed Level Polish (April 25, 2026)

### Fix: Snow particles on sun-themed gates levels (KI #19)

The four `level_gates_*` levels (easy, hard, ramp, zig_zag) are sun-themed but rendered snow particles because the client's theme detection in `client/src/level.cpp` matches by filename prefix and only knew about `level_space_`, `level_city_`, and `level_sun_`.

**Fix:** Added `ShowSnow = 0` to each gates level's Lua file (the existing per-level opt-out, used previously by `level_mtp_paint.lua`). No client rebuild required.

**Files changed:** `data/level/level_gates_easy.lua`, `data/level/level_gates_hard.lua`, `data/level/level_gates_ramp.lua`, `data/level/level_gates_zig_zag.lua`

### Fix: i18n keys leaking to HUD on level_sun_extra_ball (KI #17a)

`level_sun_extra_ball` displayed garbled text like `LEVELEXTRALANDED|TESTER` and `LEVELEXTRABALL` on the HUD because the server-side script emitted raw localization keys that have no lookup table in this codebase.

**Fix:** Replaced the keys with literal English strings — broadcast text now reads `<name> got an extra ball!` and the local message reads `Extra ball!`.

**File changed:** `data/lua/level_sun_extra_ball_server.lua`

---

## Auto-Reset Camera on Round Start (February 24, 2026)

### Fix: Camera stays on spectated player after round ends

When spectating another player with F9/F10 after crashing or landing, the camera would remain on that player when the next round started. Players wouldn't notice until after the countdown, losing valuable positioning time.

**Root cause:** The existing `resetFollowedEntity()` call in `loadNewSession()` fired early (during session loading), but could be overridden if the player pressed F9/F10 during the waiting period before the countdown began.

**Fix:** Added a `resetFollowedEntity()` call in `everybodyReady()`, which fires when the countdown starts. This ensures the camera snaps back to the player's own penguin right as the "3... 2... 1..." countdown begins, regardless of who they were spectating. F9/F10 spectating still works normally during gameplay.

**File changed:** `client/src/mtp_target.cpp`

---

## Level Info Text and Space Texture Fix (February 23, 2026)

### Feature: Display level info text during countdown

Ported the v1.5.19 level info text feature. Levels can now display contextual hints during the countdown phase (e.g., "You can open your wings more than once on this level"). Text is rendered centered on screen at 40% height in yellow, using the BigTextContext TrueType renderer with MiddleTop hot spot for pixel-perfect centering.

- Added `Info` field to client `CLevel` class, read from Lua global
- Added `CFontManager::printfCentered()` using `UTextContext::MiddleTop` hot spot
- Added info text lookup table in `utilities.lua` (replacing v1.5.19's CI18N localization)
- Renders during countdown in `hud_task.cpp`

**Files changed:** `client/src/level.h`, `client/src/level.cpp`, `client/src/font_manager.h`, `client/src/font_manager.cpp`, `client/src/hud_task.cpp`, `data/lua/utilities.lua`

### Fix: Missing textures on space crate targets

Space levels with crate-style targets (cargo_inside, fleet, hangar18, etc.) showed pink/white checker patterns instead of the correct crate textures. The `addSpaceTarget` helper was setting texture layer 0 to `"space_crate"` but the actual texture file is `space_target_crate.dds`.

**Fix:** Changed texture prefix in `addSpaceTarget` from `"space_"` to `"space_target_"` to match the actual filenames.

**File changed:** `data/lua/utilities_space.lua`

---

## WASD + Space Alternative Controls (February 22, 2026)

Added WASD and Space as always-on alternative controls alongside the existing arrow keys and Ctrl:

- **W/A/S/D** — alternative to arrow keys for movement, steering, and gliding
- **Space** — alternative to Ctrl for toggling wings open/closed

Works in all gameplay modes (rolling, flying, free-look camera). All alternative keys are automatically disabled when chat is open (Enter to toggle), so typing is unaffected. Space key events are always consumed to prevent buffered presses from triggering open/close after sending a chat message.

**File changed:** `client/src/controler.cpp`

---

## Paint Level and Bot Replay Fixes (February 22, 2026)

### Fix: level_paint friction and painting broken

The `level_paint` level had two issues: zero friction on the platform (ball slid right off) and paint blocks never changing color when rolled over.

**Root causes:**
1. **Friction overwrite:** The v1.5.19 compatibility code in `level.cpp` applied C++ property overrides (Friction=0 from the level definition) *after* `module_paint_bloc.lua` had already set Friction=10.0, zeroing it out.
2. **Painting broken:** Three separate issues:
   - `level_paint_server.lua` used v1.5.19-style function aliases (`module()`, `moduleCount()`, `entityById()`, `level()`) that are only defined by `utilities.lua`, which isn't loaded for v1.2.2a-style levels
   - `module_paint_bloc.lua` overwrote the `CModulePaintBloc` class from the ServerLua script with an incompatible version (different method names: `postUdate` vs `postUpdate`)
   - `loadModuleLuaScript()` overwrote the global `module` variable (aliased to `getModule()`) with the CModuleProxy for each paint_bloc, breaking `CLevel:postUpdate()`'s `module(i)` calls
   - The `setColor` calls used wrong client API format (`CRGBA()` object instead of 4 separate numbers)

**Fix:**
- Split `CModule::_luaInit()` so module Lua scripts load *after* C++ property overrides, giving module scripts the last word on friction/accel/etc.
- Save/restore the `module` global around module Lua script loading to preserve the `getModule()` alias
- Added missing function aliases to `level_paint_server.lua` (bridge functions normally provided by `utilities.lua`)
- Fixed `setColor` client API calls in `level_paint_server.lua` to use correct 4-number format
- Guarded `CModulePaintBloc` definition in `module_paint_bloc.lua` to not overwrite the ServerLua version
- Fixed method name typos in the fallback definition (`postUdate` -> `postUpdate`, `finalScore` -> `updateScore`)

**Files changed:**
- `server/src/module.cpp` / `.h` - Split `_luaInit()` into proxy creation + `loadModuleLuaScript()` with global save/restore
- `server/src/level.cpp` - Call `loadModuleLuaScript()` after C++ property overrides
- `data/lua/level_paint_server.lua` - Added function aliases, fixed client API calls
- `data/module/module_paint_bloc.lua` - Guarded class definition, fixed method names

### Fix: Bots loading wrong level replays (regression)

Bots were loading replay files from other levels whose names contained the current level name as a substring. For example, level "Paint" would match "City Paint" replay files, causing bots to follow nonsensical paths.

**Root cause:** `bot.cpp` used `string::find()` for replay file matching, which does substring matching. `"City Paint.4.000.mtr".find("Paint")` succeeds because "Paint" appears within "City Paint".

**Fix:** Changed to exact prefix matching on the filename — replay files must START with the level name followed by a period.

**Files changed:**
- `server/src/bot.cpp` - Use `CFile::getFilename()` + prefix match (`find() == 0`) instead of substring match

---

## Camera Improvements (February 22, 2026)

### Initial camera pitch and free-look mouse mode

Two camera improvements to address spawn visibility and mouse control:

**Default downward camera pitch:**
- Camera now starts tilted ~17 degrees downward (0.3 radians) when spawning, so players can see down ramps instead of looking straight into ramp geometry
- Previously the camera started at horizon level, which on most levels put it inside the starting ramp/slope. Snow ramps were transparent from inside but city ramps blocked the entire view with gray
- Levels can override this default via `CameraPitch` in their Lua file (e.g., `CameraPitch = 0.0` for flat levels)

**New mouse mode 4 (now default):**
- Camera always tracks mouse movement without holding left-click
- Hold left-click to lock the camera in place (inverted from old behavior)
- Previous default (mode 2) required holding left-click to look around, which was unintuitive for new players
- Old mouse modes (1-3) still available via `AllowMouse` config setting

**Files changed:**
- `client/src/mouse_listener.cpp` / `.h` - Added mode 4, default pitch on reset
- `client/src/level.cpp` / `.h` - Read optional `CameraPitch` from level Lua
- `client/src/mtp_target.cpp` - Apply per-level camera pitch after level load
- `client/mtp_target_default.cfg`, `data/config/mtp_target_default.cfg` - Default AllowMouse changed to 4

---

## City Paint Texture Preloading (February 21, 2026)

### Fix: Loading screen interruption during city_paint gameplay

When playing `level_city_paint`, the first time any player touched a platform, the paint mechanic changed the module's texture (from `city_building_orange` to `city_building_ocre` or `city_building_blue`). Since these textures weren't loaded during level init, the client triggered a download/resource fetch mid-gameplay, showing a "Please wait while downloading" GUI that interrupted the player's view for up to 1 second.

**Root cause:** The paint server script (`level_city_paint_server.lua`) uses `execLuaOnAllClient(...:setTexture(...))` to dynamically change module textures during gameplay. The textures `city_building_ocre`, `city_building_blue`, and `empty` aren't referenced by any module at level load time (everything starts as `city_building_orange`), so they aren't fetched until first use.

**Fix:**
- `client/src/module.cpp` — Changed `CModule::setTexture()` to try `CPath::lookup()` first for instant local file resolution. Only falls back to `CResourceManager::get()` (which involves CRC checks and network round-trips) if the file isn't found locally. This prevents the loading dialog from appearing for any locally available texture.
- Added `PreloadTextures` level table support to the client level loader (`client/src/level.cpp`). Levels can declare textures to preload during level initialization, ensuring they're fetched before gameplay starts (useful for textures that need to be downloaded from a remote server).
- Added `PreloadTextures = { "city_building_ocre", "city_building_blue", "empty" }` to `level_city_paint.lua`.

---

## Darts Level Scoring Fix (February 21, 2026)

### Fix: level_city_darts always scoring 0 points

The darts level has a long flat runway (`snow_box`) that launches players toward a platform with street sign targets on poles. Players fly off the runway and crash into sign faces for points. ODE's sphere-trimesh collision detection unreliably detects the thin sign meshes — the entity sphere stops on the platform surface (`city_target_zero`, score=0) instead of registering a hit on the sign above it.

**Root cause:** ODE sphere-trimesh collision misses thin sign meshes. Server logs confirmed that entities nearly always collide with only `city_target_zero` (the platform, score=0), even when visually hitting a sign face dead-on. The thin sign trimeshes are occasionally detected (giving correct scores), but most hits land on the larger platform mesh underneath.

**Fixes applied:**
- `data/lua/level_darts_server.lua` — Added Z-height-gated proximity fallback. When an entity collides with a score-0 module (the platform), the script checks if the entity is elevated above the platform surface (Z > 0.03 above the module). If so, it finds the closest scoring module by XY distance and awards that score. This distinguishes sign-face hits (entity elevated at sign height, Z ~0.12 above platform) from empty platform hits (entity at platform level, Z ~0.01 above). Direct hits on scoring sign meshes (when ODE does detect them) still use the module's own score.
- `server/src/physics.cpp` — Crash-in-fly `CurrentScore = 0` reset now only fires on the first crash frame (moved inside `if(!FreezeCommand)` guard). Previously it fired every frame, wiping the score set by the Lua callback.
- `server/src/level.cpp` — Now reads the `Collide` property from the Lua Modules table (alongside Score, Friction, Accel, Bounce). Allows levels to explicitly disable module collision.
- `data/lua/helpers.lua` — Ultimate fallback scoring uses higher-score-wins logic.

**Known limitation:** The very bottom edge of the smallest/lowest sign may occasionally not register a score, because the entity's Z height at that point is barely above the platform threshold.

---

## Modern Text Input (February 9, 2026)

### Full Text Editing for GUI Fields and Chat

Added clipboard, selection, and word navigation support to all text input fields (IP address, username, password, chat). Both the GUI text field system (`CGuiText`) and chat input (`CChatTask`) now use a shared `CTextEditor` class.

**New editing features:**
- **Ctrl+C / Ctrl+X / Ctrl+V** - Copy, cut, paste via system clipboard (uses NeL's `UDriver` clipboard API)
- **Ctrl+Z** - Undo last edit (supports multiple undo levels)
- **Shift+Arrow keys** - Select text character by character
- **Ctrl+Left/Right** - Jump to word boundaries
- **Ctrl+Shift+Left/Right** - Select by word
- **Home / End** - Jump to start/end of text
- **Shift+Home / Shift+End** - Select to start/end
- **Ctrl+A** - Select all
- **Ctrl+Backspace** - Delete previous word
- **Delete** - Delete character forward (also works with selection)
- **Tab / Shift+Tab** - Jump between input fields (IP, username, password)
- **Enter** - Submit login form from any text field (both online and LAN login)
- **Visual selection highlight** - Selected text shown with semi-transparent blue background in both GUI fields and chat
- **Select-all on focus** - Clicking into a GUI text field selects all existing text for easy replacement
- **Blinking cursor** - Visible cursor position in chat input

**Use cases enabled:**
- Paste a server IP address into the connection field
- Press Enter to connect after typing credentials (no need to click Login button)
- Tab through fields, type credentials, press Enter — fully keyboard-driven login
- Select and copy/cut text in any input field
- Quick word-level navigation and deletion
- Standard PC text editing muscle memory works everywhere

**Files added:**
- `client/src/text_editor.h` - CTextEditor class declaration
- `client/src/text_editor.cpp` - Text editing state machine (cursor, selection, clipboard, word nav)

**Files modified:**
- `client/src/gui_text.h/cpp` - Integrated CTextEditor for GUI text fields, selection rendering, Tab navigation
- `client/src/chat_task.h/cpp` - Integrated CTextEditor for chat input, cursor and selection rendering
- `client/src/intro_task.cpp` - Enter key triggers login from any focused text field
- `client/src/font_manager.h/cpp` - Added `littleStringWidth()` for text measurement
- `client/src/CMakeLists.txt` - Added text_editor source files

---

## Team Level Improvements (February 9, 2026)

### Six Fixes for Team-Based Levels

Fixed multiple issues with team levels (`level_team_90`, `level_team_classic`, `level_team_mirror`, `level_team_all_on_one`):

**1. Random Team Assignment**
Players were always assigned to the red team first because the team assignment algorithm picked team 0 when pack sizes were tied. Now collects all tied candidates and randomly selects one.

**2. Consistent & Balanced Team Distribution**
The `getTeam()` function was called once per entity, but recomputed all team assignments from scratch each time using `rand()`. Since `rand()` state advanced between calls, assignments could be inconsistent and unbalanced. Fixed by computing team assignments once per session and caching them. All subsequent `getTeam()` calls return the cached result.

**3. Bots Don't Use Wrong-Side Replays**
On split-ramp team levels, bots assigned to the blue side would load replay files recorded from the red side, causing them to fly the wrong direction. Added distance-based validation: fallback replays whose first position is >5 units from the bot's starting point are discarded.

**4. Team Score Text No Longer Persists to Non-Team Levels**
The red/blue score counter in the top-left stayed visible when transitioning from a team level to a non-team level. Root cause: off-by-one bug in `levelEndSession()` — the loop `for i=0,entityCount do` went one past the last entity, causing a Lua error that prevented the `displayTextToAll` cleanup lines from executing. Fixed loop bound to `entityCount-1`.

**5. Score Reset Bug in level_team_all_on_one**
Team scores were being overwritten with 0 when collisions stopped (same bug previously fixed in `level_team_server.lua`). Applied the `scoringHappenedThisFrame` guard and added missing cleanup lines.

**6. Blue Team 50-Point Platform Color**
The blue team's outermost (50-point) scoring platform was pure white `CRGBA(255,255,255,255)` while the red team's was tinted `CRGBA(255,128,128,255)`. Changed blue 50-point platforms to `CRGBA(128,128,255,255)` in all three split-ramp team levels.

**Files Modified:**
- `server/src/entity_manager.h` - Added team assignment cache
- `server/src/entity_manager.cpp` - Cache team assignments, randomize tied selection
- `server/src/bot.cpp` - Distance-based replay validation for fallback replays
- `data/lua/level_team_server.lua` - Fix off-by-one in `levelEndSession()` loop
- `data/lua/level_team_all_on_one_server.lua` - Fix off-by-one, add cleanup, add scoring fix
- `data/level/level_team_90.lua` - Blue 50-point platform color
- `data/level/level_team_classic.lua` - Blue 50-point platform color
- `data/level/level_team_mirror.lua` - Blue 50-point platform color

### Other Improvements

**level_team_all_on_one ServerLua fix:** Level was pointing to `level_team_server.lua` instead of `level_team_all_on_one_server.lua`, causing incorrect "Land on RED/BLUE target" text on a single shared target.

**level_team_space platform visibility:** Client-side `CModule:new()` was undefined, causing `CLevel:init()` to error out after the first module. Added client-side stub in `data/lua/utilities.lua` so all platforms render correctly.

**Post-build client data copying:** Level and Lua utility files were only copied to the server build directory, not the client. Added level and Lua copying to the client section of `scripts/post-build.bat`.

**Chat smiley codes:** Updated `ReplaceStringByImage` config from 4 broken entries (wrong `.tga` extension) to all 28 smiley codes from v1.5.19 with correct `.dds` extensions.

---

## Intermittent Scoring Failure Fix (February 8, 2026)

### Root Cause Identified and Fixed

Fixed the game-breaking bug where players intermittently received 0 points when landing on scoring targets. The bug was unpredictable - scoring worked for 10+ rounds, then failed for 1-2 rounds, then worked again.

**Root Cause:** The Lunar template's userdata caching with weak table garbage collection. When `Lunar::push()` reused cached userdata from the weak "v" table, it wasn't re-applying the metatable. If the cached userdata's metatable became stale after GC, `entity.collideWithModule` returned nil because the method lookup failed.

**Why player-player collision "primed" the fix:** The `entityEntityCollideEvent()` function exercised `Lunar::push()` first, warming the cache or triggering GC at a safe point.

**Fix Applied:**
- Modified `common/lunar.h` to ALWAYS set metatable in `Lunar::push()`, not just for new userdata
- Added silent debug counters in `data/lua/helpers.lua` to track method lookup success/failure
- Added metatable verification diagnostic in `server/src/lua_engine.cpp` (DEBUG builds only)

**Files Modified:**
- `common/lunar.h` - Always re-apply metatable after pushuserdata
- `data/lua/helpers.lua` - Debug counters: `_dbg_collideWithModule_nil`, etc.
- `server/src/lua_engine.cpp` - DEBUG-only metatable integrity check

---

## v1.5.19 Multi-Theme Level Restoration

### 28 New Playable Levels Across 4 Themes

Ported all remaining levels from v1.5.19 by building a Lua compatibility bridge between the v1.5.19 imperative `CLevel:init()` architecture and our v1.2.2a static global-table level loader.

**Space Theme (10 levels):**
- `level_space_asteroids`, `level_space_fleet` (ReleaseLevel 6 - highest quality)
- `level_space_atomium`, `level_space_calbren`, `level_space_cargo_inside`
- `level_space_hangar18`, `level_space_havoc`, `level_space_hotwings`
- `level_space_imo_rings`, `level_space_stabilo`

**Sun Theme (4 levels):**
- `level_sun_target`, `level_sun_cross`, `level_sun_extra_ball`, `level_sun_paint`

**City Theme (5 levels):**
- `level_city_easy`, `level_city_darts`, `level_city_paint`
- `level_city_destroy`, `level_city_precision`

**Gate Levels (4 levels) - New Game Mode:**
- `level_gates_easy`, `level_gates_hard`, `level_gates_ramp`, `level_gates_zig_zag`
- Fly through scoring gates that decrease in value each pass
- Pure Lua AABB gate collision detection (no C++ gate system needed)

**Other (5 levels):**
- `level_bowls1` - Distance-based scoring (closer to center = more points)
- `level_donuts2` - Second donuts variant
- `level_mtp_paint` - Alternative paint level
- `level_snow_line` - Snow line layout
- `level_team_space` - Team mode in space theme

### Engine-Level Fixes

- **Default friction for scoring targets** - Modules with `Score > 0` but `Friction == 0` now automatically get friction of 10 applied during level loading (`server/src/level.cpp`). In v1.5.19, the server applied friction to scoring targets; without this fix, balls roll across city/space targets without slowing down. Fixes `level_city_easy`, `level_city_darts`, `level_city_precision`, and all space target levels.
- **Main loop reordering for postUpdate scoring** - Moved `CSessionManager::update()` to run AFTER `levelPostUpdate()` in the server main loop (`server/src/main.cpp`). Levels like `level_city_paint` use per-frame score recalculation: `CEntity:preUpdate()` resets score to 0, then `CLevel:postUpdate()` recalculates it from painted modules. Previously, the session manager read `CurrentScore` between these two steps, always seeing 0. This fix ensures scores are fully calculated before the session manager checks arrival times and end conditions.
- **Negative score support** - Fixed `setCurrentScore` in `server/src/entity_lua_proxy.cpp` to cast `lua_Number` to `sint32` instead of `uint32`. The bowls1 level uses negative scores for distance-based penalties, which would underflow to large positive numbers with the unsigned cast.

### Bot Replay Fix

- **Added missing `Name` to all v1.5.19 levels** - 31 ported levels were missing the `Name` global variable. The bot replay system (`server/src/bot.cpp`) matches replay files by level name. When `Name` was empty, `string::find("")` matched every replay file, causing bots to load replay data from wrong levels and behave erratically. Added `Name = "Display Name"` to all 31 affected level files.

### Server-Side Lua Fixes

- **Gate AABB collision bug fix** - Fixed CLuaVector property access in gate collision detection (`helpers.lua`). Changed `.x`/`.y`/`.z` property access to `:getX()`/`:getY()`/`:getZ()` method calls, since CLuaVector is a userdata type that only supports methods.
- **userData transfer for city_paint** - Added userData transfer logic in `levelInit()` (`helpers.lua`). During `CLevel:init()`, Lua stores custom objects (e.g., CModulePaintBloc) on CLevelModule proxies via `setUserData()`. Since the C++ CModuleProxy objects are created *after* init, the userData must be explicitly copied from Lua table entries to the corresponding CModuleProxy objects.
- **`level():teamMode()` implementation** - Added team mode detection in `utilities.lua` that checks if any entity name starts with `[` (bracket prefix indicates team assignment). Used by `level_city_paint_server.lua` for team-based territory claiming.
- **Entity/Module class name bridging** - v1.5.19 server scripts define methods on `CEntity`/`CModule`/`CLevel`, but the Lunar template registers these as `Entity`/`Module`/`Level`. Bridged via aliases (`CEntity = Entity`, etc.) in `utilities.lua`, which is loaded on both client and server as part of the level file's include chain.
- **Paint level server script update** - Replaced v1.2.2a `level_paint_server.lua` with v1.5.19 version that includes `CModulePaintBloc` class definition. The old version lacked this class, causing crashes on `level_sun_paint` and `level_mtp_paint`.
- **level_team_space fix** - Changed `CModuleBase:new(team)` calls to `CModule:new(module, team)` to use the class defined in `level_team_server.lua`.
- **CVector decimal point fix** - Fixed `utilities_sun.lua` where `CVector(-15, -50, 3,5)` had a comma instead of decimal point for 3.5.

### Lua Compatibility Layer

Created a multi-layered bridge for v1.5.19 level scripts:

- **`data/lua/utilities.lua`** - CLevel Lua shim that translates `CLevel:init()` calls into global tables our C++ reads. Includes CLevel methods (`addModule`, `addStartPoint`, `addCamera`, `setWater`, `setSky`, `setFog`, `setSun`, `addGate`), module proxy with `setTexture`/`setScale`/`setScore`/etc., and CGateProxy class.
- **Theme utilities** (`utilities_snow.lua`, `utilities_space.lua`, `utilities_sun.lua`, `utilities_city.lua`) - Theme-specific helpers for water, sky, fog, sun lighting, and material properties.
- **`data/lua/helpers.lua`** - Server-side bridge loaded before level files. Provides collision event routing that supports both v1.2.2a global function style and v1.5.19 entity method style. Includes gate AABB collision detection, level update bridges, and entity lifecycle hooks.
- **v1.5.19 naming aliases** - `CEntity = Entity`, method aliases (`currentScore`, `name`, `position`, etc.), function aliases (`module`, `moduleCount`, `entityById`, `timeRemaining`).

### C++ Changes for Level Compatibility

- **CLevel:init() support** (client + server `level.cpp`) - After loading a level file, check for and call `CLevel:init()` to trigger v1.5.19-style level setup
- **Module texture support** (client `level.cpp` + `module.cpp`) - Read `Texture0`/`Texture1` fields from Modules table and apply to loaded shapes
- **Module proxy setTexture** (client `module_lua_proxy.cpp`) - Added `setTexture(layer, name)` method for runtime texture changes via `execLuaOnAllClient`
- **CLuaVector methods** (common `lua_nel.h`/`lua_nel.cpp`) - Added `getX`/`getY`/`getZ`/`setX`/`setY`/`setZ` methods used by v1.5.19 scripts
- **include() function** (common `lua_utility.cpp`) - Lua `include()` function using `CPath::lookup` for cross-directory script loading
- **nlinfo/nlwarning** (common `lua_utility.cpp`) - Registered as Lua functions for v1.5.19 server scripts
- **moduleById alias** (client `level.cpp`) - Registered `moduleById` as alias for `getModuleById`

---

## v1.5.19 Feature Ports

### Music Controls
- **F5** - Pause/resume music playback
- **F6** - Previous track
- **Shift+F7** - Next track

### Replay Playback Controls
Full replay playback control when viewing `.mtr` replay files:
- **Home** - Restart replay from beginning
- **Z** - Toggle pause/resume
- **S** (hold) - Slow down playback
- **X** (hold) - Speed up playback
- **A/E** (hold) - Slow speed (-0.1x / +0.1x)
- **Q/D** (hold) - Medium speed (-3x / +3x)
- **W/C** (hold) - Fast speed (-6x / +6x)

Added `speedTime()` and `getSpeedTime()` methods to `CTimeTask` for time speed control.

### External Camera Task (Picture-in-Picture)
Spectator camera view rendered as a picture-in-picture window:
- **Alt+A** - Toggle external camera on/off
- **Entity-following mode** - Automatically tracks nearest player within 10m who is above you
- **Fixed position mode** - Uses level-defined `ExternalCameras` positions
- Auto-enables on collision/landing, auto-disables on session end
- **Sky scene rendering** - PIP window shows sky background correctly (v1.5.19 parity)
- **Scaled player names** - Names render 4x larger in PIP for readability (v1.5.19 parity)
- **Runtime-configurable viewport** - CVariable support for adjusting PIP position/size via console commands (x1/y1/w1/h1 for viewport, x2/y2/w2/h2 for border, sc for name scale, DistToFollowInExternalCam for entity tracking distance)

New files: `client/src/external_camera_task.h`, `client/src/external_camera_task.cpp`

### Graph Visualization (Debug Display)
Performance graphs for debugging and network analysis:
- **F4** - Cycle through debug display modes (0=off, 1=debug info, 2=graphs, 3=trace)
- Graphs include: FPS, MSPF (ms per frame), ping, packet timing, LCT, key count
- Each graph shows current values, mean line, and peak line
- Semi-transparent overlays with auto-scaling

New files: `client/src/graph.h`, `client/src/graph.cpp`

### Gate System (C++)
Native C++ gate objects for gate-mode levels:
- **`addGate()`** - Lua function to create gates at runtime
- **`gateById(id)`** / **`getGateById(id)`** - Retrieve gate by ID
- Gate properties: position, scale, score
- Lua proxy with `getUserData`/`setUserData` for custom data storage
- Visual mesh instance using col_box.shape

New files: `client/src/gate.h`, `client/src/gate.cpp`, `client/src/gate_lua_proxy.h`, `client/src/gate_lua_proxy.cpp`

---

## Client Improvements

### Options Menu (New)
In-game options accessible from both main menu and pause menu:
- **Resolution selection** - Cycle through available display modes (left-click forward, right-click backward)
- **Fullscreen toggle** - Switch between windowed and fullscreen modes
- **VSync toggle** - Enable/disable vertical sync
- **Particles toggle** - Enable/disable snow particle effects (requires restart)
- **Music volume slider** - Adjust background music volume (0-100%)
- **Sound volume slider** - Adjust sound effects volume (0-100%)
- Volume changes apply immediately without restart
- Video settings from main menu auto-restart the game when Apply is clicked
- Video settings from pause menu require manual restart (to avoid disconnecting from server)

### Pause Menu (New)
Press **Escape** during gameplay to access the pause menu:
- **Resume** - Return to gameplay
- **Options** - Access video and audio settings mid-game
- **Disconnect** - Return to main menu (cleanly disconnects from server)
- **Quit Game** - Exit the application

### Disconnect/Reconnect Flow (Fixed)
- Fixed crashes when disconnecting and reconnecting to servers
- Proper cleanup of game tasks, entities, and GUI elements
- Error dialogs now have OK button and can be dismissed with Escape key

### Aspect Ratio Fix
- Fixed stretched display on widescreen monitors (16:9, 21:9, etc.)
- Game was originally designed for 4:3 and hardcoded `1.33f` aspect ratio
- Camera perspective now calculates aspect ratio from actual screen dimensions
- Main menu background, logo, and dartboard now scale correctly without stretching

### Sound Effects (Fixed)
All game sound effects now working:
- **Countdown sounds** (0-5) - Play during session countdown
- **Open sound** - Plays when transitioning to fly mode (wings open)
- **Close sound** - Plays when transitioning to ball mode (wings close)
- **Impact sound** - Plays when crashing while flying
- **Splash sound** - Plays when entering water (client-side detection)

Sound features:
- **Distance-based volume** - Other players' sounds attenuate with distance
- **User volume scaling** - All sounds respect the Sound Volume slider
- **Local player priority** - Your own sounds always play at full volume

### HUD Speed Display
- Added speedometer to bottom-right corner of HUD (above score)
- Shows current speed as an integer value (scaled x100 for readability)
- Color-coded acceleration feedback:
  - **Green** - Accelerating
  - **Red** - Decelerating
  - **White** - Stable speed
- Uses dual exponential moving average (EMA) for smooth display

### Keyboard Controls Fix
- Fixed arrow keys being captured by chat input during gameplay
- Implemented chat toggle mode:
  - Press **Enter** to activate chat input
  - Type message and press **Enter** to send
  - Arrow keys now properly control penguin steering during gameplay

### Chat Scrolling
- **End** key - Jump to bottom and resume auto-scroll for new messages

### Command-Line Arguments
- `--lan <host>` - Auto-connect to a LAN server
- `--user <name>` - Set player name for auto-connect
- Example: `mtp-target-forever.exe --lan localhost --user Player1`

### Right-Click Support
- Added right-click detection to GUI button system
- Used for cycling backwards through resolution options

## Physics Improvements

### Momentum Preservation
- Fixed momentum loss at ramp transitions
- Changed ODE contact mode from `dContactMu2` to `dContactApprox1` in physics.cpp
- Players now maintain speed when transitioning between surfaces

### Slope Steering
- Fixed inability to steer or accelerate on starting slopes
- Solution: Add explicit properties to slope modules:
  ```lua
  { Lua="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 }
  ```

## Server Improvements

### Level System
- All 32 playable snow/antarctic theme levels working
- All 4 team levels working with proper scoring
- Score/Friction/Accel/Bounce properties loaded from level Lua files
- Lua 5.2+ compatibility for module scripts

### Configuration
- `LevelPlaylist` config option for testing specific levels
- Network tick rate increased from 25Hz to 50Hz

### Level Announcements
- Chat message broadcast when each level starts: `Now playing: <DisplayName> (<filename.lua>)`
- Helps identify levels for debugging and provides history in chat log

### Command Handling Fix
- Fixed server crash when players type unknown commands like `/forcelevel`
- Root cause: NeL's `isCommand()` only checks if string starts with lowercase, not if command exists
- Fix: Proper NULL check in command.cpp before dereferencing ICommand pointer
- Fix: Use `getCommand() != NULL` check in net_callbacks.cpp instead of misleading `isCommand()`
- Unknown commands now correctly return "Unknown command" error instead of crashing

## Build System

### Windows Build
- CMake 3.5+ compatibility
- MySQL made optional (login service uses SQLite)
- Fixed library linking order and dependencies
- Added build scripts: `scripts/build-client.bat`, `scripts/build-server.bat`
- Post-build script copies data files to build directories

### Source Modernization
- Lua 5.0 to 5.x compatibility layer (`common/lua_compat.h`)
- Updated NeL API calls for modern Ryzom Core
- Fixed C++11 compatibility issues (NL_I64 literal spacing)
- Added NLMISC namespace qualifiers where needed

## Files Changed (Summary)

### New Files
- `client/data/gui/options.xml` - Options menu layout
- `client/data/gui/pause_menu.xml` - Pause menu layout
- `client/src/options_menu.cpp/h` - Shared options menu class (used by intro and game tasks)
- `data/sound/DFN/*.dfn` - Sound definition schemas for NeL sound system
- `data/sound/soundbank/*.sound` - Sound sheet definitions (countdown, effects)
- `data/sound/samplebank/sound/*.wav` - Audio sample files
- `data/lua/utilities.lua` - CLevel Lua compatibility shim for v1.5.19 levels
- `data/lua/utilities_snow.lua` - Snow theme utilities
- `data/lua/utilities_space.lua` - Space theme utilities
- `data/lua/utilities_sun.lua` - Sun theme utilities
- `data/lua/utilities_city.lua` - City theme utilities
- `data/lua/helpers.lua` - Server-side bridge for collision events and gate detection
- `data/level/level_space_*.lua` (12 files) - Space theme levels
- `data/level/level_sun_*.lua` (6 files) - Sun theme levels
- `data/level/level_city_*.lua` (6 files) - City theme levels
- `data/level/level_gates_*.lua` (4 files) - Gate mode levels
- `data/level/level_bowls1.lua`, `level_donuts2.lua`, `level_mtp_paint.lua`, `level_snow_line.lua` - Other new levels
- `docs/CHANGELOG.md` - This file
- `common/lua_compat.h` - Lua compatibility macros
- `scripts/*.bat` - Build and run scripts

### Client Source
- `client/src/intro_task.cpp/h` - Main menu, options integration via IOptionsMenuCallback
- `client/src/game_task.cpp/h` - Pause menu, options integration via IOptionsMenuCallback
- `client/src/mtp_target.cpp` - Disconnect/reconnect flow fixes
- `client/src/entity_manager.cpp/h` - Added removeAll() for clean reconnection
- `client/src/hud_task.cpp/h` - Speed display
- `client/src/chat_task.cpp/h` - Chat toggle mode
- `client/src/3d_task.cpp` - Aspect ratio fix
- `client/src/sky_task.cpp` - Aspect ratio fix (sky camera)
- `client/src/background_task.cpp` - Menu background scaling
- `client/src/gui_button.cpp/h` - Right-click support
- `client/src/gui_mouse_listener.cpp/h` - Right-click detection
- `client/src/sound_manager.cpp/h` - Volume control, sound playback, gain/relative mode
- `client/src/entity.cpp/h` - Client-side water detection, distance-based sound volume
- `client/src/level.cpp` - CLevel:init() call, texture support, moduleById alias
- `client/src/module.cpp` - Runtime texture application from level Lua
- `client/src/module_lua_proxy.cpp` - Added setTexture method for client module proxy

### Common Source
- `common/lua_nel.h` - Added CLuaVector getX/getY/getZ/setX/setY/setZ declarations
- `common/lua_nel.cpp` - Added CLuaVector accessor implementations
- `common/lua_utility.cpp` - include() function, nlinfo/nlwarning registration

### Server Source
- `server/src/physics.cpp` - Momentum preservation fix
- `server/src/module.cpp` - Lua 5.2+ compatibility
- `server/src/level.cpp` - Property loading, CLevel:init() call, default friction for scoring modules
- `server/src/main.cpp` - Reordered update loop: session manager now runs after levelPostUpdate
- `server/src/command.cpp` - NULL check fix for unknown commands
- `server/src/net_callbacks.cpp` - Proper command existence validation

## Version Strategy

This fork targets **v1.2.2a** compatibility for both client and server. The `reference/mtp-target-v1.5.19/` directory contains the last official client release for comparison and asset extraction.
