# MTP Target - Level Reference

This document lists all available levels, their scoring mechanics, and server scripts.

---

## Chat Commands

| Command | Description |
|---------|-------------|
| `/v <name>` | Vote for a level (shortcut) |
| `/votemap <name>` | Vote for a level |
| `/forcemap <name>` | Force next level (admin) |
| `/forceend` | End current session (admin) |
| `/help` | Show available commands |

**Notes:**
- Commands are case-insensitive
- Level matching uses **substring search** on the filename
- Use unique substrings to avoid matching multiple levels
- Vote requires enough players to agree (1/3 + 1 of human players)
- Admin commands work immediately (everyone is admin by default in local play)

---

## Level Details

### Standard Target Levels

These levels use classic scoring: land on colored targets (50/100/300 points).

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_arena` | Arena | `level_arena_server.lua` | Standard targets. Land in ball form on snow_target_50/100/300 for points. Friction=25 on targets. |
| `level_classic` | Snow classic | `level_classic_server.lua` *(missing, uses default)* | Standard targets. |
| `level_classic_flat` | Snow classic flat | `level_classic_flat_server.lua` | Standard targets. Flat terrain variation. |
| `level_dont_go_too_far` | Dont go too far | *(missing, uses default)* | Standard targets. |
| `level_donuts` | Give me the donuts | *(missing, uses default)* | Standard targets. |
| `level_snow_dual_ramp` | Snow funnel | *(missing, uses default)* | Standard targets. Dual ramp design. |
| `level_snow_fall` | Snow fall | *(missing, uses default)* | Standard targets. |
| `level_snow_funnel` | Snow funnel | `level_snow_funnel_server.lua` | Standard targets. Funnel terrain. |
| `level_snow_tube` | Snow tube land | *(missing, uses default)* | Standard targets. |
| `level_the_lane` | The Lan | `level_default_server.lua` | Standard targets. |
| `level_the_wall` | The Wall | `level_default_server.lua` | Standard targets. |
| `level_wood` | Wood | *(missing, uses default)* | Standard targets. Wood theme. |

### Special Scoring Levels

These levels have unique scoring mechanics.

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_classic_fight` | Snow classic Fight | `level_classic_fight_server.lua` | Standard targets + entity collision. Players can knock each other off. |
| `level_darts` | Snow darts | `level_darts_server.lua` | Score from any module contact (even while gliding). Target score = module score value. |
| `level_extra_ball` | Extra ball | `level_extra_ball_server.lua` | **Accumulating score.** Each target adds to total. Must be stopped (velocity < 0.03) to score. Water resets score to 0. |
| `level_hit_me` | Hit me | `level_hit_me_server.lua` | Standard targets. Entity collision enabled. |
| `level_race` | Race | `level_race_server.lua` | Standard targets. Racing focus. |
| `level_run_away` | Run Away | `level_run_away_server.lua` | Standard targets. Evasion gameplay. |
| `level_stairs` | Stairs | `level_stairs_server.lua` | **Progressive scoring.** +50 points per unique stair module touched. Water resets progress. |
| `level_stairs2` | Stairs 2 | `level_stairs_server.lua` | Same as Stairs. Different layout. |

### Paint/Claim Levels

First player to land on a block claims it.

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_paint` | Paint | `level_paint_server.lua` | **Territory claim.** +100 points per unique block claimed. First to land claims it. Score resets each frame, recalculated from claimed blocks. |

### Team Levels

Team-based gameplay (simplified in v1.2.2a - team mode not fully supported).

| Level | Display Name | Server Script | Scoring |
|-------|--------------|---------------|---------|
| `level_team` | Snow team | `level_team_server.lua` | Standard targets. Originally team scoring (your team's targets = positive, enemy = negative). Simplified to basic scoring in v1.2.2a. |
| `level_team_all_on_one` | Team All on one | *(missing, uses default)* | Standard targets. Team variant. |
| `level_team_mirror` | Snow team mirror | `level_team_server.lua` | Same as Snow team. Mirrored layout. |

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

### Missing Scripts (Fall Back to Default)

These levels reference scripts that don't exist - they use `level_default_server.lua`:
- `level_classic_server.lua`
- `level_dont_go_too_far_server.lua`
- `level_donuts_server.lua`
- `level_snow_dual_ramp_server.lua`
- `level_snow_fall_server.lua`
- `level_snow_tube_server.lua`
- `level_team_all_on_one_server.lua`
- `level_wood_server.lua`

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
| `classic` | level_classic, level_classic_fight, level_classic_flat |
| `team` | level_team, level_team_all_on_one, level_team_mirror |
| `stairs` | level_stairs, level_stairs2 |
| `funnel` | level_snow_funnel, level_snow_dual_ramp |

---

## Level Files

Levels are stored in `data/level/*.lua`. Each level file defines:
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
