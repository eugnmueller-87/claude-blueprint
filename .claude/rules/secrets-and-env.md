# Secrets & Env

- **NEVER commit secrets.** API keys, tokens, passwords, connection strings, `SLACK_BOT_TOKEN`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` live in **environment variables only** — never in the repo, never in code, never in a committed `.env`.
- Read config via `os.environ["X"]` / `os.getenv` (Python), `process.env.X` (JS), `$env:X` (PowerShell), `$X` (bash). Fail loud with a clear message if a required var is missing — never silently default a credential.
- Commit `.env.example` with **keys only, empty values**. `.env`, `*.key`, `*.pem`, `secrets/` are git-ignored (this blueprint ships a `.gitignore`).
- Railway / n8n / CI: set secrets in the platform's env store, not in code or workflow JSON.
- Never print, log, or echo a secret — not even truncated — in output, tracebacks, or LLM prompts/traces.
- Rotate on any suspected leak; note the rotation, never the value.
