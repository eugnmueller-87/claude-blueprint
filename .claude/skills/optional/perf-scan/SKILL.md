---
name: perf-scan
description: Find the real performance bottlenecks in a target — N+1 queries, blocking calls inside async, unbatched API/LLM calls, and pandas full-scans — delegating to the performance-reviewer agent. Use when something is slow or before scaling a hot path. Trigger phrases "find the slow parts", "profile this", "why is this slow".
---

# perf-scan

Trigger: "find the slow parts" / "profile this" / "why is this slow"

Standing rules: [`../../_conventions.md`](../../_conventions.md).

Find bottlenecks that actually matter on the hot path — not micro-optimizations.
Measure or read the evidence; never guess where the time goes. Lead with the
single biggest win.

## Steps

1. **Scope the hot path.** What's actually slow — a request, a batch job, an agent
   run, a dataframe transform? Focus there. If a profile is available (`cProfile`,
   a flame graph, timing logs), read it first — real data beats intuition.

2. **Delegate the code lens.** Run the `performance-reviewer` agent on the target
   files for algorithmic and structural issues.

3. **Python/AI/data-specific passes** (do these on top):
   - N+1: a query or API/LLM call inside a loop that could be batched.
   - Blocking I/O inside `async def` (sync `requests`, sync DB driver, `time.sleep`).
   - Unbatched LLM calls where a single batched/parallel call would do.
   - pandas: `iterrows()`/`apply` where a vectorized op works; repeated full-frame
     scans; copies where a view suffices.
   - Repeated recomputation that could be cached/memoized.
   - Unbounded data pulled into memory when a stream/chunk would do.

4. **Rank by impact.** Estimate which change buys the most — the loop-of-calls
   usually dwarfs everything. Don't list ten micro-fixes; name the top few that
   matter.

5. **Report** (terse): the top bottleneck first — `location: <problem> (fix:
   <approach>, est. impact)`. End with the single highest-leverage change. If you
   couldn't measure it, say the finding is from reading code, not a profile —
   honestly.
