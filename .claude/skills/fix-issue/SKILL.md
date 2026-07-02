---
name: fix-issue
description: Take a GitHub issue from read to closed — pull the issue, plan the fix, implement it on a feature branch, and open a PR that references and closes the issue. Use when working a tracked issue by number. Trigger phrases "fix issue #N", "work issue N", "take issue #N".
---

# fix-issue

Trigger: "fix issue #N" / "work issue N" / "take issue #N"

Standing rules: [`../_conventions.md`](../_conventions.md).

Close the loop cleanly: understand the issue, fix the real cause, land a PR that
links back. Don't guess what the issue means — read it. Don't push to main.

## Steps

1. **Read the issue.** `gh issue view <n>`. Extract: what's actually being asked,
   the expected vs actual behavior, any repro steps, and acceptance criteria. If
   the issue is ambiguous or underspecified, say what's unclear and ask before
   building the wrong thing.

2. **Plan.** State in 2–3 bullets how you'll fix it and which files you expect to
   touch. If it's a bug, plan to reproduce first (hand off to
   [`debug-fix`](../debug-fix/SKILL.md)). If it's a feature, consider
   [`tdd`](../tdd/SKILL.md).

3. **Branch.** `git switch -c fix/<n>-<short-desc>` (or `feat/<n>-...`). Never
   work an issue directly on main.

4. **Implement.** Make the change at the root cause. Add or update tests that
   encode the issue's acceptance criteria — the test is proof the issue is fixed.
   Run them; show green.

5. **Land it via [`ship`](../ship/SKILL.md).** The PR body must reference the
   issue so it auto-closes: include `Closes #<n>`. State what changed, why, and
   the test evidence.

6. **Report** (terse): issue summary · branch · what you changed · PR url with
   `Closes #<n>`. If you couldn't fully resolve it, say exactly what's left —
   honestly.
