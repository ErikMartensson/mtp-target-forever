# MTP Target - Level Reference

This document lists all available levels, their scoring mechanics, and server scripts.

**Status:** 32 playable levels + 5 test levels (ReleaseLevel=0, excluded from counts)

**Testing Progress:** 32 verified working - All playable levels tested!

---

## Testing Status

### Tested & Verified Working (32 levels)

All 32 playable levels have been tested and confirmed working:

| Level | Notes |
|-------|-------|
| `level_all_on_one` | Fixed CRGBA alpha parameter issue. Single large target gameplay works. |
| `level_classic` | Standard three-tier target. Works correctly. |
| `level_classic_easy3` | Classic with flat targets. Works correctly. |
| `level_classic_easy4` | Classic with multiple targets. Works correctly. |
| `level_classic_fight` | Players can knock each other off. Works correctly. |
| `level_classic_flat` | Flat terrain variation. Works correctly. |
| `level_classic_flat_fight` | Flat fight variant. Works correctly. |
| `level_darts` | Fixed acceleration (0.001), visibility (dark gray platform), and scoring. Bots work correctly. |
| `level_dont_go_too_far` | Fixed slope steering, scoring zones (50/100/300), and target colors. |
| `level_donuts` | Fixed slope steering and spawn point positions. |
| `level_easy1` | Fixed slope steering. Similar to level_classic. |
| `level_easy2` | Fixed slope steering. Flat targets. |
| `level_easy3` | Fixed slope steering. Flat targets, offset. |
| `level_easy4` | Fixed slope steering. Multiple flat targets. |
| `level_extra_ball` | Fixed slope steering and fly-mode water respawn. Moving target + respawn gameplay. |
| `level_extra_ball2` | Fixed slope steering and fly-mode water respawn. Larger yellow target box. |
| `level_paint` | Fixed slope steering and module Lua loading. Territory claim gameplay works - first to touch claims block. |
| `level_snow_dual_ramp` | Dual ramp design. Works correctly. |
| `level_snow_fall` | Standard targets. Works correctly. |
| `level_snow_pyramid` | Fixed scoring with colored pyramid boxes. Z-offset collision works correctly. |
| `level_snow_reverse_pyramid` | Fixed slope steering and colored scoring boxes (green/blue/red). Inverted pyramid layout. |
| `level_snow_tube` | Standard targets. Works correctly. |
| `level_stairs` | Fixed scoring (Score=50) and friction. Progressive stair scoring with color gradient. |
| `level_stairs2` | Fixed scoring (Score=50) and friction. Narrower stair variant. |
| `level_team_90` | Fixed slope steering. 90-degree rotated team targets - steer sideways to land on your team's side. |
| `level_team_all_on_one` | Fixed Score and Friction on target. Team variant works. |
| `level_team_classic` | Team-based gameplay. Red/blue targets on your side. Fully working. |
| `level_team_mirror` | Fixed spawn direction and team scoring. Mirrored layout - your targets on enemy side. |
| `level_the_lane` | Lane/wall targets. Works correctly. |
| `level_the_wall` | Wall targets. Works correctly. |
| `level_wood` | Wood theme. Works correctly. |

### Known Issues (0 levels)

All playable levels are now working correctly.

### Test Levels (5 levels) - ReleaseLevel = 0

These levels have `ReleaseLevel = 0` and are excluded from normal rotation. They require manual testing via `/forcemap` or LevelPlaylist config.

| Level | Display Name | Server Script | Notes |
|-------|--------------|---------------|-------|
| `level_arena` | Arena | `level_arena_server.lua` | Standard targets. Not production-ready. |
| `level_hit_me` | Hit me | `level_hit_me_server.lua` | Entity collision mechanics. Not production-ready. |
| `level_race` | Race | `level_race_server.lua` | Racing focus. Not production-ready. |
| `level_run_away` | Run Away | `level_run_away_server.lua` | Evasion gameplay. Not production-ready. |
| `level_snow_funnel` | Snow funnel | `level_snow_funnel_server.lua` | Funnel terrain. Not production-ready. |

### Known Issues Fixed

| Issue | Affected Levels | Fix |
|-------|-----------------|-----|
| Missing CRGBA alpha parameter | `level_all_on_one`, `level_extra_ball2`, `level_pyramid_stairs`, `level_team_90`, `level_team_classic` | Added 4th parameter (255) to all CRGBA calls |
| Invisible accelerator platform | `level_darts` | Changed color from transparent to dark gray `CRGBA(28,28,28,255)` |
| No acceleration effect | `level_darts` | Added `Accel` property support in level.cpp, set to 0.001 |
| Module Lua crash | `level_darts` | Added direct `Accel`/`Bounce` property support in level files to avoid module Lua loading |
| Can't steer/accelerate on slope | `level_dont_go_too_far`, `level_donuts`, `level_easy1-4`, `level_extra_ball`, `level_extra_ball2`, `level_snow_reverse_pyramid`, `level_team_90` | Added `Bounce = 0, Accel = 0.0001` to snow_ramp modules |
| Missing scoring zones | `level_dont_go_too_far` | Added Score (50/100/300), Friction, and Color properties to target boxes |
| Spawn points too far forward | `level_donuts` | Moved StartPoints Y coordinate back ~1.2 units |
| Fly-mode water no respawn | `level_extra_ball`, `level_extra_ball2` | Fixed `entityWaterCollideEvent` to respawn in both ball and fly mode with `setIsOpen(0)` |
| Module Lua panic crash | `level_paint` and any level using module Lua | Fixed Lua 5.2+ compatibility in `module.cpp` - changed `lua_settable(L, LUA_GLOBALSINDEX)` to `lua_setglobal(L, "module")` |

---

## LevelPlaylist Config

Control which levels play and in what order via server config.

**Config file:** `build-server/bin/Release/mtp_target_service.cfg`

```cfg
// Single level on repeat (for testing)
LevelPlaylist = { "level_classic" };

// Multiple levels in specific order
LevelPlaylist = { "level_classic", "level_arena", "level_snow_funnel" };

// Empty = normal rotation using ReleaseLevel filter
LevelPlaylist = { };
```

**Notes:**
- LevelPlaylist overrides ReleaseLevel filter
- Uses substring matching (e.g., "classic" matches "level_classic")
- Levels play in the order specified

---

## Chat Commands

| Command | Description |
|---------|-------------|
| `/v <name>` | Vote for a level - shows immediate feedback |
| `/votemap <name>` | Vote for a level - shows immediate feedback |
| `/forcemap <name>` | Force next level (admin) - shows immediate feedback |
| `/forceend` | End current session (admin) |
| `/help` | Show available commands |

**Notes:**
- Commands are case-insensitive
- Level matching uses **substring search** on the filename
- Use unique substrings to avoid matching multiple levels
- Vote requires enough players to agree (1/3 + 1 of human players)
- Admin commands work immediately (everyone is admin by default in local play)

### Level Command Feedback

Both `/v` (vote) and `/forcemap` validate levels immediately and show feedback:

| Situation | Response |
|-----------|----------|
| Level found and valid | `Vote registered: Arena (level_arena.lua)` or `Next level: Arena (level_arena.lua)` |
| No matching level | `No level found matching 'xyz'` |
| Level invalid (e.g., wrong ReleaseLevel) | `Level level_xyz.lua is invalid: ReleaseLevel 0 not in allowed list` |

**Note:** Votes are only registered if the level is valid. Invalid votes are rejected with an error message.

---

## Level Details

### Standard Target Levels (15 levels)

These levels use classic scoring: land on colored targets (50/100/300 points).

| Level | Display Name | Server Script | Notes |
|-------|--------------|---------------|-------|
| `level_classic` | Snow classic | `level_classic_server.lua` | Classic three-tier target. |
| `level_classic_flat` | Snow classic flat | `level_classic_flat_server.lua` | Flat terrain variation. |
| `level_dont_go_too_far` | Dont go too far | `level_dont_go_too_far_server.lua` | Standard targets. |
| `level_donuts` | Give me the donuts | `level_donuts_server.lua` | Standard targets. |
| `level_snow_dual_ramp` | Snow dual ramp | `level_snow_dual_ramp_server.lua` | Dual ramp design. |
| `level_snow_fall` | Snow fall | `level_snow_fall_server.lua` | Standard targets. |
| `level_snow_tube` | Snow tube land | `level_snow_tube_server.lua` | Standard targets. |
| `level_the_lane` | The Lane | `level_default_server.lua` | Lane/wall targets. |
| `level_the_wall` | The Wall | `level_default_server.lua` | Wall targets. |
| `level_wood` | Wood | `level_wood_server.lua` | Wood theme. |
| `level_snow_pyramid` | Snow Pyramid | `level_default_server.lua` | **NEW** Pyramid of scoring boxes. |
| `level_snow_reverse_pyramid` | Snow Reverse Pyramid | `level_default_server.lua` | **NEW** Inverted pyramid. |
| `level_all_on_one` | All On One | `level_default_server.lua` | **NEW** Single large target. |
| `level_extra_ball2` | Extra Ball 2 | `level_extra_ball_server.lua` | **NEW** Same as Extra Ball - moving target with respawn. Larger yellow target box. |
| `level_pyramid_stairs` | Pyramid Stairs | `level_stairs_server.lua` | **NEW** Pyramid of stairs. |

### Easy Levels (8 levels)

Beginner-friendly levels with standard or flat targets.

| Level | Display Name | Server Script | Notes |
|-------|--------------|---------------|-------|
| `level_easy1` | Snow Easy 1 | `level_default_server.lua` | **NEW** Standard targets, easy layout. |
| `level_easy2` | Snow Easy 2 | `level_default_server.lua` | **NEW** Flat targets. |
| `level_easy3` | Snow Easy 3 | `level_default_server.lua` | **NEW** Flat targets, offset. |
| `level_easy4` | Snow Easy 4 | `level_default_server.lua` | **NEW** Multiple flat targets. |
| `level_classic_easy3` | Snow Classic Easy 3 | `level_default_server.lua` | **NEW** Classic with flat targets. |
| `level_classic_easy4` | Snow Classic Easy 4 | `level_default_server.lua` | **NEW** Classic with multiple targets. |
| `level_classic_flat_fight` | Snow Classic Flat Fight | `level_classic_fight_server.lua` | **NEW** Flat fight variant. |
| `level_classic_fight` | Snow Classic Fight | `level_classic_fight_server.lua` | Players can knock each other off. |

### Special Scoring Levels (4 levels)

These levels have unique scoring mechanics.

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_darts` | Snow darts | `level_darts_server.lua` | Any contact scores (no ball-form needed). |
| `level_extra_ball` | Extra ball | `level_extra_ball_server.lua` | **Moving target + respawn:** Single target that moves when hit. Players respawn immediately after landing/crashing for multiple attempts. Score accumulates across all successful landings. |
| `level_stairs` | Stairs | `level_stairs_server.lua` | **Progressive:** +50 per unique stair. |
| `level_stairs2` | Stairs 2 | `level_stairs_server.lua` | Different stair layout. |

### Paint/Claim Levels (1 level)

First player to land on a block claims it.

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_paint` | Paint | `level_paint_server.lua` | **Territory claim:** +100 per block claimed. |

### Team Levels (4 levels)

Team-based gameplay (simplified in v1.2.2a).

| Level | Display Name | Server Script | Notes |
|-------|--------------|---------------|-------|
| `level_team_all_on_one` | Team All on one | `level_team_all_on_one_server.lua` | Team variant - shared target. |
| `level_team_classic` | Team Classic | `level_team_server.lua` | Classic team with colored boxes. Your targets on your side. |
| `level_team_mirror` | Snow team mirror | `level_team_server.lua` | Mirrored - your targets on enemy side (harder). |
| `level_team_90` | Team 90 | `level_team_server.lua` | 90-degree rotated targets. Steer sideways to land on your team's side. |

---

## Server Script Reference

### Scripts with Custom Logic

| Script | Used By | Scoring Mechanism |
|--------|---------|-------------------|
| `level_default_server.lua` | Fallback for missing scripts | Standard: `entity:setCurrentScore(module:getScore())` when ball form + module has score. |
| `level_arena_server.lua` | level_arena | Standard targets (extends default). |
| `level_classic_fight_server.lua` | level_classic_fight | Standard targets + entity collision handling. |
| `level_classic_flat_server.lua` | level_classic_flat | Standard targets. |
| `level_darts_server.lua` | level_darts | Any contact scores (no ball-form requirement). |
| `level_extra_ball_server.lua` | level_extra_ball | Accumulating: `entity:setCurrentScore(module:getScore() + entity:getCurrentScore())`. Requires stopped velocity. |
| `level_gates_server.lua` | *(not used by any level)* | Gate passing: accumulate score, gate value decreases by 10 per pass. |
| `level_hit_me_server.lua` | level_hit_me | Standard targets. |
| `level_paint_server.lua` | level_paint | Territory claim: track claimed modules per entity, +100 per claim. |
| `level_race_server.lua` | level_race | Standard targets. |
| `level_run_away_server.lua` | level_run_away | Standard targets. |
| `level_snow_funnel_server.lua` | level_snow_funnel | Standard targets. |
| `level_stairs_server.lua` | level_stairs, level_stairs2 | Progressive: track visited modules per entity, +50 per unique stair. |
| `level_sun_extra_ball_server.lua` | *(not used by any level)* | Gate passing: accumulate score from gates. |
| `level_team_server.lua` | level_team, level_team_mirror | Standard targets (team mode simplified). |
| `level_bowls1_server.lua` | *(not used by any level)* | Distance-based: closer to center = higher score (max 400, min -200). |
| `level_city_paint_server.lua` | *(not used by any level)* | Territory claim for city theme. |

### All Server Scripts Available

All 37 levels have their server scripts in `data/lua/`. Scripts that don't exist fall back to `level_default_server.lua`.

---

## Unavailable Levels (30 levels)

These levels exist in `mtp-target-src/` but are not yet converted. They require:
- **Space theme assets** (space ramps, asteroids, hangars)
- **Sun theme assets** (sun ramps, sun islands)
- **City theme assets** (city buildings, city ramps)
- **Gate mechanics** (gate scoring system)

| Theme | Levels |
|-------|--------|
| Space | `level_space_asteroids`, `level_space_atomium`, `level_space_calbren`, `level_space_cargo_inside`, `level_space_fleet`, `level_space_hangar18`, `level_space_havoc`, `level_space_hotwings`, `level_space_imo_rings`, `level_space_stabilo`, `level_space_test`, `level_team_space` |
| Sun | `level_sun_cross`, `level_sun_extra_ball`, `level_sun_paint`, `level_sun_shrinker`, `level_sun_target`, `level_sun_test`, `level_snow_line` |
| City | `level_city_darts`, `level_city_destroy`, `level_city_easy`, `level_city_paint`, `level_city_precision`, `level_city_test` |
| Gates | `level_gates_easy`, `level_gates_hard`, `level_gates_ramp`, `level_gates_zig_zag` |
| Other | `level_bowls1`, `level_donuts2`, `level_mtp_paint`, `level_physics_test` |

---

## How Scoring Works

### Standard Scoring (most levels)

```lua
function entitySceneCollideEvent(entity, module)
    module:collide(entity)
end

function Module:collide(entity)
    if entity:getIsOpen() == 0 and self:getScore() ~= 0 then
        entity:setCurrentScore(self:getScore())
    end
end
```

**Rules:**
- Must be in ball form (`getIsOpen() == 0`)
- Module must have a score value set
- Last touched scoring module determines your score
- Score finalizes when velocity drops below 0.03

### Accumulating Scoring (extra_ball, gates)

```lua
function Module:collide(entity)
    if entity:getIsOpen() == 0 and self:getScore() > 0 then
        entity:setCurrentScore(self:getScore() + entity:getCurrentScore())
    end
end
```

**Rules:**
- Score adds to current total
- Water collision typically resets to 0

### Progressive Scoring (stairs)

```lua
local entityProgress = {}

function Module:collide(entity)
    local name = entity:getName()
    if entityProgress[name][moduleId] == nil then
        entityProgress[name][moduleId] = true
        entity:setCurrentScore(entity:getCurrentScore() + 50)
    end
end
```

**Rules:**
- Each unique module can only be scored once per entity
- Progress tracked per-entity

### Territory Claim (paint)

```lua
local claimedModules = {}

function Module:collide(entity)
    if claimedModules[moduleId] == nil then
        claimedModules[moduleId] = entityName
        entity:setCurrentScore(entity:getCurrentScore() + 100)
    end
end
```

**Rules:**
- First to land claims the module
- Only the claimant scores from that module

---

## Ambiguous Names

Some short names match multiple levels. Use longer strings to be specific:

| Short Name | Matches |
|------------|---------|
| `classic` | level_classic, level_classic_easy3, level_classic_easy4, level_classic_fight, level_classic_flat, level_classic_flat_fight |
| `easy` | level_easy1, level_easy2, level_easy3, level_easy4, level_classic_easy3, level_classic_easy4 |
| `team` | level_team, level_team_90, level_team_all_on_one, level_team_classic, level_team_mirror |
| `stairs` | level_stairs, level_stairs2, level_pyramid_stairs |
| `pyramid` | level_snow_pyramid, level_snow_reverse_pyramid, level_pyramid_stairs |
| `extra` | level_extra_ball, level_extra_ball2 |

---

## Level Files

Levels are stored in `data/level/*.lua` (32 playable + 5 test levels). Each level file defines:
- `Name` - Display name shown in game
- `Author` - Level creator
- `Theme` - Visual theme (snow, city, sun, etc.)
- `ServerLua` - Server-side script for game logic
- `Modules` - 3D objects and platforms

Server scripts are in `data/lua/*_server.lua` and handle:
- Scoring logic via `entitySceneCollideEvent()`
- Friction settings via `levelInit()`
- Special game modes

---

## Debugging Levels

### Check Which Script a Level Uses

```bash
grep "ServerLua" data/level/level_NAME.lua
```

### Check if Script Exists

```bash
ls data/lua/level_NAME_server.lua
```

If missing, the level falls back to `level_default_server.lua`.

### Watch Server Logs

```bash
tail -f mtp_target_service.log
```

Look for Lua errors when a level loads.

### Force a Specific Level

```
/forcemap NAME
```

---

## Adding Custom Levels

To add a custom level:
1. Create a `.lua` file in `data/level/`
2. Define required fields (Name, Theme, Modules)
3. Set `ServerLua` to your custom script or use `level_default_server.lua`
4. Create a `*_server.lua` script for custom scoring logic
5. Restart the server to load the new level

### Minimal Server Script Template

```lua
function Entity:init()
    self:setCurrentScore(0)
end

function Entity:preUpdate()
end

function Entity:update()
end

function entitySceneCollideEvent(entity, module)
    module:collide(entity)
end

function entityEntityCollideEvent(entity1, entity2)
end

function entityWaterCollideEvent(entity)
end

function Module:collide(entity)
    if entity:getIsOpen() == 0 and self:getScore() ~= 0 then
        entity:setCurrentScore(self:getScore())
    end
end
```
