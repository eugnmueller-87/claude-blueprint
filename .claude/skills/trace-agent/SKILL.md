---
name: trace-agent
description: Debug a single LangChain / LangGraph / tool-use agent run — dump the step and tool-call trace, find where it diverged from the intended path, and isolate the bad prompt, tool, or state. Use when an agent did the wrong thing and you need to know why. Trigger phrases "trace this run", "why did the agent do that", "debug this agent run".
---

# trace-agent

Trigger: "trace this run" / "why did the agent do that" / "debug this agent run"

Standing rules: [`../_conventions.md`](../_conventions.md).

An agent went wrong on one run. Find the exact step where it diverged — don't
theorize from the top. Read the actual trace. If it's an intermittent LLM
issue, say so rather than inventing a deterministic cause.

## Steps

1. **Get the trace.** Find how this project records runs: LangSmith, a LangGraph
   checkpoint/thread, structured logs, or a captured transcript. If tracing isn't
   on, STOP and offer to enable it (LangSmith env vars, a callback handler, or a
   run logger) — don't reconstruct a run from imagination.

2. **Confirm the setup.** Model id and provider (read the client code — don't
   assume), the system prompt, the tool schemas the agent had, and the input for
   this run. For Claude, check the `claude-api` reference for tool-use behavior.

3. **Walk the steps in order.** For each step capture: the model's reasoning/
   output, which tool it called, the args, the tool result, and the resulting
   state. Mark the FIRST step where it diverged from what should have happened.

4. **Isolate the cause at the divergence point.** One of:
   - Prompt — ambiguous/missing instruction let the model choose wrong.
   - Tool schema — bad description or arg names misled the tool choice.
   - Tool result — the tool returned wrong/empty data and the agent trusted it.
   - State — stale or wrong context carried into the step.
   - Parsing — malformed model output mis-parsed downstream.
   Name which, with evidence from the trace.

5. **Report** (terse): where it diverged (step N) · the cause · the minimal
   change to fix it · whether it's deterministic or a sampling issue. If the fix
   is a prompt/tool change, offer to run [`eval-agent`](../eval-agent/SKILL.md)
   after to confirm no regression.
