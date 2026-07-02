# Agents

Agents are specialized Claude instances that run in **isolated context**. They don't see your conversation history or loaded rules. They only have their own system prompt and tools.

Claude delegates to agents automatically based on the task description, or you can invoke them with `@agent-name`.

Every reviewer is **read-only** (`Read, Grep, Glob, Bash`) — isolation is the point, so a reviewer can never edit the code it's judging. Only `frontend-designer` has `Write`/`Edit`, because its job is to generate UI files.

## Available agents

Listed core-first: the first three run on virtually every code review; the middle group activates when its subject appears in the diff; `frontend-designer` is optional (UI only).

### code-reviewer
General bug catcher for Python (primary), JS/TS, PowerShell, and Bash. Catches off-by-ones, None/null derefs, inverted conditions, race conditions, swallowed errors, and excessive complexity — with Python-specific traps (mutable default args, late-binding loop closures, `is` vs `==`) and shell traps (`$?`/`$LASTEXITCODE` after a redirected native exe, unquoted Windows paths, missing `set -euo pipefail`). Skips style nitpicks. Trigger: after any code change, before committing.

### silent-failure-hunter
Hunts the one bug class worse than a crash: code that fails without telling anyone. Empty `except`, errors masked as `[]`/`None`/empty DataFrame, floating `asyncio` tasks, `errors='coerce'`/`fillna(0)` that hides bad input, ignored exit codes in nightly `.ps1`/n8n steps. For each error path it asks: if this fails in production, who finds out? Trigger: any change to error handling, fallbacks, retries, async, or pipeline steps.

### pr-test-analyzer
Judges whether a diff's **pytest** tests actually verify the change — test critique, not test generation. Catches assertion-free tests, mock theater (mocking your own unit vs. mocking the LLM/DB boundary), tests that can't fail, `@pytest.mark.skip` left in, and weakened tolerances. Includes the AI angle: a changed prompt/chain with no test asserting the parsed output. Core question: if the implementation were wrong, would any test go red? Trigger: a diff adds/changes tests, or changes behavior without touching tests.

### security-reviewer
OWASP-style static analysis tuned to Python and the **NEVER-commit-secrets** rule. Secrets are category one: hardcoded `ANTHROPIC_API_KEY`/`OPENAI_API_KEY`/`SLACK_BOT_TOKEN`/`TELEGRAM_TOKEN`, `.env`/`*.pem` staged in the diff. Plus SQL f-string injection, `subprocess(shell=True)`, `pickle`/`yaml.load` on untrusted data, weak crypto, and missing rate limits on the Telegram bot. Severity-ranked with attack vector and fix. Trigger: changes to auth, input handling, queries, subprocess, deserialization, or crypto. Belt-and-suspenders with the `scan-secrets` hook.

### ai-agent-reviewer
Reviews LLM / agent / RAG **code** (Claude & OpenAI APIs, LangChain/LangGraph, n8n AI nodes, MCP servers). Checks prompt-injection exposure (untrusted content in the system prompt), tool-call safety (model args reaching subprocess/SQL, ungated destructive tools), token/cost control (missing `max_tokens`, unbounded agent loops), API reliability (timeouts, retry/backoff, truncated-response handling), structured-output/hallucination guards, and eval coverage. Does not assert current model ids — it instructs the reviewer to verify them. Trigger: changes to prompts, LLM calls, agent/tool definitions, or RAG pipelines.

### procurement-domain-reviewer
Sanity-checks procurement business logic across TrueSpend, SpendLens, Hades, Hermes, SCM-Master. Catches wrong savings math (wrong baseline, flipped sign, wrong percentage base), broken baselines (silent 0 → fake savings), currency/unit errors (missing FX, net-vs-gross, UoM mismatch, pre-aggregation rounding), skewed supplier scoring, and fail-open compliance checks (LkSG/CSDDD/sanctions that log but don't block). States both readings rather than guessing a domain rule. Trigger: changes to savings/spend calculations, supplier scoring, quote normalization, or compliance checks.

### data-pipeline-reviewer
Catches silent data-correctness bugs in pandas/SQL pipelines feeding the tools and Power BI. Covers coercion to NaN with no count, `merge` fan-out that inflates totals, `NaN→0` fabricating spend, non-deterministic `drop_duplicates`, dtype/German-locale parsing drift, and Power BI handoff breakage (renamed columns, number-as-string). Correctness lens (right numbers), distinct from performance-reviewer's speed lens. Trigger: changes to ETL, joins, aggregations, dedupe, or feed prep. *Optional/foldable* — its checks can fold into silent-failure-hunter for a leaner set.

### performance-reviewer
Finds real bottlenecks, not theoretical micro-optimizations, in backend/data code. Covers database (N+1, missing indexes, `SELECT *`, unbounded queries), pandas/data anti-patterns (`iterrows`/row-wise `.apply` vs vectorization, quadratic `df.append`, unindexed merges, loading whole files), memory, network/I-O (sequential awaits, missing timeouts, retry/backoff), and concurrency. Frontend perf is handed off. Trigger: changes to hot paths, endpoints, queries, or loops over collections.

### doc-reviewer
Reviews documentation for accuracy (do docs match the Python source?), completeness (are required params and **env vars** documented?), staleness, and clarity. Cross-references docs against source with grep and file reads; catches env-var drift between README and `os.environ` lookups. Trigger: after `.md`/docstring/README changes, or when code changes may have invalidated docs.

### frontend-designer (optional — UI only)
Creates distinctive, production-grade UI. Finds or creates design tokens first, picks a design principle, states its plan, then builds components. Has `Write` and `Edit` so it actually generates files. Anti-AI-slop aesthetics built in. **Include this agent when a seeded project has a web UI (e.g. a SpendLens dashboard); omit it for pure-backend / CLI / data seeds.**

## Adding your own

Create a directory per agent — `agents/<name>/<name>.md` (Claude Code scans agents directories recursively; one dir per agent is what lets the plugin marketplace symlink each agent individually):

```yaml
---
name: your-agent-name
description: When Claude should delegate to this agent
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

Your agent's system prompt here.
```

See [Claude Code docs](https://code.claude.com/docs/en/sub-agents) for all frontmatter options.
