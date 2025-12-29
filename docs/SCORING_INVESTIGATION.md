# Scoring System - FULLY FIXED (Dec 29, 2025)

This document describes how the scoring system works and the fixes that were applied.

---

## Status: WORKING ✓

Players and bots now correctly:
- Slow down on target platforms (friction=25)
- Score points (50/100/300) when landing in ball form
- Get bonus points for fast arrivals
- Get placement bonuses (1st/2nd/3rd)

---

## How Scoring Works

### 1. Level Initialization

When a level loads, `levelInit()` is called from C++. This sets friction and scores on modules:

```lua
function levelInit()
    for i = 0, getModuleCount() - 1 do
        local m = getModule(i)
        local name = m:getName()

        if name == "snow_target_50" or name == "snow_target_100" or name == "snow_target_300" then
            m:setFriction(25.0)  -- High friction to slow penguins
            m:setScore(tonumber(string.match(name, "%d+")))  -- 50, 100, or 300
        end
    end
end
```

### 2. Collision Detection

When a player/bot collides with a module, C++ calls the global function `entitySceneCollideEvent()`:

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

### 3. Score Finalization

From [server/src/running_session_state.cpp](../server/src/running_session_state.cpp):
- Score locks when velocity drops below `MinVelBeforeEnd = 0.03`
- Bonus points if ArrivalTime > 11 seconds
- Additional bonus for placement (1st/2nd/3rd)

---

## Root Causes (What Was Wrong)

### Issue 1: `nlinfo()` Not Registered

v1.5.19 scripts used `nlinfo()` for logging, but v1.2.2a doesn't register this function. Scripts crashed immediately.

**Fix:** Removed all `nlinfo()` calls.

### Issue 2: Wrong Lua API

v1.5.19 expects C++ to call entity methods directly:
```lua
-- v1.5.19 (WRONG for v1.2.2a)
function CEntity:collideWithModule(module)
    self:setCurrentScore(module:score())
end
```

v1.2.2a calls global functions instead:
```lua
-- v1.2.2a (CORRECT)
function entitySceneCollideEvent(entity, module)
    module:collide(entity)
end
```

### Issue 3: Wrong Method Names

| v1.5.19 | v1.2.2a |
|---------|---------|
| `m:name()` | `m:getName()` |
| `m:score()` | `m:getScore()` |
| `self:isOpen()` | `self:getIsOpen()` |
| `self:currentScore()` | `self:getCurrentScore()` |
| `self:meanVelocity()` | `self:getMeanVelocity()` |
| `self:startPointPos()` | `self:getStartPointPos()` |

---

## Available Lua API (v1.2.2a)

### Global Functions
- `getModuleCount()` - number of modules
- `getModule(i)` - get module at index
- `getEntityCount()` - number of entities
- `getEntity(i)` - get entity at index
- `entitySceneCollideEvent(entity, module)` - called on collision
- `entityWaterCollideEvent(entity)` - called on water collision
- `entityEntityCollideEvent(e1, e2)` - called on entity collision

### Module Methods (CModuleProxy)
- `getName()` - get module name
- `getScore()` / `setScore(n)` - score value
- `setFriction(f)` - friction value
- `setAccel(a)` - acceleration value
- `getPos()` / `setPos(v)` - position
- `setEnabled(0/1)` - enable/disable

### Entity Methods (CEntityProxy)
- `getName()` - entity name
- `getIsOpen()` - 0=ball, 1=gliding
- `getCurrentScore()` / `setCurrentScore(n)` - score
- `getPos()` / `setPos(v)` - position
- `getMeanVelocity()` - average velocity
- `getStartPointPos()` - starting position
- `displayText(x,y,scale,r,g,b,text,duration)` - show text

---

## Fixed Files

### Completely Rewritten (v1.2.2a API) ✓
- `level_classic_fight_server.lua` - Full collision API
- `level_default_server.lua` - Full collision API
- `level_arena_server.lua` - Uses default collision
- `level_classic_flat_server.lua` - Uses default collision
- `level_hit_me_server.lua` - Uses default collision
- `level_run_away_server.lua` - Uses default collision
- `level_snow_funnel_server.lua` - Uses default collision

### All Server Scripts Converted (Dec 29, 2025) ✓
- `level_bowls1_server.lua` - Distance-based scoring from center target
- `level_city_paint_server.lua` - Claim buildings for points (team mode simplified)
- `level_darts_server.lua` - Standard target scoring
- `level_extra_ball_server.lua` - Accumulate score from targets
- `level_gates_server.lua` - Pass through gates for points
- `level_paint_server.lua` - Claim blocks for points (team mode simplified)
- `level_stairs_server.lua` - 50 points per unique stair step
- `level_sun_extra_ball_server.lua` - Pass through gates for points
- `level_team_server.lua` - Standard scoring (team mode simplified)

**Note:** Team mode and advanced features (texture changes, respawn mechanics) are simplified due to v1.2.2a API limitations. Core scoring functionality works.

---

## Key Source Files

- [server/src/lua_engine.cpp](../server/src/lua_engine.cpp) - Lua API registration, calls `entitySceneCollideEvent()`
- [server/src/entity.cpp:319-321](../server/src/entity.cpp#L319-L321) - Iterates `collideModules` and calls Lua
- [server/src/physics.cpp:280-298](../server/src/physics.cpp#L280-L298) - Adds modules to `collideModules` set
- [server/src/module_lua_proxy.cpp](../server/src/module_lua_proxy.cpp) - Module Lua bindings
- [server/src/entity_lua_proxy.cpp](../server/src/entity_lua_proxy.cpp) - Entity Lua bindings
- [server/src/running_session_state.cpp](../server/src/running_session_state.cpp) - Score finalization

---

## Note: Level Loader Limitation

The level loader in [server/src/level.cpp](../server/src/level.cpp) does NOT read Score or Friction from level files. These must be set via Lua's `levelInit()` function. This is by design in v1.2.2a.
