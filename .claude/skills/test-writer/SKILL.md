---
name: test-writer
description: Backfill real pytest coverage for an existing Python module — behavior not implementation, the edge cases that actually break, no assertion-free tests and no mock theater. Use to add tests to code that already works but is under-tested. Trigger phrases "write tests for X", "add tests", "cover this module".
---

# test-writer

Trigger: "write tests for X" / "add tests" / "cover this module"

Standing rules: [`../_conventions.md`](../_conventions.md).

Write tests that would actually catch a regression, not tests that just execute
lines. Test behavior and contracts, not internals. Never write `assert True` and
never assert only that a mock was called without checking its arguments.

## Steps

1. **Read the target and its contract.** What are the public functions/classes?
   For each: inputs, outputs, side effects, and the documented or implied
   behavior. Note what's a real boundary (network, filesystem, clock, LLM API,
   DB) vs pure logic.

2. **Enumerate cases** before writing any:
   - Happy path — the normal expected use.
   - Edge cases — empty input, `None`, zero, boundary values, empty collection,
     duplicates, unicode.
   - Error cases — invalid input raises the right exception; failure paths.
   - For AI code: a refusal/truncated response, malformed JSON from the model, a
     tool-call error.

3. **Write pytest tests.** One assertion per test, Arrange-Act-Assert, names that
   describe behavior (`test_returns_empty_list_when_no_suppliers_match`). Use
   `pytest.mark.parametrize` for the same behavior across inputs. Use fixtures for
   shared setup.

4. **Mock only at boundaries.** Real implementations everywhere possible. Mock the
   network/LLM/DB/clock/randomness only — and when you mock, assert on the
   arguments passed, not just call count. No mocking of the code under test.

5. **Run them.** `pytest path/to/test_x.py`. All pass. Then deliberately break the
   source once to confirm a test actually fails (a test that can't fail is
   worthless) — then restore.

6. **Report** (terse): cases covered · tests added · run result. Name any behavior
   you could NOT test and why (e.g. needs a live key) — honestly, don't fake it.
