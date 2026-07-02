---
name: debug-fix
description: Root-cause a bug and fix it at the cause, not with a workaround — reproduce, isolate, apply the minimal fix, and prove it with a failing-then-passing test. Use when something is broken, throwing, or behaving wrong. Trigger phrases "debug this", "fix this bug", "why is this failing".
---

# debug-fix

Trigger: "debug this" / "fix this bug" / "why is this failing"

Standing rules: [`../_conventions.md`](../_conventions.md).

Fix the root cause, never a symptom. No workaround that hides the problem, no
adjacent refactor, no scope creep. Prove the fix with a test that fails before
and passes after. Never guess at the cause — reproduce it.

## Steps

1. **Reproduce first.** Get a deterministic repro: the exact command, input, or
   test that triggers it. Capture the real error output (full traceback for
   Python). If you can't reproduce it, STOP and say so — do not fix by guessing.

2. **Isolate.** Narrow to the smallest failing unit. Read the traceback bottom-up
   to the first frame in our code. Add a focused failing test (or a temporary
   assert/print) that pins the exact wrong behavior. Confirm the test fails for
   the right reason.

3. **Find the cause, state it.** Name the root cause in one sentence with
   `file:line` evidence — not the symptom. If two readings are possible, say
   which one you're acting on and why. Don't proceed on a hunch.

4. **Minimal fix at the cause.** Change the smallest thing that fixes the root
   cause. No swallowing the error to make it quiet. No touching unrelated code.

5. **Prove it.** Run the failing test — it now passes. Run the surrounding test
   file (not the whole suite, for speed) to confirm no regression. Show the
   before/after.

6. **Report** (terse): root cause · the one-line fix · test that now guards it.
   If the fix reveals a deeper design problem, name it and offer to file a
   follow-up — don't silently expand scope.
