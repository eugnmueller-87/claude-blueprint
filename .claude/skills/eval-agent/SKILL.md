---
name: eval-agent
description: Regression-test an LLM or agent workflow against a fixtures set — run each case, compare output to the expected/baseline, and flag drift, refusals, tool-call errors, and cost/latency changes. The test harness for prompt and agent changes where a normal unit test can't assert exact strings. Trigger phrases "eval this agent", "test the prompt", "did my prompt change break anything".
---

# eval-agent

Trigger: "eval this agent" / "test the prompt" / "check the agent didn't regress"

Standing rules: [`../_conventions.md`](../_conventions.md).

An LLM change can't be judged by exact-string assertions — you judge it against
cases. Run the eval set, compare to baseline, report drift honestly. Never claim
"no regression" without having actually run the cases. If there's no eval set
yet, say so and offer to scaffold one — don't fake a pass.

## Steps

1. **Find the harness.** Look for an existing eval set: `evals/`, `tests/evals/`,
   a `cases.jsonl` / `fixtures/`, or a promptfoo / `langsmith` / pytest eval file.
   If none exists, STOP and offer to scaffold: a `cases.jsonl` (each line = input
   + expected-behavior + optional gold output) plus a runner. Don't invent
   results from a set that doesn't exist.

2. **Confirm provider + model.** Read the code for the actual client
   (`anthropic` / `openai` / a LangChain wrapper) and the exact model id — do not
   assume. If it's Anthropic/Claude, consult the `claude-api` reference for the
   current model id and pricing before reasoning about cost.

3. **Run the cases** against the CURRENT prompt/agent. Capture per case: output,
   tool calls made, tokens in/out, latency, any refusal or error. Keys come from
   env vars only — if a key is missing, STOP and name the env var to set. Never
   hardcode.

4. **Compare to baseline.** Diff each case against the stored expected behavior:
   - Behavioral pass/fail (did it do the right thing?), not string-equality.
   - New refusals or truncations that weren't there before.
   - Tool-call changes (wrong tool, missing call, malformed args).
   - Cost / latency delta vs baseline (flag if materially up).

5. **Report** (terse table): N cases · X pass / Y fail · new refusals · tool
   errors · cost delta. List each FAILING case as `input → expected → actual`.
   End with the single most important regression to fix. If everything passed,
   say so plainly — and only because you ran it.

6. **Offer to update the baseline** only if the new behavior is intended and
   Eugen confirms. Never silently overwrite the gold set.
