---
name: ship
description: Land the current change end to end — branch if needed, run lint/typecheck/tests, self-review the diff, make a conventional commit, push, and open a PR. Refuses to push to main/master. Reports honestly if any gate fails and stops. Trigger phrases "ship it", "ship this", "land this change".
---

# ship

Trigger: "ship it" / "ship this" / "land this change"

Standing rules: [`../_conventions.md`](../_conventions.md).

Land the change cleanly. Every gate must actually pass — never report "shipped"
if a step failed. If a gate fails, STOP at that gate, show the real failure, and
give the one fix to try. No hedging, no "should be fine".

## Steps

1. **Branch guard.** `git branch --show-current`. If on `main`/`master`, create a
   feature branch first: `git switch -c <type>/<short-desc>` (type = feat / fix /
   chore / refactor). The `block-dangerous-commands` hook also refuses a push to
   main — this is the friendly first line.

2. **Scope check.** `git diff --stat`. If the diff spans unrelated concerns, say
   so and offer to split — don't silently ship a mixed bag.

3. **Quality gates** (run, capture output, STOP on first failure):
   - Format: `ruff format .` (Python) or the detected formatter.
   - Lint: `ruff check .` (Python) / `npm run lint` (JS).
   - Types: `mypy .` (if configured) / `npm run typecheck`. Skip cleanly if the
     project has no type checker — say you skipped it.
   - Tests: `pytest` (Python) / `npm test`. Run the FULL suite before a ship.
   If any gate fails: print the failing output, name the fix, STOP. Do not commit.

4. **Self-review.** Run the [`pr-review`](../pr-review/SKILL.md) skill on the
   staged diff. Fix any correctness finding at ≥80% confidence before committing.
   Don't ship over a known real bug.

5. **Secret sweep.** Re-check the staged diff for secrets (the `scan-secrets`
   hook guards writes, but confirm here): keys must come from env vars, never
   literals. If anything looks like a real key, STOP.

6. **Commit.** Conventional commit, imperative subject, WHY in the body. End the
   message with:

   ```
   Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
   ```

7. **Push + PR.** `git push -u origin <branch>` then `gh pr create` with a body
   that states what changed and why, plus the test evidence from step 3. End the
   PR body with:

   ```
   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   ```

8. **Report** (terse): branch · gates passed (with actual pass counts) · PR url.
   If you stopped early, report exactly which gate and why — honestly.
