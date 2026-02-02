# MTP Target Forever

A penguin bowling/curling game where players roll down slopes and land on scoring targets. MTP Target Forever is a community revival of the original MTP Target v1.2.2a, built against modern Ryzom Core/NeL libraries.

## Quick Start

```powershell
# Prerequisites: Visual Studio 2022 Build Tools + Ninja (choco install ninja)

# First-time setup: Install dependencies (~1.3GB download)
.\scripts\setup-deps.ps1

# Build RyzomCore/NeL (one-time, ~5 min)
.\scripts\setup-ryzomcore.ps1

# Build game (auto-detects MSVC environment)
.\scripts\build-client.bat
.\scripts\build-server.bat

# Run (two terminals)
.\scripts\run-server.bat
.\scripts\run-client.bat --lan localhost --user YourName
```

## Directory Structure

```
mtp-target-forever/
├── deps/                        # Dependencies (git-ignored, created by setup-deps.ps1)
│   ├── lua/                     # Lua 5.1
│   ├── curl/                    # libcurl
│   ├── libxml2/                 # XML parsing
│   ├── ode/                     # Physics engine (server only)
│   └── ...
│
├── ryzomcore/                   # RyzomCore/NeL (git-ignored, created by setup-ryzomcore.ps1)
│   ├── build/lib/               # NeL static libraries
│   └── build/bin/               # NeL driver DLLs
│
├── build-client/bin/            # Client build output (Ninja)
│   ├── mtp-target-forever.exe
│   └── data/                    # Game assets (copied from data/)
│
├── build-server/bin/            # Server build output (Ninja)
│   ├── mtp-target-forever-srv.exe
│   ├── mtp_target_service.cfg   # RUNTIME CONFIG - edit this!
│   └── data/                    # Game assets (copied from data/)
│
├── data/                        # Source game assets (committed)
│   ├── level/                   # Level definitions (*.lua)
│   ├── lua/                     # Server-side Lua scripts
│   ├── shape/                   # 3D models
│   ├── sound/                   # Sound effects and music
│   │   ├── DFN/                 # NeL sound definition schemas
│   │   ├── samplebank/sound/    # WAV audio files
│   │   └── soundbank/           # Sound sheet definitions (.sound)
│   ├── texture/                 # Textures
│   └── ...
│
├── client/src/                  # Client source code
├── server/src/                  # Server source code
├── common/                      # Shared code
│
├── scripts/                     # Build and run scripts
│   ├── setup-deps.ps1           # Downloads dependencies to deps/
│   ├── setup-ryzomcore.ps1      # Clones and builds RyzomCore/NeL
│   ├── build-client.bat         # Builds client with Ninja
│   ├── build-server.bat         # Builds server with Ninja
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

**Server runtime config:** `build-server/bin/mtp_target_service.cfg`

This is the file that matters at runtime. The template at `server/mtp_target_service_default.cfg` is only copied on first build.

**Key settings:**
```cfg
LevelPlaylist = { "level_classic" };  # Single level for testing
LevelPlaylist = { };                   # Empty = normal rotation
```

## Testing Levels

1. Edit `build-server/bin/mtp_target_service.cfg`
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
| `main` | Active development with all fixes |
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
- `client/src/sound_manager.cpp` - Sound effects and music playback
- `client/src/entity.cpp` - Entity updates, sound triggers, water collision detection

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

### Log File Locations

| Component | Running Directly | After Exit (via run script) |
|-----------|------------------|----------------------------|
| **Client** | `build-client/bin/log.log` | `build-client/bin/logs/log.log` |
| **Server** | `build-server/bin/mtp_target_service.log` | `build-server/bin/logs/mtp_target_service.log` |

**Log rotation behavior:**
- When running executables directly, logs accumulate in `build-*/bin/log.log`
- When using `scripts/run-client.bat` or `scripts/run-server.bat`:
  - Logs are written to the same path while the game is running
  - On exit/crash, logs are moved to `build-*/bin/logs/` directory
  - Previous logs are rotated (`.log` → `.log.1` → `.log.2`, etc., up to 5 files)

**Watch logs in real-time:**
```bash
tail -f build-server/bin/mtp_target_service.log  # Server
tail -f build-client/bin/log.log                  # Client
```

**Common log patterns:**
- `Loading level: level_name` - Level loading started
- `Lua error:` - Script problems
- `Module score:` - Scoring events (if debug enabled)

### Debug/Developer Keys

Client debug keys defined in `client/src/controler.cpp`:

| Key | Action | Status |
|-----|--------|--------|
| ESC | Open pause menu | Works |
| F1 | Toggle level view | Works |
| F3 | Cycle polygon mode (solid/wireframe/points) | Works |
| F7 | Toggle free look camera mode | Works |
| F8 | Release/capture mouse cursor | Works |
| F9 | View previous entity | Works |
| F10 | View next entity | Works |
| F11 | Reset followed entity | Works |
| F12 | Print camera position to log | Works |
| Alt+A | Toggle external camera | Works |
| Alt+F2 | Take screenshot | Works |
| Ctrl+F5 | Force end session (`/forceend`) | Works |
| Ctrl+F6 | Reset session (`/reset`) | Buggy (acts like /forceend) |
| F5 | Add bot | DISABLED (crash) |
| F6 | Kick bot | DISABLED (crash) |
| Shift+F1 | Toggle start positions display | Non-functional |
| F4 | Toggle editor mode | Non-functional |
| Ctrl+F4 | Toggle debug display | Non-functional |

### Network Latency Investigation

If investigating high ping or input delay, check these files:
- `server/src/network.cpp:142` - Network update rate (changed 40ms → 20ms)
- `client/src/interpolator.cpp` - Client-side position smoothing
- Look for sleep/wait calls in network loops

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
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | All improvements from original v1.2.2a |
| [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Issue tracker with priorities |
| [docs/LEVELS.md](docs/LEVELS.md) | Level list, scoring mechanics, chat commands |
| [docs/MODIFICATIONS.md](docs/MODIFICATIONS.md) | Source code changes for modern compatibility |
| [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) | Runtime issue solutions |

## Finalizing Tasks

Before creating commits for completed features or fixes, update documentation:

- [ ] **docs/CHANGELOG.md** - Add new features, improvements, or fixes
- [ ] **docs/MODIFICATIONS.md** - Document source code changes (if applicable)
- [ ] **docs/KNOWN_ISSUES.md** - Mark fixed issues as completed, add new issues discovered
- [ ] **docs/RUNTIME_FIXES.md** - Add runtime solutions (if applicable)
- [ ] **README.md** - Update status, features, or known issues sections (if significant)

**Typical updates:**
- New feature → CHANGELOG.md + README.md (if user-facing)
- Bug fix → CHANGELOG.md + KNOWN_ISSUES.md (mark completed)
- Code modernization → MODIFICATIONS.md
- Runtime crash fix → RUNTIME_FIXES.md + KNOWN_ISSUES.md
