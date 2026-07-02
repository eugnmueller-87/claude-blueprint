#!/usr/bin/env bash
# Blocks edits to sensitive or generated files.
# PreToolUse hook for Edit|Write operations.
# Exit 2 = block (deny|ask). Exit 0 = allow.
#
# Fails CLOSED (deny) if jq is missing — a security hook refuses to run blind.
# Tuned for Eugen's stack: n8n/LangChain credential dumps, GCP/Power BI service
# accounts, and the 2-year ChatGPT export (conversations.json = PII, must never
# be committed or hand-edited).

set -uo pipefail

emit() {
  # $1 = decision (deny|ask) ; $2 = reason
  local decision="$1"
  local reason="${2//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$decision" "$reason"
  exit 2
}

INPUT=$(cat)

# Extract file_path. Prefer jq; fall back to a grep/sed parse so this hook WORKS
# without jq (Windows/Git-Bash often lacks it). We do NOT blanket-deny on missing jq
# — that would block every edit. If we genuinely cannot find a path, allow (exit 0):
# the scan-secrets hook is the fail-closed backstop for content.
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
else
  FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')
fi
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename -- "$FILE_PATH")
BASENAME_LC=$(printf '%s' "$BASENAME" | tr '[:upper:]' '[:lower:]')
PATH_LC=$(printf '%s' "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

# ALLOW-LIST first: template files are meant to be edited (seed step 2). Must come
# BEFORE the protected-pattern loop, or ".env.*" would block ".env.example".
case "$BASENAME_LC" in
  .env.example|.env.sample) exit 0 ;;
esac

# Protected basename patterns. Matched case-insensitively via BASENAME_LC.
PROTECTED_PATTERNS=(
  ".env"
  ".env.*"
  "*.pem"
  "*.key"
  "*.crt"
  "*.p12"
  "*.pfx"
  "id_rsa"
  "id_ed25519"
  "credentials.json"
  "conversations.json"      # ChatGPT export = 2yr of PII, never commit/edit
  "token.txt"               # common n8n / bot token dump
  "service-account*.json"   # GCP / Power BI service accounts
  "gcp-*.json"
  ".npmrc"
  ".pypirc"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "poetry.lock"
  "uv.lock"
  "*.gen.ts"
  "*.generated.*"
  "*.min.js"
  "*.min.css"
)

shopt -s nocasematch 2>/dev/null || true
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  case "$BASENAME_LC" in
    $pattern)
      emit deny "Protected file: $BASENAME matches pattern '$pattern'"
      ;;
  esac
done

# Sensitive directories (lower-cased path for case-insensitive on Windows/mac).
case "$PATH_LC" in
  .git/*|*/.git/*)
    emit deny "Cannot edit files inside .git/" ;;
  secrets/*|*/secrets/*)
    emit deny "Cannot edit files inside secrets/" ;;
  .env|.env.*|*/.env|*/.env.*)
    emit deny "Cannot edit .env files. Secrets live in env vars, never the repo. (.env.example is allowed.)" ;;
  .claude/hooks/*|*/.claude/hooks/*)
    emit deny "Cannot edit hook scripts. These enforce security boundaries." ;;
  .claude/settings.json|*/.claude/settings.json|.claude/settings.local.json|*/.claude/settings.local.json)
    emit ask "Editing settings.json. This controls permissions and hooks. Confirm this change." ;;
  raw/inputs/openai/*|*/raw/inputs/openai/*)
    emit ask "This holds the raw ChatGPT export (PII). Confirm this is a sync-skill ingest, not a hand-edit." ;;
esac

exit 0
