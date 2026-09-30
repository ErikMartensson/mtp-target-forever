# Current Focus

> Single source of truth for "what was I doing and what's next" — update this when you stop for the day.
> Check [LEVELS.md](LEVELS.md) for the per-level status table and [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for issue details.

**Last updated:** 2026-09-30 (Donuts 2 score-reset fix added)

## Where I left off

The latest gameplay work before this pass was completed on April 25. On September 29, all four `level_gates_*` levels were played: scoring by flying through gates and by landing on the target worked. KI #17 (score updates), KI #19 (gate-level snow), and KI #20 (gate triggers/visual movement) have fixes recorded. The frame-graze/near-miss edge case was not specifically tested.

On September 30, Donuts 2 and MTP Paint both awarded points. Live HUD updates were confirmed on both levels, and score resets were verified in both transition directions after adding `setCurrentScore(0)` to Donuts 2's custom `CEntity:init()`. Donuts 2's Ctrl+F6 control-loss reproduction and red-platform fall-through remain under investigation.

The local client and server builds both succeeded on September 29 using the repository build scripts. Lua 5.1 syntax checks passed for all 145 files in `data/level/`, `data/lua/`, and `data/module/`. These checks do not replace in-game collision/scoring tests.

Final tally per `docs/LEVELS.md`:
- 56 ✅ Working
- 4 ⚠️ Follow-up needed (still playable)
- 0 🚫 Broken
- 0 ❓ Untested
- 10 ⏭ Test-only (`ReleaseLevel = 0/20/200`, intentionally excluded)

## Next thing to do

Do a short, focused gameplay pass, then prepare the PR. This is a hobby project; the documented non-blocking issues below do not need to be solved before merging.

1. **Investigate Donuts 2 control loss (KI #21).** Reproduce by pressing Ctrl+F6 to reset the session while on Donuts 2. The server log at 22:07:20 records a scene contact while the player was marked open at approximately `(1.96, -8.53, 3.76)`, near the funnel/tube. `server/src/physics.cpp` freezes movement on any scene contact while open. This may be related, but the player reports still rolling in ball form; correlate logs during the Ctrl+F6 reproduction before deciding the cause.
2. **Investigate the red 300-point platform collision gap (KI #22)** on Donuts 2. Reproduce falling through the visible surface, then compare the rendered `snow_box` mesh and ODE collision mesh before changing geometry.
3. **Give `level_bowls1` a reasonable repeat test** for KI #1. The fix is applied but its intermittent nature makes verification take time; record the result and don't let a full 20-round test block the merge.
4. KI #16 (rare bot bouncing on `level_space_havoc`) is low priority and can remain documented unless it reproduces.

Done April 25:
- ~~KI #19 (snow particles on sun-themed gates)~~ ✅ Lua-only fix, `ShowSnow = 0` added to all 4 `level_gates_*.lua` files
- ~~KI #17a (i18n keys leaking to HUD on level_sun_extra_ball)~~ ✅ Replaced raw keys with English literals in `level_sun_extra_ball_server.lua`
- ~~KI #17b/c (scoreboard not live + score persists across rounds)~~ ✅ New `ScoreUpdate` network message broadcast from server's 50 Hz tick whenever any entity's `CurrentScore` changes. Per-round reset propagates automatically. Affected all gates, sun_extra_ball, donuts2.
- ~~KI #20 (gate AABB scores on frame hits / visual gate didn't move)~~ ✅ Two combined bugs: (a) `CGateProxy:setPosition` now also calls runtime `Module:setPos` so the visible mesh actually moves; (b) tightened trigger volume to `OpeningHalfExtents = CVector(0.05, 0.05, 0.05)`. Verified working on sun_extra_ball.

Done September 29:
- ✅ Played `level_gates_easy`, `level_gates_hard`, `level_gates_ramp`, and `level_gates_zig_zag`; gate-pass and landing scores worked on all four. The hard-level balance quirk remains documented. Near-miss/frame-graze behavior was not specifically tested.

Done September 30:
- ✅ Donuts 2 and MTP Paint awarded points; live HUD updates worked on both, and score reset correctly in both directions between the levels.
- ✅ Ctrl+F6 provides a repeatable way to trigger the Donuts 2 control-loss report.

### Merge to `main`
After the focused gameplay checks, open a PR from `wip/level-testing-feb-2026` to `main` and use CI as the final build check. The branch includes six commits on local `main` that are not currently in the local `origin/main` ref; refresh remotes and confirm the PR comparison before publishing. Do not tag a release as part of this merge; review the release workflow separately first.

### Accepted non-blocking issue
KI #18 (`level_city_destroy`'s 300-point target is unlandable) is documented and accepted. Keep the upstream geometry unchanged for this merge.

## Open higher-priority bugs (still to verify)

- **KI #1 — Intermittent scoring failure on `level_bowls1`.** Fix applied Feb 8 (Lunar metatable patch); still needs repeat playtesting. A full ~20-round test is useful but not a merge blocker.

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

The ignored build output currently has root-level shadow copies of `helpers.lua`, `level_bowls1_server.lua`, and `level_team_server.lua`. They match the canonical `data/lua/` copies; leave them alone during this pass and investigate their source/deployment behavior separately before removing them.

## Conventions

- Commit messages: `<verb> <what>` — present tense, imperative.
- Per-level fixes: small, focused commits straight to the branch.
- Larger / risky changes: branch first, PR to merge.
- Keep `docs/LEVELS.md` and `docs/KNOWN_ISSUES.md` accurate as you go.
