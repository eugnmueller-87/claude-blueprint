#!/usr/bin/env bash
# Scans file content for accidental secrets before writing.
# PreToolUse hook for Edit|Write operations.
# Exit 2 = ask (warn, allow override for test fixtures/docs). Exit 0 = allow.
#
# Tuned for Eugen's stack: Claude & OpenAI APIs, LangChain/LangGraph, n8n,
# Slack (SLACK_BOT_TOKEN), a Telegram bot on Railway, Hugging Face model pulls,
# SQL connection strings, GitHub, AWS. Hard rule: NEVER commit secrets — env
# vars only, never the repo.
#
# FAIL-CLOSED on the secret scan. This is THE no-secrets guarantee — it must run
# even without jq. jq is NOT guaranteed on Windows/Git-Bash, so we do NOT skip when
# it is missing; we fall back to scanning the raw stdin JSON. Worst case (can't parse
# content at all) we scan the whole payload — over-inclusive is the safe direction here.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
  if [ "$TOOL_NAME" = "Write" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
  elif [ "$TOOL_NAME" = "Edit" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
  else
    exit 0
  fi
else
  # jq-free fallback: scan the entire raw JSON payload. This catches secrets in the
  # content regardless of tool_name; false-positive risk is acceptable for a warn/ask.
  CONTENT="$INPUT"
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# --- High-confidence secret patterns ---

MATCHES=""

# AWS Access Key IDs.
if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  MATCHES="$MATCHES AWS access key (AKIA...);"
fi

# AWS Secret Access Keys (40-char base64 after a key assignment).
if echo "$CONTENT" | grep -qiE '(aws_secret_access_key|secret_key)[[:space:]]*[=:][[:space:]]*["'\''"]?[A-Za-z0-9/+=]{40}'; then
  MATCHES="$MATCHES AWS secret key;"
fi

# GitHub tokens (PAT, OAuth, App, fine-grained).
if echo "$CONTENT" | grep -qE '(ghp_|gho_|ghs_|ghr_|github_pat_)[a-zA-Z0-9_]{20,}'; then
  MATCHES="$MATCHES GitHub token;"
fi

# Anthropic API keys (Claude API) — sk-ant-api / sk-ant-admin.
if echo "$CONTENT" | grep -qE 'sk-ant-(api|admin)[0-9]{2}-[a-zA-Z0-9_-]{80,}'; then
  MATCHES="$MATCHES Anthropic API key (sk-ant-...);"
fi

# OpenAI keys — project, service-account, and legacy.
if echo "$CONTENT" | grep -qE 'sk-(proj-|svcacct-)?[a-zA-Z0-9_-]{20,}'; then
  MATCHES="$MATCHES OpenAI/generic API key (sk-...);"
fi

# Slack tokens (SLACK_BOT_TOKEN xoxb, plus xoxp/a/r/s). Tight 3-segment form first,
# then a loose fallback so a real token is never missed.
if echo "$CONTENT" | grep -qE 'xox[baprs]-[0-9]{10,}-[0-9]{10,}-[0-9a-zA-Z]{20,}' \
  || echo "$CONTENT" | grep -qE 'xox[baprs]-[0-9a-zA-Z-]{20,}'; then
  MATCHES="$MATCHES Slack token;"
fi

# Telegram bot token (python-telegram-bot on Railway): <digits>:AA<35 chars>.
if echo "$CONTENT" | grep -qE '[0-9]{8,10}:AA[a-zA-Z0-9_-]{33}'; then
  MATCHES="$MATCHES Telegram bot token;"
fi

# Hugging Face access token (LangChain/RAG model pulls).
if echo "$CONTENT" | grep -qE 'hf_[a-zA-Z0-9]{30,}'; then
  MATCHES="$MATCHES Hugging Face token;"
fi

# Private key blocks.
if echo "$CONTENT" | grep -qE -- '-----BEGIN[[:space:]]+(RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'; then
  MATCHES="$MATCHES private key block;"
fi

# Connection strings with embedded credentials (his SQL / pandas data pulls).
if echo "$CONTENT" | grep -qE '(mongodb|postgres|postgresql|mysql|mariadb|mssql|redis|amqp|smtp)(\+[a-z]+)?://[^:[:space:]]+:[^@[:space:]]+@'; then
  MATCHES="$MATCHES connection string with credentials;"
fi

# Generic password/secret/token assignments with literal string values.
# Matches:  password = "actual_value",  SECRET_KEY: 'actual_value',  api_token="actual"
# Excludes: env-var references (his correct pattern) — os.environ[...], os.getenv(...),
#           pydantic Field(...), process.env.*, ${...}, ENV[...], env(...).
if echo "$CONTENT" | grep -qiE '(password|secret|token|api_key|apikey|api_secret|access_token|bearer)[[:space:]]*[=:][[:space:]]*["'\''"][^"'\''"]{8,}["'\''"]' && \
   ! echo "$CONTENT" | grep -qiE '(password|secret|token|api_key|apikey|api_secret|access_token|bearer)[[:space:]]*[=:][[:space:]]*["'\''"]?(process\.env|os\.environ|os\.getenv|getenv|\$\{|ENV\[|env\(|Field\()'; then
  MATCHES="$MATCHES hardcoded credential;"
fi

if [ -n "$MATCHES" ]; then
  # "ask" not "deny": test fixtures and docs legitimately contain fake keys.
  REASON="Possible secret detected in content:$MATCHES Never commit secrets — use env vars. Review carefully before allowing."
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"$REASON\"}}"
  exit 2
fi

exit 0
