# Current Focus

> Single source of truth for "what was I doing and what's next" — update this when you stop for the day.
> Check `docs/LEVELS.md` for the per-level status table and `docs/KNOWN_ISSUES.md` for issue details.

**Last updated:** 2026-04-25 (KI #17 + KI #20 both fully fixed)

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

1. **Sanity-test the 4 gates levels** (`level_gates_easy/hard/ramp/zig_zag`). KI #20's gate-trigger fix was tuned and verified on `level_sun_extra_ball`. The same `addGatePS`/`addGate90PS` defaults now apply to the four gates levels — should work the same, but worth a quick run-through. `level_gates_zig_zag` in particular spaces gates only 0.35 units apart in Z, so check that adjacent gates still score correctly.
2. **Cleanup: delete the shadow `.lua` files** at `build-server/bin/data/` root (`helpers.lua`, `level_bowls1_server.lua`, `level_team_server.lua`). They were silently shadowing the canonical `data/lua/` copies and bit us hard during KI #20. Currently overwritten to match but the cleanest fix is to remove them outright.
3. **KI #16 — bots infinite-bouncing on havoc.** Intermittent, low pri. Skip unless reproducible.
4. **KI #18 — city_destroy 300 unlandable.** Decision was to keep upstream geometry. Skip unless we change that decision.

Done April 25:
- ~~KI #19 (snow particles on sun-themed gates)~~ ✅ Lua-only fix, `ShowSnow = 0` added to all 4 `level_gates_*.lua` files
- ~~KI #17a (i18n keys leaking to HUD on level_sun_extra_ball)~~ ✅ Replaced raw keys with English literals in `level_sun_extra_ball_server.lua`
- ~~KI #17b/c (scoreboard not live + score persists across rounds)~~ ✅ New `ScoreUpdate` network message broadcast from server's 50 Hz tick whenever any entity's `CurrentScore` changes. Per-round reset propagates automatically. Affected all gates, sun_extra_ball, donuts2.
- ~~KI #20 (gate AABB scores on frame hits / visual gate didn't move)~~ ✅ Two combined bugs: (a) `CGateProxy:setPosition` now also calls runtime `Module:setPos` so the visible mesh actually moves; (b) tightened trigger volume to `OpeningHalfExtents = CVector(0.05, 0.05, 0.05)`. Verified working on sun_extra_ball.

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
