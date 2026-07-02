#!/usr/bin/env bash
# Seed a project with my blueprint. Usage: bash seed.sh <target-dir>
# Non-destructive: never overwrites an existing CLAUDE.md / .gitignore / .env.example.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:?usage: seed.sh <target-dir>}"

mkdir -p "$DEST/.claude"
cp -R "$SRC/.claude/." "$DEST/.claude/"
rm -rf "$DEST/.claude/hooks/tests"                    # test fixtures stay in the seed repo
rm -f  "$DEST/.claude/hooks/guard-vault-integrity.sh" # VAULT-ONLY hook — never ship to code projects
# Also drop its wiring from the seeded settings.json (guard-vault-integrity line).
if [ -f "$DEST/.claude/settings.json" ]; then
  grep -v 'guard-vault-integrity' "$DEST/.claude/settings.json" > "$DEST/.claude/settings.json.tmp" \
    && mv "$DEST/.claude/settings.json.tmp" "$DEST/.claude/settings.json"
fi

[ -f "$DEST/.gitignore" ]    || cp "$SRC/.gitignore" "$DEST/.gitignore"
[ -f "$DEST/.env.example" ]  || cp "$SRC/.env.example" "$DEST/.env.example"
[ -f "$DEST/CLAUDE.md" ]     || cp "$SRC/CLAUDE.template.md" "$DEST/CLAUDE.md"

chmod +x "$DEST/.claude/hooks/"*.sh 2>/dev/null || true

echo "Seeded '$DEST'. Next:"
echo "  1) fill in CLAUDE.md (Commands / Architecture / Key Decisions)"
echo "  2) cp .env.example .env   (then fill it — it is git-ignored)"
echo "  3) git init && git add .  (the .gitignore already protects you)"
command -v jq >/dev/null 2>&1 || \
  echo "WARNING: jq not found — the security hooks FAIL CLOSED without it. Run: winget install jqlang.jq"
