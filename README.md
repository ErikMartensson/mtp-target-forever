# MTP Target Forever

<p align="center">
  <img src="assets/site_logo.png" alt="MTP Target Logo" width="170" height="94">
</p>

> A free multiplayer online action game where you roll down a giant ramp and delicately land on platforms to score points. Fight with and against players in this mix of action, dexterity, and strategy - inspired by Monkey Target from Super Monkey Ball.

**Status:** 🎮 Playable - Version 1.2.2a client and server working with 32 of 62 levels

### Download Latest Build

| Component | Download |
|-----------|----------|
| **Game Client** | [MTP-Target-Forever-Client-win64.zip](https://nightly.link/ErikMartensson/tux_target/workflows/build/main/MTP-Target-Forever-Client-win64.zip) |
| **Game Server** | [MTP-Target-Forever-Server-win64.zip](https://nightly.link/ErikMartensson/tux_target/workflows/build/main/MTP-Target-Forever-Server-win64.zip) |

*Built automatically from the latest `main` branch commit.*

---

## Table of Contents

- [Download Latest Build](#download-latest-build)
- [About This Project](#about-this-project)
- [Current Status](#current-status)
- [Quick Start (Windows)](#quick-start-windows)
- [Documentation](#documentation)
- [Architecture](#architecture)
- [What We've Fixed](#what-weve-fixed)
- [Contributing](#contributing)
- [Original Game Info](#original-game-info)
- [Project Goals](#project-goals)
- [Known Issues](#known-issues)
- [License](#license)
- [Credits](#credits)
- [Contact & Community](#contact--community)

---

## About This Project

**MTP Target** was created by Melting Pot in 2003-2004 and went offline around 2013. This is a community effort to bring it back to life by:

1. ✅ **Building a local server** - Run your own game server
2. ✅ **Creating a modern login service** - TypeScript/Deno replacement for authentication
3. ✅ **Compiling the client** - Build from source for debugging and modifications
4. ✅ **Windows support** - Full Windows build with Visual Studio 2022

### Version Strategy

We're currently running **version 1.2.2a** (from this repository's source code) for both client and server. This ensures full compatibility between all components.

**Future Plans:**
- Port features and improvements from version 1.5.19 where possible
- Add additional levels from 1.5.19 release
- Consider protocol upgrade to 1.5.19 if compatible with gameplay

The original v1.5.19 server source is unavailable, so we're starting with the v1.2.2a codebase we have and will enhance it over time.

### Reference Source Code

The v1.5.19 client source code is preserved in [`reference/mtp-target-v1.5.19/`](reference/mtp-target-v1.5.19/) for comparison and asset extraction. This includes shapes and textures for space/sun/city themes that are missing from v1.2.2a.

**Original download:** [Internet Archive](https://web.archive.org/web/20130630212354/http://www.mtp-target.org/files/mtp-target-src.19.tar.bz2)

---

## Current Status

### What Works ✅

- ✅ **Build System:** Full Windows build with Visual Studio 2022 and automated scripts
- ✅ **Game Server:** Compiles and runs on Windows, 32 playable levels working
- ✅ **Game Client:** Compiles and runs on Windows with OpenGL/OpenAL drivers
- ✅ **Login Service:** Modern TypeScript/Deno implementation handles authentication
- ✅ **Database:** SQLite-based user and shard management
- ✅ **Physics:** ODE 0.16.5 engine with Lua 5.x scripting
- ✅ **Network:** Full protocol working (VLP login + game server connection)
- ✅ **Controls:** Arrow keys for steering, Ctrl for ball/glide toggle, Enter for chat
- ✅ **Scoring:** Full scoring system with targets and friction
- ⚠️ **Bots:** AI bots present but not working correctly on all maps
- ✅ **Game Assets:** All textures, shapes, sounds included in repository

### Known Issues ⚠️

See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for the complete issue tracker.

**Medium Priority:**
- ⚠️ **30 levels unavailable** - Require missing theme assets (space/sun/city)
- ⚠️ **Bot AI limited** - Bots learn from player replays, don't play independently
- ⚠️ **High ping on localhost** - 17-19ms instead of near-zero
- ⚠️ **Input delay** - Noticeable lag between steering input and penguin response

**Low Priority:**
- ⚠️ **Water rendering disabled** - Falls back gracefully when textures missing

**The game is fully playable!** All 32 snow-theme levels work with proper scoring and physics.

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for detailed fix documentation.

---

## Quick Start (Windows)

**Prerequisites:**
- Windows 10/11
- Visual Studio 2022 Build Tools (with C++ Desktop Development)
- CMake 3.20+
- 7-Zip (for extracting dependencies)
- PowerShell 5.1+

**Optional:**
- vcpkg (for server builds - ODE physics library)
- Deno 2.6.0+ (for login service, only needed for "Play Online")

### 1. Setup Dependencies

```powershell
# Download and install dependencies (~1.3GB)
.\scripts\setup-deps.ps1

# Client only (skip ODE physics library)
.\scripts\setup-deps.ps1 -SkipODE
```

This downloads pre-built libraries to `deps/` (git-ignored).

### 2. Build RyzomCore (NeL)

One-time build of the NeL engine libraries (~15 minutes):

```powershell
git clone --depth 1 https://github.com/ryzom/ryzomcore.git C:\ryzomcore
cd C:\ryzomcore && mkdir build && cd build

cmake .. -G "Visual Studio 17 2022" -A x64 `
    -DWITH_SOUND=ON -DWITH_NEL=ON -DWITH_NEL_TOOLS=OFF `
    -DWITH_NEL_TESTS=OFF -DWITH_NEL_SAMPLES=OFF -DWITH_RYZOM=OFF `
    -DWITH_STATIC=ON -DCMAKE_PREFIX_PATH="C:/path/to/mtp-target-forever/deps"

cmake --build . --config Release --parallel 4 --target nelmisc nel3d nelnet nelsound nelsnd_lowlevel nelgeorges nelligo
cmake --build . --config Release --parallel 2 --target nel_drv_opengl_win nel_drv_openal_win
```

### 3. Build Game

```powershell
.\scripts\build-client.bat
.\scripts\build-server.bat
```

### 4. Run the Game

```powershell
# Terminal 1: Start server
.\scripts\run-server.bat

# Terminal 2: Start client (LAN mode - no login service needed)
.\scripts\run-client.bat --lan localhost --user YourName
```

**Controls:**
- **Arrow keys:** Steer penguin (requires speed in ball mode)
- **CTRL:** Toggle between ball/gliding modes
- **Enter:** Open chat (press again to send)
- **Escape:** Cancel chat

**Chat Commands:**

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/v <name>` | Vote for a level (e.g., `/v arena`) |
| `/forcemap <name>` | Force next level (admin) |
| `/forceend` | End current session (admin) |

See **[docs/LEVELS.md](docs/LEVELS.md)** for the complete level list and map names.

For detailed build instructions and troubleshooting, see **[docs/BUILDING.md](docs/BUILDING.md)** and **[docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md)**.

---

## Documentation

| Document | Description |
|----------|-------------|
| [**BUILDING.md**](docs/BUILDING.md) | Complete build guide for Windows (NeL, ODE, client, server) |
| [**RUNTIME_FIXES.md**](docs/RUNTIME_FIXES.md) | Runtime crashes and fixes (water, levels, controls, files) |
| [**KNOWN_ISSUES.md**](docs/KNOWN_ISSUES.md) | Issue tracker with planned fixes and priorities |
| [**LEVELS.md**](docs/LEVELS.md) | Level list and chat commands for voting/forcing maps |
| [**MODIFICATIONS.md**](docs/MODIFICATIONS.md) | Source code changes for modern compatibility |
| [**PROTOCOL_NOTES.md**](docs/PROTOCOL_NOTES.md) | NeL network protocol technical reference |
| [**scripts/post-build.bat**](scripts/post-build.bat) | Automated post-build file copy script |
| [**docs/archive/**](docs/archive/) | Historical development notes (reference only) |

---

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Client    │────────>│Login Service │────────>│   Database   │
│ (Windows)   │  Auth   │  (Deno/TS)   │  Query  │  (SQLite)    │
│             │<────────│   Port 49997 │<────────│              │
└─────────────┘  Shards └──────────────┘         └──────────────┘
       │
       │ Connect with cookie
       v
┌─────────────┐
│Game Server  │
│  (C++/NeL)  │  Lua scripts, ODE physics, multiplayer logic
│ Port 51574  │
└─────────────┘
```

**Technology Stack:**
- **Game Server:** C++ with NeL framework, ODE physics, Lua 5.1
- **Login Service:** TypeScript/Deno with SQLite
- **Client:** C++ with NeL 3D engine (original Windows binary or from source)

---

## What We've Fixed

The original code was from 2003-2004 and needed updates for modern systems:

- ✅ **Lua 5.0 → 5.1** - Migrated to currently supported Lua version
- ✅ **64-bit compatibility** - Fixed pointer casts and size types
- ✅ **Modern NeL API** - Updated for RyzomCore (NeL's successor)
- ✅ **ODE 0.5 → 0.16** - Physics engine upgrade
- ✅ **Namespace fixes** - Resolved conflicts with modern C++ std library

See [docs/MODIFICATIONS.md](docs/MODIFICATIONS.md) for technical details.

---

## Contributing

We'd love your help! This is a community effort to preserve a fun open-source game.

### Areas Where We Need Help

- **Windows Build System:** CMake configuration for Visual Studio
- **Client Compilation:** Getting the client to build on Windows
- **Protocol Documentation:** Reverse engineering remaining message formats
- **Testing:** Trying the server on different platforms
- **macOS Support:** Build instructions and testing

### How to Contribute

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push and create a Pull Request

**Not a coder?** You can still help with:
- Documentation improvements
- Testing and bug reports
- Sharing knowledge about the original game
- Spreading the word

---

## Original Game Info

**MTP Target** was created by Melting Pot (Ace, Muf, Skeet) in 2003-2004 and active until ~2009.

**Main Features (from original site):**
- Immediate fun - no need to play 10 hours
- Short games - 1 minute rounds
- Original gameplay
- Five minutes to learn, weeks to master
- Tons of easy and hard levels
- Team maps with specific gameplay
- Up to 16 players simultaneously per server
- Free software (GPL) and free to play
- Tournaments

**Technical Stack:**
- **Engine:** NeL 3D (Nevrax Engine Library) from Ryzom
- **Physics:** ODE (Open Dynamics Engine)
- **Scripting:** Lua for game modes and levels
- **Platforms:** Windows, Linux, and Mac (originally)

---

## Project Goals

### Completed
- [x] Windows build system with Visual Studio 2022
- [x] Automated builds (GitHub Actions CI)
- [x] Game server running with 32 playable levels
- [x] Game client compiled from source
- [x] Full network protocol working
- [x] Modern Lua 5.x compatibility
- [x] Physics fixes (momentum preservation, steering)
- [x] Scoring system fully functional

### In Progress
- [ ] Import missing theme assets (space/sun/city - 30 levels)
- [ ] Improve bot AI
- [ ] Reduce network latency

### Future
- [ ] Docker containers for easy deployment
- [ ] Community servers
- [ ] Custom levels and mods
- [ ] Linux/macOS builds

---

## Known Issues

See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for the complete issue tracker.

### Open Issues
- **30 levels unavailable** - Require missing theme assets (space/sun/city)
- **Bot AI limited** - Bots learn from player replays, don't play independently
- **High ping on localhost** - 17-19ms instead of near-zero
- **Input delay** - Noticeable lag between steering and response
- **Water rendering disabled** - Falls back gracefully when textures missing

### Fixed Issues
- Build system - Full Windows compilation with automated scripts and CI
- All 32 snow-theme levels working with proper scoring
- Physics steering and momentum preservation
- Keyboard controls with chat toggle mode
- Camera controls with persistent zoom
- Team level scoring (red/blue detection)
- Lua 5.x compatibility throughout

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for fix documentation.

---

## License

This game is free software released under the **GNU GPL v2+** license.

See [COPYING](COPYING) for full license text.

---

## Credits

### Original Developers (2003-2004)
- **Code:** Ace, Muf, Skeet (Melting Pot)
- **Sounds:** Garou
- **Music:** Hulud (Digital Murder)
- **Graphics:** 9dan, Paul, Kaiser Foufou, Hades
- **Testing:** Darky, Dyze, Felix, Grib, R!pper, Snagrot, Uzgrot, Lithrel

### Libraries & Engines
- **NeL Framework:** Nevrax / Ryzom Core team
- **ODE Physics:** Russell Smith and contributors
- **Lua:** PUC-Rio team

### Community Restoration (2025-2026)
- Full Windows build system with automated CI
- Server and client compilation from source
- TypeScript login service implementation
- 32 levels tested and working
- Comprehensive documentation

---

## Contact & Community

- **Issues:** Use GitHub [Issues](../../issues) for bugs and questions
- **Discussions:** GitHub [Discussions](../../discussions) for ideas and help
- **Original Site:** www.mtp-target.org (offline, domain expired/repurposed)

---

## Star This Repository

If you're interested in this project or want to see it succeed, please give it a star! It helps others discover this game restoration effort.

---

**Let's bring this fun penguin game back to life! 🐧🎯**
