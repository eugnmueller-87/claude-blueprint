# Skills

Skills are reusable workflows Claude *runs* on request. Each lives in its own
directory as `.claude/skills/<name>/SKILL.md` with YAML frontmatter (`name` +
`description`). The `description` is the routing signal — Claude auto-selects a
skill when your request matches it, so descriptions here front-load the trigger
phrases.

Skills are workflows, **not** enforcement. The hard guards (secret scanning,
dangerous-command blocking, file protection) live in `.claude/hooks/` and run
automatically regardless of which skill is active. Skills assume those guards
exist and never re-implement them.

Every skill in this blueprint obeys the four standing rules in
[`_conventions.md`](_conventions.md): lead with the answer, verify before
claiming done, report failure honestly, never guess. Read that file once — it is
referenced (not copy-pasted) by every SKILL.md.

## Tiers

**CORE** — ships in every project seed. Stack-agnostic.

| Skill | Say | Does |
|---|---|---|
| [setup-project](setup-project/SKILL.md) | "set up this project" | Bootstrap `.claude/` into a repo: detect stack, tune CLAUDE.md + rules, wire hooks, write the drift fingerprint. |
| [ship](ship/SKILL.md) | "ship it" | Branch → lint/typecheck/test → self-review → conventional commit → push → PR. Refuses to push to main. |
| [pr-review](pr-review/SKILL.md) | "review this PR" | Multi-lens review of the diff via the review agents, 80%-confidence filter, terse findings. |
| [debug-fix](debug-fix/SKILL.md) | "debug this" | Reproduce → isolate → minimal fix at the cause → prove with a failing-then-passing test. |
| [explain](explain/SKILL.md) | "explain this" | Fast orientation on unfamiliar code: entry points, data flow, the 3 files that matter. |
| [catchup](catchup/SKILL.md) | "catch me up" | ADHD re-entry: reads git state + diff + TODOs and restates the ONE next action. |
| [claude-md](claude-md/SKILL.md) | "update the project memory" | Audit & tighten CLAUDE.md against reality: commands work, under the cap, no stale decisions. |
| [context-budget](context-budget/SKILL.md) | "trim the context" | Report what loads every turn and cut bloat into path-scoped rules or agents. |

**STACK** — ships in Python/AI projects by default (nearly all of them).

| Skill | Say | Does |
|---|---|---|
| [tdd](tdd/SKILL.md) | "tdd this" | Red-green-refactor for Python: failing pytest first, minimal code to green, refactor. |
| [test-writer](test-writer/SKILL.md) | "write tests for X" | Real pytest tests (behavior, edge cases, no mock theater) for a target module. |
| [refactor](refactor/SKILL.md) | "refactor X" | Behavior-preserving cleanup guarded by the test suite. No scope creep. |
| [fix-issue](fix-issue/SKILL.md) | "fix issue #N" | Pull a GitHub issue, plan, implement on a branch, close the loop with a PR. |
| [eval-agent](eval-agent/SKILL.md) | "eval this agent" | Regression-test an LLM/agent workflow against fixtures: drift, refusals, tool errors, cost. |
| [trace-agent](trace-agent/SKILL.md) | "trace this run" | Debug a LangChain/LangGraph/tool-use run: dump the step trace, find where it diverged. |
| [secrets-check](secrets-check/SKILL.md) | "check for secrets" | On-demand full-repo secret sweep — manual complement to the scan-secrets hook. |
| [db-query](db-query/SKILL.md) | "query the spend data" | Read-only SQL/pandas exploration of spend/supplier data. No writes without opt-in. |

**OPTIONAL** — wire in per project. Discoverable stubs under
[`optional/`](optional/), not loaded by default.

| Skill | Say | Does |
|---|---|---|
| [deploy-check](optional/deploy-check/SKILL.md) | "check the deploy" | Pre/post-deploy sanity for Railway/Vercel: env vars, health endpoint, clean logs. |
| [perf-scan](optional/perf-scan/SKILL.md) | "find the slow parts" | Real bottlenecks (N+1, blocking async, unbatched API calls, pandas full-scans). |
| [data-contract](optional/data-contract/SKILL.md) | "validate the data" | Validate a dataframe/CSV/API payload against an expected schema before a pipeline. |

## Adding your own

Copy the shape of any SKILL.md: frontmatter with `name` + a trigger-rich
`description`, then a body that opens with a `Trigger:` line, a one-paragraph
role, and a numbered **Steps** list. Keep steps concrete and verifiable.
