# Testing

- Verify behavior, not implementation. Don't assert mock call counts when output values would do.
- Run the specific test, not the suite: `pytest path/to/test_x.py::test_case -q` (JS: `npm test -- path`). Faster feedback, fewer tokens.
- Flaky test? Fix it or delete it. Never `@pytest.mark.flaky` or retry to make it pass.
- Prefer real implementations. Mock only at system boundaries: network, filesystem, clock, randomness, and every LLM/API call.
- Never hit a paid LLM/API in a unit test. Stub the client; record/replay fixtures (VCR-style) for integration tests, gated behind an env flag.
- One logical assertion per test. Name = behavior. Arrange-Act-Assert. No `if`/loops in tests — use `@pytest.mark.parametrize`.
- No `assert True`, no "was called" checks without verifying the arguments.
- Comprehensive test authoring goes to the `test-writer`/eval skill, not inline.
