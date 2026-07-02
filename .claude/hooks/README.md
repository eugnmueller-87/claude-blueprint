# Hooks

Hook scripts are **deterministic enforcement**. Unlike rules (advisory), hooks *guarantee* behavior by blocking or modifying tool calls before or after they run. They are the load-bearing layer of Eugen's hard rules — chiefly **never commit secrets** and the **git safety rails**.

Hooks are wired in `.claude/settings.json` under the `"hooks"` key. Each hook has an event, a matcher, and a command. `timeout` values are in **seconds**.

**Two profiles from one blueprint:**
- **Generic code project** (TrueSpend, Hades, Hermes, SpendLens, SCM-Master, the Telegram bot): hooks 1–8.
- **Vault / second brain**: add hook 9 (`guard-vault-integrity.sh`). One extra line in `settings.json`.

## Fail-open vs fail-closed (deliberate)

| Hook | Missing `jq` | Why |
|---|---|---|
| `scan-secrets.sh` | fail-**open** (allow) | warn-only (`ask`); other guards still fire |
| `format-on-save.sh` / `auto-test.sh` | fail-**open** (no-op) | never block on tooling gaps |
| `protect-files.sh` / `warn-large-files.sh` / `guard-vault-integrity.sh` | fail-**closed** (deny) | security/integrity hooks refuse to run blind |

## Available hooks

### 1. scan-secrets.sh — PreToolUse (`Edit`｜`Write`)
Scans content being written for high-confidence secrets and emits **`ask`** (not deny — test fixtures/docs legitimately contain fake keys). Tuned to Eugen's stack:
- **Anthropic** `sk-ant-api…` / `sk-ant-admin…`; **OpenAI** `sk-`, `sk-proj-`, `sk-svcacct-`.
- **Slack** `xoxb/xoxp/a/r/s` (his `SLACK_BOT_TOKEN`); **Telegram** bot token `digits:AA…`; **Hugging Face** `hf_…`.
- **GitHub** `ghp_/gho_/ghs_/ghr_/github_pat_`; **AWS** `AKIA…` + secret key.
- Private-key blocks; DB **connection strings with credentials** (postgres/mysql/mssql/redis/…).
- Generic `password/secret/token/api_key = "literal"` — **excludes** env-var references (`os.environ`, `os.getenv`, pydantic `Field(...)`, `process.env`, `${…}`), so his correct pattern never false-fires.

### 2. protect-files.sh — PreToolUse (`Edit`｜`Write`)
Blocks edits to sensitive/generated files. Fails **closed**.
- `.env`, `.env.*`, `*.pem`, `*.key`, `*.crt`, `*.p12`, `*.pfx`, `id_rsa`, `id_ed25519`.
- `credentials.json`, `token.txt`, `service-account*.json`, `gcp-*.json` — n8n/LangChain/GCP/Power BI creds.
- **`conversations.json`** — the 2-year ChatGPT export (PII); never commit/edit.
- Lock files, `*.gen.ts`, `*.generated.*`, `*.min.js/css`.
- Anything in `.git/`, `secrets/`; **self-protecting** on `.claude/hooks/*` (deny) and `settings.json` (ask).
- `raw/inputs/openai/*` → `ask` (raw PII export).

### 3. block-dangerous-commands.sh — PreToolUse (`Bash`)
Blocks dangerous shell commands, even chained (`&&`, `;`). Fails **closed**. Encodes Eugen's git hard-rules.
- **Git**: push to `main`/`master` (explicit, refspec, or bare push while on the branch), `--force` (allows `--force-with-lease`), `reset --hard`, `clean -f`.
- **SQL** (spend/supplier data): `DROP TABLE/DATABASE/SCHEMA`, `DELETE FROM` without `WHERE`, `TRUNCATE TABLE`.
- **Filesystem/system**: `rm -rf` on `/`, `~`, `$HOME`, unresolved `$VAR`, system dirs; `chmod 777`; `curl|wget | bash`; `mkfs`; `dd if=/dev/`; redirects into raw device files.
- **Publishing**: `npm/yarn/pnpm/bun/cargo/gem/twine` publish without `--dry-run`.

### 4. format-on-save.sh — PostToolUse (`Edit`｜`Write`)
Auto-formats after an edit. Always exits 0; silent on success. Runs a formatter **only when both the binary and a config exist**. Order tuned to Eugen (Python first):
- **Ruff** (`ruff.toml`/`.ruff.toml` or `pyproject.toml [tool.ruff]`) → `ruff format` + `ruff check --fix`.
- **Black + isort** (`pyproject.toml [tool.black]`) as fallback.
- **Biome** (`biome.json`) then **Prettier** for JS/TS. rustfmt/gofmt for Rust/Go.

### 5. warn-large-files.sh — PreToolUse (`Edit`｜`Write`)
Blocks writes to build artifacts, dep dirs, binaries. Fails **closed**.
- `node_modules/`, `vendor/`, `dist/`, `build/`, `.next/`, `__pycache__/`, `.venv/`/`venv/`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`.
- `*.so/.dll/.exe/.wasm`, archives, media, `*.pyc/.pyo/.class`, and binary data (`*.parquet/.xlsx/.pbix`).

### 6. auto-test.sh — PostToolUse (`Edit`｜`Write`)
Finds the test matching the edited source (`test_<stem>.py`, `<stem>_test.py`, same-dir / `tests/` / `__tests__/`) and runs it. **pytest** first, then `python -m unittest`; vitest/jest/mocha for JS, `go test`, `cargo test`. Silent on success — only emits on failure. `timeout: 120` in settings (Hades/Hermes suites can be slow).

### 7. session-start.sh — SessionStart (`startup`｜`resume`｜`clear`)
Injects `Branch: … | dirty` (~5–10 tokens). `DOTCLAUDE_SESSION_VERBOSE=1` adds last commit / file count / staged / stash / PR info. Drift nudge via `.claude/.dotclaude.json`. All commands (`git`, `cksum`, `wc`, `jq`) exist in Git Bash.

### 8. notify.sh — Notification
Native notification when Claude needs input. **Windows toast first** (native win32 + Git Bash has `powershell.exe` on PATH; `-NoProfile` avoids profile noise), then macOS `osascript`, then Linux `notify-send`. `DOTCLAUDE_NOTIFY_DRYRUN=1` prints instead of notifying.

### 9. guard-vault-integrity.sh — PreToolUse (`Edit`｜`Write`) — **VAULT ONLY**
Enforces the second-brain CLAUDE.md §4 never-touch trees. Fails **closed**.
- `wiki/**` → **deny** (AI-written index, never hand-edited). Exception: `wiki/sources.md` and `wiki/best-practices/**` → **ask** (sync skills regenerate these).
- `raw/**` → **ask** (original assets, never reorganized; confirm a real sync-skill ingest).
- **Do NOT copy this hook into a generic code project.**

## Windows / Git Bash compatibility

- All hooks are `#!/usr/bin/env bash` and run under **Git Bash** (what Claude Code uses for hooks on win32). No PowerShell syntax inside.
- **`jq` must be on PATH** (`winget install jqlang.jq`). See fail-open/closed table above.
- **Line endings: LF, not CRLF.** CRLF gives `bad interpreter: /usr/bin/env bash^M`. The repo `.gitattributes` pins `*.sh text eol=lf` — the #1 Windows gotcha.
- **Executable bit**: `git update-index --chmod=+x .claude/hooks/*.sh` when committing from Windows so the bit survives. `chmod +x` is a no-op on NTFS but Git Bash honors the index bit.
- **`powershell.exe`** (notify) resolves on native win32 Git Bash PATH — no WSL required.
- `dd`/`mkfs`/`/dev/` patterns are inert on Windows but kept for portability to Linux/Railway deploy repos.

## Adding your own

1. Create a `.sh` script here (LF line endings).
2. `git update-index --chmod=+x .claude/hooks/your-hook.sh`.
3. Wire it in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/your-hook.sh" } ] }
    ]
  }
}
```

- Exit 0 = allow, exit 2 = block/ask. Scripts receive JSON on stdin with `tool_input`.
- See the [Claude Code hooks docs](https://code.claude.com/docs/en/hooks) for all events.
