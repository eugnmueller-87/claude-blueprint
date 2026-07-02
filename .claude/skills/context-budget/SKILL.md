---
name: context-budget
description: Report what loads into context every turn — CLAUDE.md plus always-on rules — and cut the bloat by pushing content into path-scoped rules or agents. Use when the project feels token-heavy, responses feel unfocused, or after several rules were added. Trigger phrases "trim the context", "what's costing tokens", "audit the context budget".
---

# context-budget

Trigger: "trim the context" / "what's costing tokens" / "audit the context budget"

Standing rules: [`../_conventions.md`](../_conventions.md).

Everything that loads every turn is a permanent tax. The goal is a small, always-
on core plus rules that load only near the code they govern. Lead with the total
and the biggest cut.

## Steps

1. **Inventory what's always on:**
   - `CLAUDE.md` — count non-blank lines.
   - Every file in `.claude/rules/` WITHOUT `paths:` frontmatter — these load
     every turn. Count lines each.
   - Note which rules HAVE `paths:` frontmatter — these are free until near
     matching files; leave them.
   Report the always-on total in lines.

2. **Find the bloat.** For each always-on file, ask: does this actively change
   Claude's behavior on most turns? If not, it belongs elsewhere:
   - Path-specific guidance → give it `paths:` frontmatter (loads only near
     matching files).
   - A big review checklist → move it into an agent (loads only when invoked).
   - Discoverable facts / stale content → delete.

3. **Check for dead path-scoped rules.** A rule scoped to `**/*.tsx` in a repo
   with no TSX files is pure noise on disk — flag it for removal.

4. **Propose the cuts** as a checklist, biggest saving first: file · current
   lines · action (scope / move-to-agent / delete) · lines saved. Don't apply
   destructive edits to `.claude/` structure without Eugen's OK — this is a
   NEEDS-SIGN-OFF class change.

5. **Report** (terse): always-on total before → projected after · the single
   biggest cut · the checklist. Apply only what he approves.
