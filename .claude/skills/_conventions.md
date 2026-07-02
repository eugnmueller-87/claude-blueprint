# Skill conventions

These four rules apply to **every** skill in this blueprint. Each SKILL.md
references this file instead of restating them — keeps the blueprint DRY and
token-cheap. When you run any skill, hold these standing:

1. **Lead with the answer / smallest next step.** (ADHD-aware.) Open with the one
   thing that matters — the result, the fix, or the single next action. Detail
   after, in bullets. No preamble, no "great question", no wall of text.

2. **Verify before claiming done.** (No-bullshit.) Never report a gate passed, a
   test green, or a change shipped unless you actually ran it and saw it pass.
   "Should work" is banned. If you didn't run it, say you didn't.

3. **Report failure honestly.** When something fails, STOP at the failure, show
   the real output, name the single most likely fix. No hedging ("try", "maybe",
   "hopefully"), no papering over, no silent workaround. A blocked step reported
   straight is worth more than a fake success.

4. **Never guess.** (Never-guess.) Detect facts from real files, real command
   output, real docs — never assume a command, version, path, model id, or API
   shape. If you can't verify, say "I don't know yet" and mark it a TODO. For
   anything Claude/Anthropic-related, consult the `claude-api` reference rather
   than answering from memory.

## Stack defaults (this blueprint is Python/AI-first)

- **Primary:** Python. Test runner `pytest`; formatter/linter `ruff` (fallback
  `black` + `isort`); type checker `mypy` when configured. Package manager `uv`
  or `pip`. Always detect the real tooling from `pyproject.toml` first — don't
  assume.
- **Also present:** some JS/TS (read `package.json` `scripts`), PowerShell, Bash.
- **AI/agents:** Claude & OpenAI APIs, LangChain/LangGraph, n8n, MCP servers, RAG.
- **Data:** SQL, pandas, Power BI. Procurement-AI domain — spend, suppliers,
  negotiation, compliance (LkSG / CSDDD).
- **OS:** Windows (win32) + Git Bash. Any shell shown in a skill step is POSIX
  `sh` runnable under Git Bash. PowerShell-only commands are marked as such.

## Secrets — non-negotiable

Secrets come from environment variables, never repo literals. Never read, write,
print, or commit a real key. The `scan-secrets` and `protect-files` hooks guard
writes automatically; skills still re-check any diff they touch. If a key is
missing, STOP and name the env var to set — never hardcode a placeholder that
looks real.
