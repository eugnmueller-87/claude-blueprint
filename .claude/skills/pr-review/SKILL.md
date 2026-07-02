---
name: pr-review
description: Multi-lens review of the current diff — delegates to the code-reviewer, silent-failure-hunter, and security-reviewer agents, applies an 80%-confidence filter, and returns terse findings sorted by severity. Use before committing, before opening a PR, or on any diff that needs a real correctness pass. Trigger phrases "review this PR", "review the diff", "review my changes".
---

# pr-review

Trigger: "review this PR" / "review the diff" / "review my changes"

Standing rules: [`../_conventions.md`](../_conventions.md).

Catch real bugs, not style. Style is handled by the formatter/linter — don't
report it. Only ship findings you're at least 80% sure are real; drop the rest.
Lead with the single most important fix.

## Steps

1. **Get the diff.** `git diff --name-only` (working tree) or the staged diff if
   invoked mid-`ship`. If reviewing a GitHub PR, `gh pr diff <n>`. State what
   scope you're reviewing in one line.

2. **Delegate the lenses** (run the agents on the changed files):
   - `code-reviewer` — off-by-ones, null derefs, inverted logic, race
     conditions, complexity.
   - `silent-failure-hunter` — swallowed exceptions, bare `except:`, results
     ignored, `None` returned on error paths (huge in Python + agent code).
   - `security-reviewer` — only if the diff touches an API/auth/input boundary or
     handles credentials.

3. **Python/AI-specific passes** (do these yourself on top of the agents):
   - Bare `except:` or `except Exception: pass` — swallowed errors.
   - Mutable default arguments (`def f(x=[])`).
   - Un-awaited coroutines / blocking calls inside `async def`.
   - LLM calls with no timeout, no retry, or output parsed without a
     guard for refusals/truncation.
   - Secrets read from anywhere but env vars.

4. **Merge + filter.** Collapse duplicate findings across agents. Apply the ≥80%
   confidence filter. Drop anything pre-existing and outside the changed scope.

5. **Report** (terse): one line per finding, most severe first —
   `file:line: <issue> (fix: <hint>)`. End with one sentence naming the single
   most important fix. If nothing survives the filter, say the diff is clean —
   and only because you actually reviewed it.
