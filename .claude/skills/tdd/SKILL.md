---
name: tdd
description: Drive a Python change test-first — red/green/refactor, one behavior at a time. Write the failing pytest, watch it fail, write the minimal code to green, then refactor with the test as a net. Use when building new behavior where the spec is clear enough to express as a test. Trigger phrases "do this test-first", "tdd this", "build this with tests first".
---

# tdd

Trigger: "do this test-first" / "tdd this" / "build this with tests first"

Standing rules: [`../_conventions.md`](../_conventions.md).

Design by test. Write the test before the code, one behavior per cycle. Never
skip the red step — a test you never saw fail proves nothing. Never write ahead
of the current failing test.

## Steps

1. **Pick ONE behavior.** State it as a single sentence: given X, when Y, then Z.
   If the ask has several behaviors, list them and do the first — one at a time.

2. **RED — write the failing test.** A real `pytest` test naming the behavior
   (`test_<behavior>`), Arrange-Act-Assert, one assertion. Run it: `pytest
   path/to/test_x.py::test_behavior`. Confirm it FAILS, and fails for the right
   reason (assertion, not an import error). Show the failure.

3. **GREEN — minimal code.** Write the least code that makes the test pass.
   Hardcode if that's genuinely the smallest step — the next test will force
   generality. Run the test: it passes. Show it green.

4. **REFACTOR — clean with the net.** Remove duplication, improve names, extract
   only if it earns its keep (no premature abstraction). Re-run the test file
   after each change; it stays green. No new behavior in this step.

5. **Loop or stop.** If more behaviors remain, go back to step 1 for the next
   one. Otherwise run the full test file once to confirm all green.

6. **Report** (terse): behaviors covered · tests added · all green (with the run
   output). Never report green you didn't watch pass.
