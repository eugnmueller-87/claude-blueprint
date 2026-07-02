#!/usr/bin/env bash
# Sends a native OS notification when Claude needs user input.
# Notification hook. Always exits 0.
#
# Eugen runs native win32 + Git Bash (NOT WSL). powershell.exe is on the Git
# Bash PATH, so the Windows toast branch works directly. -NoProfile keeps his PS
# profile from printing noise / slowing startup. macOS/Linux branches kept so
# the blueprint stays portable to a Railway/Linux deploy box.

INPUT=$(cat 2>/dev/null)

MESSAGE="Claude Code needs your attention"
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  MSG=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null)
  if [ -n "$MSG" ]; then
    MESSAGE="$MSG"
  fi
fi

TITLE="Claude Code"

# Test/dry-run mode: print instead of notifying (used by hook fixtures).
if [ "${DOTCLAUDE_NOTIFY_DRYRUN:-0}" = "1" ]; then
  echo "notify: $TITLE: $MESSAGE"
  exit 0
fi

# Windows (native win32 + Git Bash) → PowerShell balloon toast. Tried first
# because that is Eugen's actual environment.
if command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; \$n = New-Object System.Windows.Forms.NotifyIcon; \$n.Icon = [System.Drawing.SystemIcons]::Information; \$n.Visible = \$true; \$n.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', 'Info')" >/dev/null 2>&1
  exit 0
fi

# macOS.
if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
  exit 0
fi

# Linux (native).
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$TITLE" "$MESSAGE" 2>/dev/null
  exit 0
fi

# No notification method available. Silent exit.
exit 0
