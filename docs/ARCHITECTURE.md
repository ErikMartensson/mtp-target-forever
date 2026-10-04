# Architecture

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

## Components

- **Game Client:** C++ with the NeL 3D engine (OpenGL/OpenAL drivers)
- **Game Server:** C++ with the NeL framework, ODE 0.16 physics, Lua 5.1 scripting. Listens on port 51574
- **Login Service:** TypeScript/Deno with SQLite for user and shard management. Listens on port 49997

The login service is only needed for "Play Online" mode. LAN mode (`run-client.bat --lan <host>`) connects directly to the game server and skips authentication entirely, which is the easiest way to play.

## See Also

- [BUILDING.md](BUILDING.md) — Build guide
- [PROTOCOL_NOTES.md](PROTOCOL_NOTES.md) — NeL network protocol reference
- [MODIFICATIONS.md](MODIFICATIONS.md) — Source changes for modern compatibility
