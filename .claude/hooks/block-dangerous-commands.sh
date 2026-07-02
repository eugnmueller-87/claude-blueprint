#!/usr/bin/env bash
# Blocks dangerous shell commands: push to protected branches, force push,
# destructive operations. PreToolUse hook for Bash operations.
# Exit 2 = block. Exit 0 = allow.
#
# Enforces Eugen's git hard-rules: no push to master, no force push (allows
# --force-with-lease), no reset --hard / clean -f. Also guards the SQL he runs
# against spend/supplier data (DROP/TRUNCATE/DELETE-without-WHERE).
#
# Windows/Git-Bash note: dd/mkfs//dev/ patterns are inert on native win32 but
# harmless — kept so this blueprint stays portable when it seeds a Linux/Railway
# deploy repo. The git/rm/SQL rules are the ones that fire on Eugen's machine.
#
# Configurable via env:
#   CLAUDE_PROTECTED_BRANCHES  comma list (default: derived from git + main,master)

set -uo pipefail

emit_deny() {
  local reason="${1//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 2
}

INPUT=$(cat)

# Extract the command. Prefer jq; fall back to grep/sed so this WORKS without jq
# (not installed on this Windows box). Blanket-denying on missing jq would block
# EVERY Bash command. If no command found, allow (exit 0).
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
else
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//')
fi
[ -z "$COMMAND" ] && exit 0

# ── Protected branch list ────────────────────────────────────────────────
DEFAULT_BRANCHES="main,master"
if GIT_DEFAULT=$(git config --get init.defaultBranch 2>/dev/null) && [ -n "$GIT_DEFAULT" ]; then
  DEFAULT_BRANCHES="$DEFAULT_BRANCHES,$GIT_DEFAULT"
fi
PROTECTED_BRANCHES="${CLAUDE_PROTECTED_BRANCHES:-$DEFAULT_BRANCHES}"
BR_REGEX=$(printf '%s' "$PROTECTED_BRANCHES" | tr ',' '\n' | awk 'NF{printf "%s%s",sep,$0; sep="|"}')

contains_cmd() { printf '%s' "$COMMAND" | grep -qE "$1"; }
contains_icmd() { printf '%s' "$COMMAND" | grep -qiE "$1"; }

# ── Git push protections ────────────────────────────────────────────────
if contains_cmd '(^|[;&|()]+[[:space:]]*)git[[:space:]]+push'; then
  if contains_cmd "git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]*:)?($BR_REGEX)(\$|[[:space:]])"; then
    MATCHED_BRANCH=$(printf '%s' "$COMMAND" | grep -oE "($BR_REGEX)(\$|[[:space:]])" | head -1 | tr -d '[:space:]')
    emit_deny "Blocked: push to protected branch '${MATCHED_BRANCH:-main}'. Use a feature branch and open a PR."
  fi
  if contains_cmd "git[[:space:]]+push.*:($BR_REGEX)(\$|[[:space:]])"; then
    MATCHED_BRANCH=$(printf '%s' "$COMMAND" | grep -oE ":($BR_REGEX)(\$|[[:space:]])" | head -1 | tr -d ': [:space:]')
    emit_deny "Blocked: push to protected branch '${MATCHED_BRANCH:-main}' via refspec. Use a feature branch and open a PR."
  fi
  if contains_cmd 'git[[:space:]]+push[[:space:]]*($|[;&|])'; then
    CURRENT=$(git branch --show-current 2>/dev/null || true)
    if [ -n "$CURRENT" ] && printf '%s' ",$PROTECTED_BRANCHES," | grep -q ",$CURRENT,"; then
      emit_deny "Blocked: you are on '$CURRENT' (a protected branch). Switch to a feature branch."
    fi
  fi
  if contains_cmd 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(-[a-zA-Z]*f[a-zA-Z]*|--force)([[:space:]=]|$)' \
     && ! contains_cmd '\-\-force-with-lease'; then
    emit_deny "Blocked: force push is not allowed. Use --force-with-lease if you must overwrite remote."
  fi
fi

# ── Destructive filesystem operations ───────────────────────────────────
CMD_NOQUOTE=$(printf '%s' "$COMMAND" | tr -d "'\"")
if printf '%s' "$CMD_NOQUOTE" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*[[:space:]]+)*-?[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+(/([[:space:]]|\*|$)|~|\$HOME|\$[A-Za-z_][A-Za-z0-9_]*|\.\./\.\.)' ; then
  emit_deny "Blocked: recursive force-delete on /, ~, \$HOME, an unresolved \$VAR, or .../.. path. Specify a concrete safe target."
fi
if printf '%s' "$CMD_NOQUOTE" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-?[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+/(usr|etc|var|bin|sbin|lib|opt|root|boot)([[:space:]/]|$)'; then
  emit_deny "Blocked: recursive delete targeting a system directory."
fi

# ── Dangerous database operations (spend/supplier data) ─────────────────
if contains_icmd 'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)[[:space:]]+'; then
  emit_deny "Blocked: DROP TABLE/DATABASE/SCHEMA detected. Run manually if intended."
fi
if printf '%s\n' "$COMMAND" | awk '
  BEGIN { IGNORECASE=1; RS=";" }
  /DELETE[[:space:]]+FROM[[:space:]]+[A-Za-z_][A-Za-z0-9_.]*/ {
    if ($0 !~ /WHERE/) { print "BAD"; exit }
  }
' | grep -q BAD; then
  emit_deny "Blocked: DELETE FROM without a WHERE clause. Add a WHERE or run manually."
fi
if contains_icmd 'TRUNCATE[[:space:]]+TABLE'; then
  emit_deny "Blocked: TRUNCATE TABLE detected. Run manually if intended."
fi

# ── Dangerous system commands ───────────────────────────────────────────
if contains_cmd 'chmod([[:space:]]+-[a-zA-Z]+)*[[:space:]]+0?777([[:space:]]|$)' \
  || contains_cmd 'chmod([[:space:]]+-[a-zA-Z]+)*[[:space:]]+a\+rwx([[:space:]]|$)'; then
  emit_deny "Blocked: chmod 777 / a+rwx grants everyone full access. Use restrictive perms."
fi

if contains_cmd '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|ksh|fish|dash|csh)([[:space:]]|$)'; then
  emit_deny "Blocked: piping downloaded content directly to a shell is dangerous."
fi

if printf '%s' "$COMMAND" | grep -qE '(^|[^0-9&])>[[:space:]]*/dev/[a-zA-Z][a-zA-Z0-9]*' \
   && ! printf '%s' "$COMMAND" | grep -qE '>[[:space:]]*/dev/(null|stdout|stderr|tty|zero|random|urandom)([[:space:]]|$)' ; then
  emit_deny "Blocked: redirection into a raw device file can destroy data."
fi
if contains_cmd '(^|[;&|[:space:]])(mkfs|mkfs\.[a-z0-9]+)([[:space:]]|$)' \
  || contains_cmd '(^|[;&|[:space:]])dd[[:space:]]+[^|]*(if|of)=/dev/[a-zA-Z]' ; then
  emit_deny "Blocked: mkfs/dd against a device node. Irreversible data loss."
fi

# ── Destructive git ─────────────────────────────────────────────────────
if contains_cmd 'git[[:space:]]+reset[[:space:]]+--hard'; then
  emit_deny "Blocked: git reset --hard discards uncommitted changes permanently."
fi
if contains_cmd 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'; then
  emit_deny "Blocked: git clean -f permanently deletes untracked files."
fi

# ── Accidental package publishing ───────────────────────────────────────
publish_patterns=(
  '(npm|yarn|pnpm|bun)[[:space:]]+publish'
  'cargo[[:space:]]+publish'
  'gem[[:space:]]+push'
  'twine[[:space:]]+upload'
)
for pat in "${publish_patterns[@]}"; do
  if contains_cmd "$pat" && ! contains_cmd '(^|[[:space:]])(--dry-run|-n)([[:space:]=]|$)'; then
    emit_deny "Blocked: publishing packages should run in CI or manually, not via Claude."
  fi
done

exit 0
