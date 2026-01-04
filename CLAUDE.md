# Tux Target

A penguin bowling/curling game where players roll down slopes and land on scoring targets. Originally released as MTP Target, this is a revival of v1.2.2a built against modern Ryzom Core/NeL libraries.

## Quick Start

```bash
# Build
.\scripts\build-server.bat
.\scripts\build-client.bat

# Run (two terminals)
.\scripts\run-server.bat
.\scripts\run-client.bat --lan localhost --user YourName
```

## Directory Structure

```
tux_target/
├── build-client/bin/Release/    # Client build output
│   ├── tux-target.exe
│   └── data/                    # Game assets (copied from data/)
│
├── build-server/bin/Release/    # Server build output
│   ├── tux-target-srv.exe
│   ├── mtp_target_service.cfg   # RUNTIME CONFIG - edit this!
│   └── data/                    # Game assets (copied from data/)
│
├── data/                        # Source game assets (committed)
│   ├── level/                   # Level definitions (*.lua)
│   ├── lua/                     # Server-side Lua scripts
│   ├── shape/                   # 3D models
│   ├── texture/                 # Textures
│   └── ...
│
├── client/src/                  # Client source code
├── server/src/                  # Server source code
├── common/                      # Shared code
│
├── scripts/                     # Build and run scripts
│   ├── build-client.bat
│   ├── build-server.bat
│   ├── run-client.bat           # Supports: --lan <host> --user <name>
│   ├── run-server.bat
│   └── post-build.bat           # Copies data/ to build directories
│
├── docs/                        # Documentation
│   ├── BUILDING.md
│   ├── KNOWN_ISSUES.md
│   ├── LEVELS.md
│   └── RUNTIME_FIXES.md
│
└── reference/                   # Reference materials (DO NOT EDIT)
    └── mtp-target-v1.5.19/      # v1.5.19 client source for comparison
        ├── client/              # Client code with newer features
        ├── common/              # Shared code
        └── data/                # Assets (space/sun/city themes)
```

## Configuration

**Server runtime config:** `build-server/bin/Release/mtp_target_service.cfg`

This is the file that matters at runtime. The template at `server/mtp_target_service_default.cfg` is only copied on first build.

**Key settings:**
```cfg
LevelPlaylist = { "level_classic" };  # Single level for testing
LevelPlaylist = { };                   # Empty = normal rotation
```

## Testing Levels

1. Edit `build-server/bin/Release/mtp_target_service.cfg`
2. Set `LevelPlaylist = { "level_name" };`
3. Start server: `.\scripts\run-server.bat`
4. Start client: `.\scripts\run-client.bat --lan localhost --user tester`

**Chat commands:**
- `/forcemap <name>` - Force next level (admin)
- `/v <name>` - Vote for a level
- `/forceend` - End current session

## Branches

| Branch | Purpose |
|--------|---------|
| `frankensteins-monster` | Active development with all fixes |
| `master` | Pristine original v1.2.2a source for comparison |

## Key Source Files

### Server
- `server/src/level.cpp` - Loads Score, Friction, Accel, Bounce from level modules
- `server/src/module.cpp` - Lua 5.2+ compatibility for module scripts
- `server/src/physics.cpp` - ODE physics, momentum preservation (dContactApprox1)
- `server/src/network.cpp` - Network tick rate (line 142)

### Client
- `client/src/chat_task.cpp` - Chat toggle mode (Enter key)
- `client/src/hud_task.cpp` - HUD rendering (speed display, altimeter, score)
- `client/src/interpolator.cpp` - Client-side position smoothing

### Lua Scripts
- `data/lua/*_server.lua` - Server-side scoring logic per level
- `data/level/*.lua` - Level definitions (modules, spawn points, theme)

## Common Fix Patterns

### Slope Steering
**Problem:** Player can't steer or accelerate on starting slopes.
**Fix:** Add explicit properties to snow_ramp modules:
```lua
{ ..., Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
```

### Team Level Scoring
**Detection:** Module Lua names containing "red" or "blue" are detected as team targets.
**Naming:** Use `team_target_50_red`, `team_target_100_blue`, etc.

### Stacked Target Collision
**For overlapping targets:** Use small Z offsets (0.01) to separate collision surfaces.
**Rule:** Higher score targets at lower Z (ball lands on them last).

### Momentum Loss at Ramps
**Already fixed:** Changed ODE contact mode from `dContactMu2` to `dContactApprox1` in physics.cpp.

## Debug / Logs

**Server log:** `build-server/bin/Release/mtp_target_service.log`

Watch in real-time:
```bash
tail -f build-server/bin/Release/mtp_target_service.log
```

**Client log:** Check console output or `build-client/bin/Release/` for any `.log` files.

**Common log patterns:**
- `Loading level: level_name` - Level loading started
- `Lua error:` - Script problems
- `Module score:` - Scoring events (if debug enabled)

## Level File Format

Levels are Lua files in `data/level/`. Key fields:

```lua
Name = "Display Name"
Author = "Creator"
Theme = "snow"                           -- Visual theme
ServerLua = "level_custom_server.lua"    -- Scoring script
ReleaseLevel = 3                         -- 1-5 = playable, 0 = test only

Modules = {
    { Position = CVector(0, 0, 0),
      Rotation = CAngleAxis(0, 0, 1, 0),
      Scale = CVector(1, 1, 1),
      Color = CRGBA(255, 255, 255, 255),
      Lua = "module_name",               -- Module behavior
      Shape = "shape_name",              -- 3D model
      Score = 100,                       -- Points for landing
      Friction = 1,                      -- Surface friction
      Accel = 0,                         -- Acceleration boost
      Bounce = 0                         -- Bounce factor
    },
}

StartPoints = {
    { Position = CVector(0, 10, 5), Rotation = 0 },
}
```

## Reference Source (v1.5.19)

The `reference/mtp-target-v1.5.19/` directory contains the last official release (client only, no server).

**DO NOT EDIT** - this is reference material for:
- Comparing code between v1.2.2a and v1.5.19
- Extracting assets (space/sun/city theme shapes and textures)
- Understanding v1.5.19 features to port

**Source:** [Internet Archive](https://web.archive.org/web/20130630212354/http://www.mtp-target.org/files/mtp-target-src.19.tar.bz2)

## Documentation

| Doc | Contents |
|-----|----------|
| [docs/BUILDING.md](docs/BUILDING.md) | Build prerequisites and steps |
| [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Issue tracker with priorities |
| [docs/LEVELS.md](docs/LEVELS.md) | Level list, scoring mechanics, chat commands |
| [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) | Runtime issue solutions |
