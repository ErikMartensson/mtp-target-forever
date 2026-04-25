# Current Focus

> Single source of truth for "what was I doing and what's next" — update this when you stop for the day.
> Check `docs/LEVELS.md` for the per-level status table and `docs/KNOWN_ISSUES.md` for issue details.

**Last updated:** 2026-04-25 (testing queue cleared)

## Where I left off

All 60 playable levels have a verified status. **Testing queue is empty.** Branch `wip/level-testing-feb-2026` carries everything since the Feb 24 cutoff on `main`.

Final tally per `docs/LEVELS.md`:
- 50 ✅ Working
- 10 ⚠️ Has known issue (still playable)
- 0 🚫 Broken
- 0 ❓ Untested
- 10 ⏭ Test-only (`ReleaseLevel = 0/20/200`, intentionally excluded)

## Next thing to do

Pick one of:

### A. Bug-fix pass on filed issues
The level testing turned up 4 new KIs. Some are quick wins:

1. **KI #19 — snow particles on `level_gates_*`** (sun-themed). Two paths:
   - C++ one-liner: add `level_gates_` to the prefix list in `client/src/level.cpp:436-442`. Requires client rebuild.
   - Lua-only: add `ShowSnow = 0` near the top of each of the 4 `level_gates_*.lua` files (precedent: `level_mtp_paint.lua:2`). No rebuild needed.
2. **KI #17a — i18n keys leaking to HUD on `level_sun_extra_ball`** (`LEVELEXTRALANDED|TESTER`). Replace the raw keys in `data/lua/level_sun_extra_ball_server.lua:18-20,31` with English strings. Lua-only fix.
3. **KI #17b/c — scoreboard not live + score persists across rounds.** Bigger investigation. False trail noted in KI #17 (don't try the Entity vs CEntity init fix, it's a no-op). Real cause likely in scoreboard read path; affects all gates levels, sun_extra_ball, donuts2 — all share non-standard round-end conditions.
4. **KI #16 — bots infinite-bouncing on havoc.** Intermittent, low pri. Skip unless reproducible.
5. **KI #18 — city_destroy 300 unlandable.** Decision was to keep upstream geometry. Skip unless we change that decision.

### B. Merge WIP to `main`
If we're satisfied with the testing coverage, open a PR `wip/level-testing-feb-2026` → `main`. CI builds, you get a green/red signal, then merge. Snapshots a known-good state with all 50 levels verified.

### C. Ship a `v0.2.0` tag
After (B), tag `v0.2.0`. The `release.yml` workflow will package + publish. First tagged release in a long time — gives users an actual download instead of "latest main artifact".

### D. Linux build
The audit earlier estimated 2-4 days. Park it until the bug-fix pass is done so we're not porting known-broken code.

## Open higher-priority bugs (still to verify)

- **KI #1 — Intermittent scoring failure on `level_bowls1`.** Fix applied Feb 8 (Lunar metatable patch). Still marked ⚠️. Needs extended solo play (~20 rounds) to verify.

## Tooling reminder

```powershell
# Quick-load any level or preset (no .cfg editing):
.\scripts\run-server.bat -p level_space_hangar18
.\scripts\run-server.bat -p sun-untested        # named preset
.\scripts\run-server.bat -p a,b,c               # inline
.\scripts\run-server.bat -p last                # repeat
.\scripts\run-server.bat                        # normal rotation
```

After editing `data/lua/` or `data/module/`, the file must be copied into `build-server/bin/data/` (run `scripts\post-build.bat`, or just `cp` directly).

## Conventions

- Commit messages: `<verb> <what>` — present tense, imperative.
- Per-level fixes: small, focused commits straight to the branch.
- Larger / risky changes: branch first, PR to merge.
- Keep `docs/LEVELS.md` and `docs/KNOWN_ISSUES.md` accurate as you go.
