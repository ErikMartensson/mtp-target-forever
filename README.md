# MTP Target Forever

<p align="center">
  <img src="assets/site_logo.png" alt="MTP Target Logo" width="170" height="94">
</p>

> A free multiplayer online action game where you roll down a giant ramp and delicately land on platforms to score points. Fight with and against players in this mix of action, dexterity, and strategy - inspired by Monkey Target from Super Monkey Ball.

**Status:** 🎮 Playable - v1.2.2a client and server with 60 playable levels (56 verified working, 4 with a documented issue or follow-up check)

### Download Latest Build

| Component | Download |
|-----------|----------|
| **Game Client** | [MTP-Target-Forever-Client-win64.zip](https://nightly.link/ErikMartensson/mtp-target-forever/workflows/build/main/MTP-Target-Forever-Client-win64.zip) |
| **Game Server** | [MTP-Target-Forever-Server-win64.zip](https://nightly.link/ErikMartensson/mtp-target-forever/workflows/build/main/MTP-Target-Forever-Server-win64.zip) |

*Built automatically from the latest `main` branch commit. Extract, run the server, then the client - see [docs/CONTROLS.md](docs/CONTROLS.md) to get started.*

---

## About

**MTP Target** was created by Melting Pot in 2003-2004 and went offline around 2013. This is a community revival built on the original v1.2.2a source code, modernized to compile and run on current Windows against the Ryzom Core/NeL libraries, with levels and assets ported from the v1.5.19 release.

Server, client, physics, and scoring all work, and every playable level has been through an initial gameplay test. What's been changed and fixed is documented in the [changelog](docs/CHANGELOG.md); what's still rough is in the [issue tracker](docs/KNOWN_ISSUES.md).

## Built With AI - Transparency

I want to be upfront about how this project was made: **it was developed extensively with AI coding tools.**

Two honest reasons:

1. **I can't write C or C++, and my Lua knowledge is limited.** Reviving a 20-year-old C++ codebase would have been far beyond my ability without AI assistance.
2. **Nobody else had done it.** I couldn't find any working, maintained copy of this game anywhere. I have so much love and nostalgia for MTP Target that I felt I had to do it myself, for my own sake at least.

I don't expect the outcome to be perfect. Far from it actually. In terms of development I did the bare minimum to get the game building and playable, and rough edges remain. Though, I have done extensive manual testing in order to sort out bugs and improve some of the user experience. My hope is simply that at least one other person out there finds this project, plays it, and enjoys themselves, even momentarily.

The best-case scenario would be for someone with actual NeL/Ryzom engine experience to find this and revive the game properly. If that's you: the code is GPL, the docs are in [docs/](docs/), and forks are very welcome.

## Building From Source

See **[docs/BUILDING.md](docs/BUILDING.md)** - automated scripts handle dependencies, the NeL engine build, and the game itself on Windows 10/11.

## Documentation

| Doc | Contents |
|-----|----------|
| [BUILDING.md](docs/BUILDING.md) | Build guide (quick start + troubleshooting) |
| [CONTROLS.md](docs/CONTROLS.md) | Game controls and debug keys |
| [CHAT.md](docs/CHAT.md) | Chat commands and level voting |
| [LEVELS.md](docs/LEVELS.md) | All levels and their testing status |
| [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Open and fixed issues |
| [CHANGELOG.md](docs/CHANGELOG.md) | Everything changed since the original v1.2.2a |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Client / server / login service overview |
| [MODIFICATIONS.md](docs/MODIFICATIONS.md) | Source changes for modern compatibility |
| [RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) | Runtime problems and solutions |

## The Original Game

Created by **Melting Pot** (Ace, Muf, Skeet) in 2003-2004, active until ~2009, gone by ~2013. It promised - and delivered - immediate fun: one-minute rounds, five minutes to learn but weeks to master, tons of easy and hard levels, team maps, and up to 16 players per server. Free software (GPL) then, still GPL now.

The original site (www.mtp-target.org) is long offline, but the v1.5.19 client source survives on the [Internet Archive](https://web.archive.org/web/20130630212354/http://www.mtp-target.org/files/mtp-target-src.19.tar.bz2).

## License

Free software released under the **GNU GPL v2+** license. See [COPYING](COPYING) for the full text.

## Credits

### Original Developers (2003-2004)
- **Code:** Ace, Muf, Skeet (Melting Pot)
- **Additional code:** Mickey
- **Sounds:** Garou (Melting Pot)
- **Music:** Hulud (Digital Murder)
- **Graphics:** 9dan, Paul, Kaiser Foufou, Hades
- **Testing:** Darky, Dyze, Felix, Grib, R!pper, Snagrot, Uzgrot, Lithrel, and the #ryzom.epiknet beta testers
- **Community levels:** erendis, Phail, Wedgee

### Libraries & Engines
- **NeL Framework:** Nevrax / Ryzom Core team
- **ODE Physics:** Russell Smith and contributors
- **Lua:** PUC-Rio team

---

**Let's bring this fun penguin game back to life! 🐧🎯**
