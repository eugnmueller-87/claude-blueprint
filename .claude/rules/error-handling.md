---
paths:
  - "**/*.py"
  - "src/api/**"
  - "src/services/**"
  - "**/controllers/**"
  - "**/routes/**"
  - "**/handlers/**"
  - "**/agents/**"
  - "**/tools/**"
---

# Error Handling

- Custom exception classes with codes, not bare `Exception("failed")` / `Error("something went wrong")`.
- **Never swallow errors** (`except: pass` is banned). Log with context (what operation, which input) or re-raise with `raise ... from e` to keep the chain.
- Handle every rejected promise / awaited call. No fire-and-forget async (`asyncio.create_task` without awaiting/collecting, floating JS promises).
- API responses: consistent shape `{"error": {"code", "message"}}`, correct status (400 validation, 401 auth, 404, 429 rate limit, 500). FastAPI/Flask: exception handlers, not try/except in every route.
- Never leak stack traces, file paths, raw DB errors, or **raw LLM/tool errors** to end users or clients.
- **Retry transient failures** (network timeout, 429, 5xx from Anthropic/OpenAI) with exponential backoff + jitter and a max-attempt cap. **Fail fast** on validation, auth, and 4xx-non-429 — don't retry.
- Include a correlation/request/run ID in logs when available (ties to agent-run tracing).
