---
name: secrets-check
description: On-demand full-repo secret sweep — scan the working tree, staged changes, and git history for leaked keys, tokens, and credentials. The manual complement to the automatic scan-secrets PreToolUse hook, for auditing a repo before making it public or after a scare. Trigger phrases "check for secrets", "am I leaking anything", "scan the repo for secrets".
---

# secrets-check

Trigger: "check for secrets" / "am I leaking anything" / "scan the repo for secrets"

Standing rules: [`../_conventions.md`](../_conventions.md).

The `scan-secrets` hook guards new writes; this is the whole-repo audit. Report
every hit honestly — a false negative here can leak a key. Never print a real
secret value in full; mask it.

## Steps

1. **Confirm ignore hygiene first.** Check `.gitignore` covers `.env`, `.env.*`,
   `*.pem`, `*.key`, `secrets/`, `*.pfx`, credential files. If `.env` is NOT
   ignored, that's finding #1 — flag it loud.

2. **Scan tracked files (working tree).** Search for high-signal patterns — do
   NOT print matched values in full, mask the middle:
   - Anthropic: `sk-ant-` keys.
   - OpenAI: `sk-` / `sk-proj-` keys.
   - AWS: `AKIA[0-9A-Z]{16}` access key ids.
   - GitHub: `ghp_` / `gho_` / `ghs_` tokens.
   - Slack: `xoxb-` / `xoxp-` tokens.
   - Google: `AIza[0-9A-Za-z_\-]{35}`.
   - Private keys: `-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----`.
   - Generic: `password`/`secret`/`token`/`api_key` assigned a quoted literal
     (not a `os.environ[...]` / `os.getenv(...)` reference).
   - Connection strings with inline credentials (`://user:pass@host`).

3. **Scan staged changes.** `git diff --cached` for anything about to be
   committed.

4. **Scan history (the dangerous one).** `git log -p` grep for the same patterns,
   or run a dedicated tool if available (`gitleaks detect`, `trufflehog`). A key
   removed from HEAD but still in history is still leaked. If found, say plainly:
   the key must be rotated AND history rewritten — removal from HEAD is not
   enough.

5. **Report** (terse): findings by severity — `location: <pattern> (masked)` —
   history hits first. For each: the required action (rotate the key + where to
   move it to an env var). If clean, say the repo is clean across tree, staged,
   and history — and only because you scanned all three.
