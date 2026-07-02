# project-seed — my project blueprint

Every new repo starts here. It copies my hard rules in as **enforced machinery,
not good intentions**: secrets can't be committed, dangerous commands can't run,
and Claude works ADHD-aware and reports failures honestly.

Tuned for my stack: Python-first, AI agents (Claude/OpenAI, LangChain/LangGraph,
n8n, MCP, RAG), data work (SQL, pandas, Power BI), procurement-AI domain
(spend, suppliers, negotiation, compliance/LkSG/CSDDD). Runs on **Windows + Git
Bash**.

## What's in the box

- `.claude/settings.json` — permission allow/deny list + hook wiring
- `.claude/hooks/` — bash guards (block secrets & dangerous commands; auto-format & test)
- `.claude/rules/` — coding rules; most are path-scoped (load only near relevant code)
- `.claude/agents/` — focused reviewers (secret leaks, silent failures, LLM cost, data integrity)
- `CLAUDE.template.md` — starter project instructions with my four hard rules baked in
- `.gitignore` + `.env.example` — secrets stay out of git, config is documented
- `seed.sh` — one-shot installer for a new project

## The philosophy: mandatory core + tiers

Three tiers, one hard rule.

**MANDATORY CORE (never delete — ships in every project):**
- `scan-secrets.sh` + `protect-files.sh` + the `.gitignore` secret blocks + the
  `deny` list in `settings.json`. This is the **no-secrets guarantee**, enforced
  deterministically — not by hoping Claude remembers.
- The `CLAUDE.template.md` "Operating Rules" block (no-secrets, no-bullshit,
  honest-failure, ADHD-aware).
- `block-dangerous-commands.sh` — no push to main, no `rm -rf /`, no accidental
  `twine upload`, no DB `DROP`.

**RECOMMENDED (on by default, safe to trim per project):**
- `warn-large-files.sh`, `format-on-save.sh`, `auto-test.sh`, `session-start.sh`, `notify.sh`
- `python.md`, `ai-agents.md` rules
- `secret-leak-hunter` + `silent-failure-hunter` agents

**OPTIONAL (path-scoped — cost nothing until you touch matching files):**
- `data.md`, `procurement.md`, `security.md` rules
- `llm-cost-guard`, `data-integrity-reviewer` agents

**The one hard rule:** *Security is deterministic; everything else is advisory.*
Rules and agents are advice Claude can reason around. The secret/danger hooks and
the deny-list **cannot be reasoned around** — they block at the tool-call boundary
before the model's intent matters. That is why the core is non-negotiable and
**fails closed** (blocks if `jq` is missing), while convenience hooks **fail open**
(skip silently if a tool is missing) so they never get in the way.

## Seed a NEW project

```bash
# from an empty or new repo dir, on Git Bash:
bash /path/to/project-seed/seed.sh .
# then: 1) fill in CLAUDE.md  2) cp .env.example .env  3) git init && git add .
```

`seed.sh` copies `.claude/`, `.gitignore`, `.env.example`, renames
`CLAUDE.template.md` → `CLAUDE.md`, strips the seed repo's test fixtures,
`chmod +x`'s the hooks, and prints the 3-step checklist. It never overwrites an
existing `CLAUDE.md`, `.gitignore`, or `.env.example`.

## Install into an EXISTING project

For adding the blueprint to TrueSpend / Hades / etc. that already have code:

1. **Copy the machinery, not the docs:**
   `cp -R project-seed/.claude/ <proj>/.claude/` then
   `rm -rf <proj>/.claude/hooks/tests`. If a `.claude/` already exists, copy
   `hooks/`, `rules/`, `agents/` individually and **deep-merge** `settings.json`
   by hand (append your `allow` entries and the `hooks` blocks; don't clobber
   existing project permissions).
2. **Merge `.gitignore`:** append the SECRETS + DATA blocks if not present. Then
   immediately check nothing sensitive is already tracked:
   `git ls-files | grep -iE '\.env|\.key|\.pem|credentials'` — if it returns
   anything, that secret is already in history: rotate it and `git rm --cached`.
3. **CLAUDE.md:** if one exists, paste the **Operating Rules (non-negotiable)**
   block from `CLAUDE.template.md` at the top; keep your Commands/Architecture.
4. **`.env.example`:** create it from the vars the code already reads; move any
   hardcoded secret into `.env` and reference it via `os.getenv`.
5. **`chmod +x .claude/hooks/*.sh`** (needed for the hooks to run).
6. **Verify:** run the scan-secrets test below; confirm `session-start.sh` prints
   your branch; try a dummy `git push origin main` in a throwaway to confirm the
   danger hook blocks it.

## Prerequisites

- **Git Bash** (ships with Git for Windows) — the hooks are bash.
- **jq** — REQUIRED for the security hooks. Without it they **fail closed**
  (block). Install: `winget install jqlang.jq`
- Optional: `ruff`/`black` (Python format), `prettier` (JS/TS), `pytest`, `gh` CLI.

## Customizing

- Add a permission: edit the `allow` list in `.claude/settings.json`.
- Add a per-machine-only permission: `.claude/settings.local.json` (git-ignored) —
  e.g. a `Bash(railway *)` you trust only on your own box.
- Add a rule: drop a `.md` in `.claude/rules/` (path-scope it unless truly global).
- Loosen a guard: the hooks are yours — but **never weaken `scan-secrets.sh` or
  `protect-files.sh`**.

## Test the machinery works

```bash
# should emit an "ask" decision and exit 2 (works WITH or WITHOUT jq installed):
echo '{"tool_name":"Write","tool_input":{"file_path":"x.py","content":"key=\"sk-ant-api03-abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcd\""}}' \
  | bash .claude/hooks/scan-secrets.sh

# a clean env-var reference should ALLOW (exit 0):
echo '{"tool_name":"Write","tool_input":{"file_path":"x.py","content":"key = os.environ[\"ANTHROPIC_API_KEY\"]"}}' \
  | bash .claude/hooks/scan-secrets.sh
```

> `scan-secrets.sh` fails **closed** and runs even without `jq` (falls back to scanning
> the raw payload). Install `jq` for cleaner parsing, but it is not required.
