---
name: explain
description: Fast orientation on unfamiliar code — find the entry points, trace the data flow, name the 3 files that actually matter, and explain it in plain language. Use when landing in a new repo or module and needing the mental model before touching anything. Trigger phrases "explain this", "how does X work", "walk me through this code".
---

# explain

Trigger: "explain this" / "how does X work" / "walk me through this code"

Standing rules: [`../_conventions.md`](../_conventions.md).

Give Eugen the mental model fast, in plain voice — no corporate filler, no
restating the obvious. Lead with the one-sentence "what this is". Never invent
behavior you didn't read; if the code is ambiguous, say so.

## Steps

1. **Find the entry points.** Locate where execution starts: `__main__`, a CLI
   `argparse`/`click` command, a FastAPI/Flask app, a bot handler, a
   LangGraph/agent graph definition, or the public functions a caller imports.

2. **Trace the main data flow.** Follow ONE representative path end to end: input
   → transform → the core work (the API call, the query, the agent step) →
   output. Read the actual code; note where state or side effects live.

3. **Name the 3 files that matter.** The ones you'd have to understand to change
   anything real. Skip config, tests, and glue. Say what each one owns.

4. **Surface the non-obvious.** Anything a newcomer would trip on: a hidden
   coupling, an implicit contract, a "why is it done this way" decision, a place
   that reads env vars, a spot where errors are swallowed.

5. **Report** (terse):
   - **What it is:** one sentence.
   - **Flow:** input → … → output, in 3–5 arrows.
   - **The 3 files:** `path` — what it owns.
   - **Watch out for:** the non-obvious bits.
   End with: "To change `<the thing you'd likely want>`, start in `<file>`."
