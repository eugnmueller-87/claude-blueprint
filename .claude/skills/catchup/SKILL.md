---
name: catchup
description: Re-orient after a break — read git state, the recent diff, and open TODO/FIXME markers, then restate in plain language what this branch is doing and the ONE next action. External working memory for when the thread was dropped. Trigger phrases "catch me up", "what was I doing", "where was I".
---

# catchup

Trigger: "catch me up" / "what was I doing" / "where was I"

Standing rules: [`../_conventions.md`](../_conventions.md).

Eugen dropped this thread and is coming back cold. Your job is external working
memory: reconstruct the state and hand back the ONE next step. Lead with the
answer. Short and concrete — no wall of text, no ten open tabs.

## Steps

1. **Read state (don't ask, look):**
   - `git branch --show-current` and `git log --oneline -5` — branch + recent
     commits.
   - `git status -s` and `git diff --stat` — what's uncommitted right now.
   - Grep the diff and changed files for `TODO` / `FIXME` / `HACK` markers.
   - If a PR exists for the branch: `gh pr view` for its state and checks.

2. **Reconstruct the intent.** From the branch name, commit messages, and the
   shape of the uncommitted diff, state in ONE sentence what this work is trying
   to do. If it's genuinely ambiguous, say "I can't tell from the code whether X
   or Y" — don't invent a narrative.

3. **Find the edge.** Identify where work stopped: a half-finished function, a
   failing or pending test, a TODO, an unpushed commit. This is the re-entry
   point.

4. **Report — this exact shape, nothing else unless asked:**
   - **Branch:** `<name>` (`<clean | N files uncommitted>`)
   - **Doing:** `<one sentence>`
   - **Stopped at:** `<the edge>`
   - **Next 5-min step:** `<the single lowest-activation-energy action>`

   Do not open ten threads — surface the one that matters and offer to park the
   rest in the inbox.
