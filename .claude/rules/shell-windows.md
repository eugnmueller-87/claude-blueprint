---
paths:
  - "**/*.ps1"
  - "**/*.sh"
  - "**/*.bat"
  - "**/*.cmd"
---

# Shell — Windows + Git Bash + PowerShell

- This is **Windows (win32) with Git Bash + PowerShell 5.1**. Scripts must work there — POSIX sh in `.sh` (Git Bash), PowerShell syntax in `.ps1`. Don't assume Linux-only tools exist.
- Bash: `/dev/null` (not `NUL`), forward slashes, quote all `"$paths"` (Windows paths have spaces), heredocs for multi-line — not PowerShell here-strings.
- PowerShell 5.1: no `&&`/`||` chaining (use `;` + `if ($?)`); no ternary/`??`/`?.`; don't `2>&1` native exes; write files other tools read with `-Encoding utf8` (default is UTF-16 BOM).
- Cross-line-ending safe: don't hardcode CRLF/LF assumptions; let `.gitattributes` normalize.
- **Hooks are bash, exit 2 = block/ask.** Read JSON from stdin via `jq`; **degrade gracefully if `jq` is missing** (skip the check, don't crash the hook). Never let a hook hard-fail the tool call on a missing dependency.
- Prefer arg-lists over string interpolation when calling programs; never build a command string from untrusted input (ties to `security.md`).
