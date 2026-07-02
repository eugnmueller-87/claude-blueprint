---
name: claude-md
description: Audit and tighten this project's CLAUDE.md against reality — confirm the documented commands actually run, keep it under the line cap, and strip stale decisions or duplicated code style. Use when CLAUDE.md has drifted, grown bloated, or after the stack changed. Trigger phrases "update the project memory", "fix CLAUDE.md", "audit the project instructions".
---

# claude-md

Trigger: "update the project memory" / "fix CLAUDE.md" / "audit the project instructions"

Standing rules: [`../_conventions.md`](../_conventions.md).

CLAUDE.md loads every single turn — every line costs tokens forever. Keep it
true, tight, and load-bearing. Never document a command you haven't run. Lead
with what you changed.

## Steps

1. **Read the current CLAUDE.md** and count non-blank lines. Hard cap 50, target
   25. If over, that's the first thing to fix.

2. **Verify every command.** Run each command in the Commands section once
   (lint, test, typecheck, build, dev). Any that fails or no longer exists →
   fix the line to match reality or delete it. Never leave a command that doesn't
   run. Detect the truth from `pyproject.toml` / `package.json`, don't guess.

3. **Cut duplication and bloat:**
   - Code style rules → belong in `rules/code-quality.md`, not here. Remove.
   - Path-specific guidance → belongs in a path-scoped rule. Move it.
   - Anything Claude can discover by exploring (file lists, obvious structure) →
     delete.
   - Keep only: real commands, non-obvious architecture, and WHY-decisions.

4. **Check the Key Decisions section is current.** Stale decisions that no longer
   hold are worse than none — they mislead. Flag any that contradict the current
   code; confirm with Eugen before rewriting a decision (that's his call).

5. **Report** (terse): line count before → after · commands verified (pass/fail)
   · what you cut or moved · anything flagged for his sign-off. End with the one
   remaining thing to tighten, if any.
