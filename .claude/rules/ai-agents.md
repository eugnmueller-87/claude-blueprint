---
paths:
  - "**/agents/**"
  - "**/tools/**"
  - "**/prompts/**"
  - "**/chains/**"
  - "**/graphs/**"
  - "**/llm/**"
  - "**/*_agent.py"
  - "**/*_prompt*.py"
  - "**/*.prompt"
  - "**/mcp/**"
---

# AI Agents & LLM Code

## Model & provider hygiene
- Never hardcode a model id, temperature, or max-tokens inline — read from config/env so models are swappable. When touching Claude/Anthropic code, confirm current model ids/limits via the `claude-api` skill; never answer model questions from memory.
- Set `max_tokens`, timeouts, and stop conditions explicitly on every call. No unbounded generations.

## Prompt hygiene
- Prompts live in versioned files/constants, not scattered inline f-strings. One source of truth per prompt.
- Clear role separation: system vs user vs tool messages. Put instructions in system, data in user. Never concatenate untrusted content into the system prompt (prompt-injection surface).
- Delimit injected data (tags/fences) and state that everything inside is data, not instructions.
- Deterministic tasks (extraction, classification, routing): `temperature=0`. Creative drafting: raise deliberately, document why.

## Tool-call reliability
- Tool schemas are strict and typed (pydantic / JSON schema); validate model-produced args before executing. Never trust arg types.
- Tools are idempotent where possible; side-effecting tools (send email, write file, place order) require an explicit confirm/guard flag, never auto-fire in a loop.
- Handle the "model called no tool / wrong tool / malformed args" path explicitly — retry-with-repair once, then fail loud.
- Cap agent loop iterations (max steps) and total tokens per run. No infinite ReAct loops.

## Token & cost discipline
- Log tokens-in/tokens-out and estimated cost per call/run behind a flag. Know what a run costs before shipping it.
- Cache/reuse: enable prompt caching for stable system prompts; dedupe identical calls; batch where the API allows.
- Trim context: retrieve only what's needed (see `rag-retrieval.md`), summarize long history, don't stuff whole documents.
- Cheapest model that passes eval wins; escalate to a stronger model only where evals prove it's needed.

## Structure & observability
- Structured output via tool-use/JSON-schema/pydantic parsing, not regex-scraping free text.
- Every agent run gets a run id; log inputs, tool calls, and outputs (secrets/PII redacted) for tracing.
- n8n / MCP: credentials in the platform's secret store; workflow/server JSON committed **without** secrets; keep node logic thin and testable.
