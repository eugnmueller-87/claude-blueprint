---
name: refactor
description: Behavior-preserving cleanup of a target guarded by the existing test suite — improve names, cut duplication, reduce nesting, without changing what the code does and without touching adjacent code. Use to clean up working code, never to add features. Trigger phrases "refactor X", "clean this up", "tidy this code".
---

# refactor

Trigger: "refactor X" / "clean this up" / "tidy this code"

Standing rules: [`../_conventions.md`](../_conventions.md).

Refactoring changes structure, never behavior. The test suite is the proof it
stayed the same. No scope creep, no adjacent rewrites, no new features slipped in.
If there are no tests, that's the blocker — say so.

## Steps

1. **Establish the safety net.** Run the tests covering the target and confirm
   they pass FIRST. If the target has no tests, STOP and say so — offer to run
   [`test-writer`](../test-writer/SKILL.md) to add a characterization test before
   refactoring. Never refactor blind.

2. **Scope it tight.** Name exactly what you're cleaning and what you are NOT
   touching. One target. Don't wander into adjacent modules "while you're here".

3. **Refactor in small steps**, re-running the tests after each:
   - Rename for clarity (names that lie, generic `data`/`tmp`, missing `is_`/`has_`).
   - Cut duplication that has actually recurred (not speculative abstraction).
   - Flatten nesting with early returns (>3 levels deep).
   - Split god-functions doing read+validate+transform+persist+notify.
   - Python: prefer `pathlib` over `os.path`, comprehensions over manual loops
     where clearer, `logging` over `print`, type hints on public signatures.
   Behavior stays identical at every step.

4. **Prove no behavior changed.** Full relevant test file green, same as step 1.
   Run `ruff check .` — no new lint. If a test had to change, behavior changed —
   STOP and flag it, that's not a refactor.

5. **Report** (terse): what you cleaned · tests green before and after · lines/
   complexity reduced. Confirm zero behavior change, backed by the test run.
