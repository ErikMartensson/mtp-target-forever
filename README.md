# MTP Target - Community Revival

<p align="center">
  <img src="assets/site_logo.png" alt="MTP Target Logo" width="170" height="94">
</p>

> A free multiplayer online action game where you roll down a giant ramp and delicately land on platforms to score points. Fight with and against players in this mix of action, dexterity, and strategy - inspired by Monkey Target from Super Monkey Ball.

**Status:** 🚧 Active Revival - Server functional, client connection in progress

---

## Table of Contents

- [About This Project](#about-this-project)
- [Current Status](#current-status)
- [Quick Start (Ubuntu/WSL)](#quick-start-ubuntuwsl)
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
3. 🚧 **Compiling the client** - Build from source for debugging and modifications
4. 📋 **Windows support** - Currently builds on Linux/WSL, Windows build coming soon

---

## Current Status

### What Works

- ✅ **Game Server:** Fully functional, compiled and tested on Ubuntu/WSL
- ✅ **Login Service:** Modern TypeScript implementation handles authentication
- ✅ **Database:** SQLite-based user and shard management
- ✅ **Physics:** ODE engine working with Lua scripting
- ✅ **Network:** VLP (login) protocol working with game client

### What's In Progress

- 🚧 **Client Connection:** SCS (shard selection) message format debugging
- 🚧 **Windows Build:** CMake configuration for Visual Studio
- 📋 **Client Compilation:** Source code ready, build system pending
- 📋 **Documentation:** Consolidating build and setup guides

---

## Quick Start (Ubuntu/WSL)

**Prerequisites:**
- Ubuntu 22.04+ or WSL2
- Deno 2.6.0+ (for login service)
- Build tools (gcc, cmake, ninja)

### 1. Install Dependencies

```bash
sudo apt update
sudo apt install -y build-essential cmake git ninja-build \
    libxml2-dev libfreetype6-dev libpng-dev libjpeg-dev \
    libgl1-mesa-dev libglu1-mesa-dev libxxf86vm-dev \
    libxrandr-dev libxrender-dev libmysqlclient-dev \
    lua5.1 liblua5.1-0-dev libcurl4-openssl-dev \
    libluabind-dev libode-dev
```

### 2. Build NeL Framework

```bash
git clone https://github.com/ryzom/ryzomcore.git
cd ryzomcore && mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DWITH_SOUND=OFF ..
ninja
cd ../..
```

### 3. Build Game Server

```bash
cd tux_target  # This repository
make -C server update
make -C server all
```

### 4. Start Services

```bash
# Terminal 1: Start game server
cd server/src
LD_LIBRARY_PATH=/path/to/ryzomcore/build/lib:$LD_LIBRARY_PATH ./mtp_target_service

# Terminal 2: Start login service (requires Deno)
cd login-service-deno
deno task db-setup  # First time only
deno task login

# Terminal 3: Start HTTP server (requires sudo for port 80)
cd login-service-deno
sudo deno task http
```

For detailed instructions, see **[docs/BUILDING.md](docs/BUILDING.md)**.

---

## Documentation

| Document | Description |
|----------|-------------|
| [**BUILDING.md**](docs/BUILDING.md) | Complete build guide for all platforms |
| [**MODIFICATIONS.md**](docs/MODIFICATIONS.md) | Source code changes for modern compatibility |
| [**PROTOCOL_NOTES.md**](docs/PROTOCOL_NOTES.md) | NeL network protocol technical reference |
| [**docs/archive/**](docs/archive/) | Historical development notes |

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

### Short Term
- [x] Get server running on modern Linux
- [x] Build working login service
- [ ] Debug SCS message format (in progress)
- [ ] Compile client from source
- [ ] Test full connection flow

### Medium Term
- [ ] Windows build system
- [ ] Automated builds (GitHub Actions)
- [ ] Docker containers for easy deployment
- [ ] Modern authentication (optional)
- [ ] Web-based server browser

### Long Term
- [ ] Community servers
- [ ] Custom levels and mods
- [ ] Updated graphics (optional)
- [ ] Modern networking (optional)

---

## Known Issues

### Critical
- **SCS Message Crash:** Client crashes when receiving shard connection info from login service
  - Root cause: Binary/source mismatch - installed client doesn't match source code
  - Solution in progress: Compile client from source

### Minor
- Data directory path warnings (cosmetic)
- Time format compilation warnings (non-functional)
- Windows build not yet configured

See [Issues](../../issues) for full bug tracker.

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

### Community Restoration (2025)
- Server compilation and modern compatibility fixes
- TypeScript login service implementation
- Documentation and build guides

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
