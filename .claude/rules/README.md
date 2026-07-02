# Rules

Rules are modular instruction files that Claude Code loads automatically from `.claude/rules/`. They extend `CLAUDE.md` without bloating it.

- **No `paths:` frontmatter** — loaded every session, like `CLAUDE.md`. Costs tokens every turn, so keep it tight (budget: under ~30 lines each).
- **`paths: [...]` frontmatter** — loaded only when working near files matching the glob patterns. Free until you touch matched files.

This set is tuned for a **Python / AI-agent / procurement** stack (Python primary, some JS/TS, PowerShell + Bash on Windows/Git Bash; Claude & OpenAI APIs, LangChain/LangGraph, n8n, MCP, RAG; SQL/pandas/Power BI; procurement-AI domain). Push everything that doesn't actively change Claude's behavior into a path-scoped rule, an agent, or out entirely.

## The set at a glance

| Rule | Scope (loaded when) | Purpose |
|---|---|---|
| `code-quality.md` | Always | Anti-defaults, naming (JS + Python), code markers, file organization. |
| `testing.md` | Always | Behavior-first pytest/JS principles; never hit a paid API in a unit test. |
| `no-bullshit.md` | Always | Verify before claiming, no hedging, honest failure, ADHD-aware output contract. |
| `secrets-and-env.md` | Always | The #1 hard rule: secrets in env vars only, never in the repo. |
| `python-quality.md` | `**/*.py`, `pyproject.toml`, `requirements*.txt` | 3.11+, ruff, type hints, pathlib, uv, context managers, logging. |
| `error-handling.md` | Python + service/API/handler/agent/tool dirs | Typed errors, no swallowing, retry-with-backoff, no leaked traces. |
| `security.md` | Python + API/auth/agent/tool dirs | Input validation, parameterized SQL, no eval/pickle, LLM output is untrusted. |
| `ai-agents.md` | agent/tool/prompt/chain/graph/llm/mcp paths | Model/prompt hygiene, tool-call reliability, token+cost discipline, observability. |
| `rag-retrieval.md` | rag/retrieval/embeddings/vectorstore/ingest paths | Chunking, pinned embedding model, hybrid retrieval, provenance for citation. |
| `evals.md` | evals/eval/golden/llm-fixture paths | Golden set, property assertions, LLM-as-judge rules, scorecard-as-regression-gate. |
| `data-pandas-sql.md` | `*.sql`, `*.ipynb`, data/etl/analysis/pipeline paths | Parameterized SQL, dtype/NaN discipline, `Decimal` for money, reproducible transforms. |
| `db-migrations.md` | alembic/migrations/prisma/drizzle dirs | Never edit existing migrations, reversible, Alembic autogen is a draft. |
| `data-privacy-procurement.md` | data/supplier/spend/ingest/compliance paths | GDPR-relevant data, minimize before sending to LLMs, sourced compliance findings. |
| `shell-windows.md` | `*.ps1`, `*.sh`, `*.bat`, `*.cmd` | Git Bash + PowerShell 5.1 reality; hooks degrade gracefully if `jq` missing. |
| `frontend.md` | `*.tsx/*.jsx/*.vue/*.svelte/*.css/...`, component/page dirs | Design tokens, principle pick-list, accessibility (WCAG 2.1 AA), performance. |

Always-loaded: `code-quality`, `testing`, `no-bullshit`, `secrets-and-env`. Everything else is path-scoped and free until matched.

## Adding your own

Create a new `.md` file in this directory. With no frontmatter it loads every session:

```markdown
# Your Rule Name

- Your instructions here
```

Or path-scoped, so it only loads when Claude touches matching files:

```yaml
---
paths:
  - "src/your-area/**"
---

# Your Rule Name

- Instructions that only apply when touching these files
```

See [Claude Code docs](https://code.claude.com/docs/en/memory#path-specific-rules) for glob pattern syntax.
