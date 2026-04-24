# Current Focus

> Single source of truth for "what was I doing and what's next" — update this when you stop for the day.
> Check `docs/KNOWN_ISSUES.md` for the structured issue list and per-level testing table.

**Last updated:** 2026-04-24 (returning after a 2-month break)

## Where I left off (Feb 24, 2026)

Last commit on `main`: `172a2c8` — "Auto-reset camera to own penguin at the start of each round"

Active WIP parked on branch `wip/level-testing-feb-2026`:
1. Engine + config changes (deferred module Lua loading, `Collide` flag, AllowMouse=4 mouse mode, dynamic texture lookup, bot replay matching)
2. 28 ported v1.5.19 levels + per-theme utility scripts
3. Doc updates (CHAT.md added, KNOWN_ISSUES level testing table)

## Next thing to do

**Per-level testing of the 28 v1.5.19 ports** — the table in [KNOWN_ISSUES.md issue #2](KNOWN_ISSUES.md) has rows full of `?`. Pick one level at a time, set the playlist to it, play a few rounds, fill in the row.

Suggested order (engine fixes already applied; these just need verification):
1. **Space levels** (10 untested) — start with `level_space_atomium`, `calbren`, `fleet`
2. **Sun levels** (3 untested) — `level_sun_cross`, `extra_ball`, `paint`
3. **City levels** (2 untested) — `level_city_destroy`, `precision`
4. **Gates** (3 untested) — `level_gates_hard`, `ramp`, `zig_zag`
5. **Other** — `level_donuts2`, `mtp_paint`, `snow_line`, `team_space`

For each, check: loads, ramp works, scoring works, bot behavior, notes.

## Open higher-priority bugs

- **Issue #1 — Intermittent scoring failure** (KNOWN_ISSUES.md). Fix applied Feb 8 (Lunar metatable patch). Needs extended verification under solo play on `level_bowls1`.

## How to work on this project

- `main` = working baseline. CI builds + publishes nightly artifacts on every push.
- `wip/*` = parked or in-progress work. CI does NOT run on these branches.
- Open a PR to `main` when ready to merge — that triggers a CI build for pre-merge validation.

When testing a level:
```bash
# 1. edit build-server/bin/mtp_target_service.cfg → LevelPlaylist = { "level_name" };
# 2. .\scripts\run-server.bat
# 3. .\scripts\run-client.bat --lan localhost --user tester
# 4. update docs/KNOWN_ISSUES.md table row, commit
```

After editing Lua scripts in `data/lua/` or `data/module/`, run `scripts\post-build.bat` (or manually copy) to push them into `build-*/bin/data/`.

## Conventions

- Commit messages: `<verb> <what>` — present tense, imperative. e.g. "Fix slope steering on pyramid_stairs".
- Per-level fixes go straight to `main` once verified — small, focused commits.
- Larger refactors or risky changes: branch first, PR to merge.
- Keep `KNOWN_ISSUES.md` accurate — flip ✓ as you verify levels, add new bugs as you find them.
