# MTP Target Forever - Level Reference

Single source of truth for level testing status, scoring mechanics, and reference data.

**Total:** 70 level files (60 playable + 10 test). Use this checklist to track which levels have been verified, when, and any open issues.

---

## Testing Workflow

```bash
# 1. Pick a ❓ level from the table below
# 2. Launch with the playlist tooling (no need to edit any .cfg):
scripts\run-server.bat -p level_space_hangar18
# 3. In another terminal:
scripts\run-client.bat --lan localhost --user tester
# 4. Play 2-3 rounds. Update the row in this file:
#    - Status emoji
#    - Last Tested = today's date (YYYY-MM-DD)
#    - If broken: file an entry in docs/KNOWN_ISSUES.md, reference its number here
# 5. Commit just the doc update — small, focused commits
```

See [Playlist Tooling](#playlist-tooling) below for all the ways to launch.

**Status legend:**
- ✅ Working - Verified playable, no known issues
- ⚠️ Has known issue - Playable but bugged; see Issue Ref
- 🚫 Broken - Not playable, blocking issue
- ❓ Untested - Loads in theory but no human verification yet
- ⏭ Test-only - `ReleaseLevel = 0/20/200`, excluded from rotation

---

## Unified Checklist (70 levels)

### Snow / Original (33 levels)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_all_on_one`             | snow  | ✅     | 2026-02-04  | —         | Single large target gameplay                    |
| `level_classic`                | snow  | ✅     | 2026-02-04  | —         | Standard three-tier target                      |
| `level_classic_easy3`          | snow  | ✅     | 2026-02-04  | —         | Classic with flat targets                       |
| `level_classic_easy4`          | snow  | ✅     | 2026-02-04  | —         | Classic with multiple targets                   |
| `level_classic_fight`          | snow  | ✅     | 2026-02-04  | —         | Players can knock each other off                |
| `level_classic_flat`           | snow  | ✅     | 2026-02-04  | —         | Flat terrain variation                          |
| `level_classic_flat_fight`     | snow  | ✅     | 2026-02-04  | —         | Flat fight variant                              |
| `level_darts`                  | snow  | ✅     | 2026-02-04  | —         | Acceleration platform, dark gray visibility    |
| `level_dont_go_too_far`        | snow  | ✅     | 2026-02-04  | —         | Three scoring zones (50/100/300)               |
| `level_donuts`                 | snow  | ✅     | 2026-02-04  | —         | Standard targets                                |
| `level_easy1`                  | snow  | ✅     | 2026-02-04  | —         | Standard targets, easy layout                  |
| `level_easy2`                  | snow  | ✅     | 2026-02-04  | —         | Flat targets                                    |
| `level_easy3`                  | snow  | ✅     | 2026-02-04  | —         | Flat targets, offset                            |
| `level_easy4`                  | snow  | ✅     | 2026-02-04  | —         | Multiple flat targets                           |
| `level_extra_ball`             | snow  | ✅     | 2026-02-04  | —         | Moving target + respawn gameplay                |
| `level_extra_ball2`            | snow  | ✅     | 2026-02-04  | —         | Larger yellow target box                        |
| `level_paint`                  | snow  | ✅     | 2026-02-04  | —         | Territory claim, +100 per block                 |
| `level_pyramid_stairs`         | snow  | ✅     | 2026-02-04  | —         | Pyramid of stairs                               |
| `level_snow_dual_ramp`         | snow  | ✅     | 2026-02-04  | —         | Dual ramp design                                |
| `level_snow_fall`              | snow  | ✅     | 2026-02-04  | —         | Standard targets                                |
| `level_snow_pyramid`           | snow  | ✅     | 2026-02-04  | —         | Z-offset collision works correctly              |
| `level_snow_reverse_pyramid`   | snow  | ✅     | 2026-02-04  | —         | Inverted pyramid layout                         |
| `level_snow_tube`              | snow  | ✅     | 2026-02-04  | —         | Standard targets                                |
| `level_stairs`                 | snow  | ✅     | 2026-02-04  | —         | Progressive +50 per unique stair                |
| `level_stairs2`                | snow  | ✅     | 2026-02-04  | —         | Narrower stair variant                          |
| `level_team_90`                | team  | ✅     | 2026-02-09  | —         | 90° rotated team targets                        |
| `level_team_all_on_one`        | team  | ✅     | 2026-02-09  | —         | Shared target both teams                        |
| `level_team_classic`           | team  | ✅     | 2026-02-09  | —         | Classic team with colored boxes                 |
| `level_team_mirror`            | team  | ✅     | 2026-02-09  | —         | Mirrored - your targets on enemy side          |
| `level_team_space`             | team  | ✅     | 2026-02-09  | —         | Team variant with wider platform spacing (snow theme — "space" = gaps, not visual theme) |
| `level_the_lane`               | snow  | ✅     | 2026-02-04  | —         | Lane/wall targets                               |
| `level_the_wall`               | snow  | ✅     | 2026-02-04  | —         | Wall targets                                    |
| `level_wood`                   | wood  | ✅     | 2026-02-04  | —         | Wood theme                                      |

### Space Theme (10 ports + 1 test)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_space_asteroids`        | space | ✅     | 2026-02-04  | —         | Asteroid targets, advanced. Maybe too fast.    |
| `level_space_atomium`          | space | ✅     | 2026-04-24  | —         | Atomium structure targets. Bots active (replays saved). |
| `level_space_calbren`          | space | ✅     | 2026-04-24  | —         | Planet targets                                  |
| `level_space_cargo_inside`     | space | ✅     | 2026-04-24  | —         | Indoor space station                            |
| `level_space_fleet`            | space | ✅     | 2026-04-25  | —         | Crate targets on cargo ships (ship hulls are decorative cushions) |
| `level_space_hangar18`         | space | ✅     | 2026-04-25  | —         | Hangar targets                                  |
| `level_space_havoc`            | space | ⚠️     | 2026-04-25  | KI #16    | Asteroid field. Bots once seen infinite-bouncing on ship interior (low pri). |
| `level_space_hotwings`         | space | ✅     | 2026-04-25  | —         | Planet targets                                  |
| `level_space_imo_rings`        | space | ✅     | 2026-04-25  | —         | Ring targets                                    |
| `level_space_stabilo`          | space | ✅     | 2026-04-25  | —         | Planet targets                                  |
| `level_space_test`             | space | ⏭      | —           | —         | ReleaseLevel=20, test only                      |

### Sun Theme (4 ports + 2 test)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_sun_target`             | sun   | ✅     | 2026-02-04  | —         | Standard sun targets                            |
| `level_sun_cross`              | sun   | ✅     | 2026-04-25  | —         | Cross pattern layout                            |
| `level_sun_extra_ball`         | sun   | ⚠️     | 2026-04-25  | KI #17    | Gate scoring works but: i18n keys leak to HUD, no live scoreboard updates, score persists into next round |
| `level_sun_paint`              | sun   | ✅     | 2026-04-25  | —         | Territory claim. Fixed math.mod→% Lua 5.1. Minor Z-fighting between overlapping grid cells (cosmetic). |
| `level_sun_shrinker`           | sun   | ⏭      | —           | —         | ReleaseLevel=0, modules shrink over time       |
| `level_sun_test`               | sun   | ⏭      | —           | —         | ReleaseLevel=200, test only                     |

### City Theme (5 ports + 1 test)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_city_easy`              | city  | ✅     | 2026-02-04  | —         | Standard city targets                           |
| `level_city_darts`             | city  | ✅     | 2026-02-04  | —         | Z-height-gated proximity scoring                |
| `level_city_paint`             | city  | ✅     | 2026-02-21  | —         | Painting + texture preloading fixed             |
| `level_city_destroy`           | city  | ⚠️     | 2026-04-25  | KI #18    | Playable. 50 + 100 targets work; 300 target unlandable due to ~25° tilt (upstream geometry, kept as-is). |
| `level_city_precision`         | city  | ✅     | 2026-04-25  | —         | Precision landing                               |
| `level_city_test`              | city  | ⏭      | —           | —         | ReleaseLevel=200, test only                     |

### Gate Levels (4 ports)

Fly through scoring gates that decrease in value each pass.

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_gates_easy`             | gates | ⚠️     | 2026-04-25  | KI #17, #19 | Playable, gate scoring works. Same family bugs: persistent score (KI #17c) + snow particles (KI #19). |
| `level_gates_hard`             | gates | ⚠️     | 2026-04-25  | KI #17, #19 | Playable. Gate scoring works mechanically. Score persists across rounds (KI #17c). Snow particles on sun theme (KI #19). Balance: final landing platform out-scores running all gates. |
| `level_gates_ramp`             | gates | ⚠️     | 2026-04-25  | KI #17, #19 | Playable, gate scoring works. Same family bugs: persistent score (KI #17c) + snow particles (KI #19). |
| `level_gates_zig_zag`          | gates | ⚠️     | 2026-04-25  | KI #17, #19 | Playable, gate scoring works. Same family bugs: persistent score (KI #17c) + snow particles (KI #19). |

### Other New Ports (4 + 1 test)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_bowls1`                 | other | ⚠️     | 2026-02-08  | KI #1     | Intermittent scoring failure (fix in testing)  |
| `level_donuts2`                | snow  | ⚠️     | 2026-04-25  | KI #17    | Playable. Score persists into next round (KI #17c). Note: requires opening wings 2× per round, suggesting the persistent-score bug correlates with non-standard round-end conditions, not just CEntity init style. |
| `level_mtp_paint`              | sun   | ⚠️     | 2026-04-25  | KI #17    | Playable. Score persists into next round (KI #17c). Sun themed; uses ShowSnow=0 in Lua to suppress snow particles. |
| `level_snow_line`              | snow  | ✅     | 2026-04-25  | —         | Snow line layout                                |
| `level_physics_test`           | other | ⏭      | —           | —         | ReleaseLevel=200, test only                     |

### Test-Only / Unfinished (5 levels, ReleaseLevel = 0)

| Level                          | Theme | Status | Last Tested | Issue Ref | Notes                                           |
|--------------------------------|-------|--------|-------------|-----------|-------------------------------------------------|
| `level_arena`                  | snow  | ⏭      | —           | —         | Standard targets, not production-ready          |
| `level_hit_me`                 | snow  | ⏭      | —           | —         | Entity collision mechanics                      |
| `level_race`                   | snow  | ⏭      | —           | —         | Racing focus, not production-ready              |
| `level_run_away`               | snow  | ⏭      | —           | —         | Evasion gameplay                                |
| `level_snow_funnel`            | snow  | ⏭      | —           | —         | Funnel terrain                                  |

### Summary

| Status | Count |
|--------|-------|
| ✅ Working | 50 |
| ⚠️ Has known issue | 10 |
| 🚫 Broken | 0 |
| ❓ Untested | 0 |
| ⏭ Test-only | 10 |
| **Total** | **70** |

---

## Playlist Tooling

The server's `LevelPlaylist` setting controls which levels play and in what order. Editing `mtp_target_service.cfg` directly is fragile because the server reformats it on each run. The tooling below sidesteps that by regenerating the .cfg from a template every time.

### Quick reference

```bash
# Single level
scripts\run-server.bat -p level_space_hangar18

# Inline comma-separated playlist (no spaces)
scripts\run-server.bat -p level_space_fleet,level_space_atomium,level_space_calbren

# Named preset (file in scripts/playlists/)
scripts\run-server.bat -p space-untested

# Re-run last session's playlist
scripts\run-server.bat -p last

# Normal rotation (uses ReleaseLevel filter, ignores playlist)
scripts\run-server.bat
```

### Named presets

Named presets live in `scripts/playlists/<name>.txt` — one level name per line, `#` for comments. They're version-controlled, so improvements you make benefit everyone.

Starter presets:
- `space-untested` - The 9 untested space levels
- `sun-untested` - The 3 untested sun levels
- `city-untested` - The 2 untested city levels
- `gates-untested` - The 3 untested gates levels
- `regression` - Sample of tricky levels to retest after engine changes
- `paint-levels` - All paint/territory variants in one batch

Add your own: drop a `.txt` file in `scripts/playlists/`. To use ad-hoc on the fly, use the comma-separated form (`-p a,b,c`) — no file needed.

### How it works

`scripts/set-playlist.ps1` resolves the `-p` argument, reads `server/mtp_target_service_default.cfg`, replaces the `LevelPlaylist = {...}` block, and writes the result to `build-server/bin/mtp_target_service.cfg`. The server then reads that file as normal.

The script also writes the resolved playlist to `scripts/playlists/last-session.txt` so you can replay with `-p last`.

---

## LevelPlaylist Config (manual editing, if needed)

If you want to set up a long-running playlist by hand, edit `server/mtp_target_service_default.cfg` (the template — survives across runs):

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
- The runtime file at `build-server/bin/mtp_target_service.cfg` gets reformatted by the server. Edit the template instead.

---

## Chat Commands

See [CHAT.md](CHAT.md) for the full chat reference.

**Quick reference:** `/v <name>` to vote, `/forcemap <name>` to force (admin), `/forceend` to end session (admin).

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

### Progressive Scoring (stairs)

Each unique module can only be scored once per entity; +50 per new stair.

### Territory Claim (paint)

First entity to land on a module claims it; +100 per claim.

### Distance-Based (bowls1)

Closer to center = higher score (max 400, min -200). Negative scores supported.

---

## Team Levels

Team-based gameplay. Players are split into red and blue teams; team members share a combined score.

**Team Assignment:**
- By default, players are randomly and evenly distributed each round.
- Force grouping with a **team tag** in brackets (e.g., `[A]Alice`, `[A]Bob` end up on the same team).

**Team Scoring (split-ramp levels):**
- Landing on your team's target: **positive** points
- Landing on the enemy team's target: **negative** points
- Color-coded: red team = red/salmon platforms, blue team = blue platforms
- Each side has 3 platforms: 50 (large/outer), 100 (medium), 300 (small/center)

---

## Server Script Reference

Server scripts in `data/lua/*_server.lua` define scoring per level. Levels reference their script via `ServerLua = "..."` (or fall back to `level_default_server.lua`).

| Script                              | Used By                              | Mechanism                                       |
|-------------------------------------|--------------------------------------|-------------------------------------------------|
| `level_default_server.lua`          | Fallback                             | Standard target scoring                         |
| `level_classic_fight_server.lua`    | classic_fight, classic_flat_fight    | Standard + entity collision handling           |
| `level_darts_server.lua`            | darts                                | Any contact scores (no ball-form required)     |
| `level_extra_ball_server.lua`       | extra_ball, extra_ball2              | Accumulating + stop-velocity check             |
| `level_gates_server.lua`            | gates_*                              | Gate passing, value decreases per pass         |
| `level_paint_server.lua`            | paint, sun_paint, mtp_paint          | Territory claim                                 |
| `level_city_paint_server.lua`       | city_paint                           | Territory claim, city-themed                   |
| `level_stairs_server.lua`           | stairs, stairs2                      | Progressive, +50 per unique stair              |
| `level_team_server.lua`             | team_classic, team_mirror, team_90   | Team scoring with negative for enemy targets   |
| `level_team_all_on_one_server.lua`  | team_all_on_one                      | Shared-target team variant                     |
| `level_bowls1_server.lua`           | bowls1                               | Distance-based scoring                          |
| `level_sun_extra_ball_server.lua`   | sun_extra_ball                       | Gate passing for sun theme                     |

---

## Level File Format

Levels are Lua files in `data/level/*.lua`. Required globals:

```lua
Name         = "Display Name"
Author       = "Creator"
ReleaseLevel = 1   -- 1-6 = playable, 0/20/200 = test-only
ServerLua    = "level_custom_server.lua"  -- optional
CameraPitch  = 0.6  -- optional, default 0.6 rad

Modules = {
    { Position = CVector(0, 0, 0),
      Rotation = CAngleAxis(0, 0, 1, 0),
      Scale    = CVector(1, 1, 1),
      Color    = CRGBA(255, 255, 255, 255),
      Lua      = "module_name",
      Shape    = "shape_name",
      Score    = 100,
      Friction = 1,
      Accel    = 0,
      Bounce   = 0,
      Collide  = 1     -- default 1
    },
}

StartPoints = {
    { Position = CVector(0, 10, 5), Rotation = 0 },
}
```

---

## Adding Custom Levels

1. Create a `.lua` file in `data/level/`
2. Define required fields
3. Set `ServerLua` to your custom script or use `level_default_server.lua`
4. Restart the server (`scripts\run-server.bat`) to load the new level
5. Add a row to the [Unified Checklist](#unified-checklist-70-levels)

### Minimal Server Script Template

```lua
function Entity:init() self:setCurrentScore(0) end
function Entity:preUpdate() end
function Entity:update() end

function entitySceneCollideEvent(entity, module) module:collide(entity) end
function entityEntityCollideEvent(entity1, entity2) end
function entityWaterCollideEvent(entity) end

function Module:collide(entity)
    if entity:getIsOpen() == 0 and self:getScore() ~= 0 then
        entity:setCurrentScore(self:getScore())
    end
end
```

---

## Ambiguous Names

Some short names match multiple levels. Use longer strings to be specific:

| Short Name | Matches                                                                                               |
|------------|-------------------------------------------------------------------------------------------------------|
| `classic`  | classic, classic_easy3, classic_easy4, classic_fight, classic_flat, classic_flat_fight, team_classic |
| `easy`     | easy1-4, classic_easy3, classic_easy4, city_easy, gates_easy                                          |
| `team`     | team_90, team_all_on_one, team_classic, team_mirror, team_space                                       |
| `stairs`   | stairs, stairs2, pyramid_stairs                                                                       |
| `pyramid`  | snow_pyramid, snow_reverse_pyramid, pyramid_stairs                                                    |
| `extra`    | extra_ball, extra_ball2, sun_extra_ball                                                               |
| `paint`    | paint, mtp_paint, sun_paint, city_paint                                                               |
