---
name: setup-project
description: Bootstrap the .claude/ blueprint into a repo — detect the stack, tune CLAUDE.md and rules, wire the safety hooks, write the drift fingerprint. Run once when seeding a new project, or re-run after the stack changes. Trigger phrases "set up this project", "setupdotclaude", "seed claude into this repo".
---

# setup-project

Trigger: "set up this project" / "setupdotclaude" / "seed claude here"

Standing rules: [`../_conventions.md`](../_conventions.md).

You are seeding this repo with the standing blueprint. Lead with what you're
about to change, do it, then report what landed. Never invent commands — detect
them from real manifest files; if a command isn't verifiable, mark it TODO and
say so.

## Steps

1. **Detect the stack.** Read (don't guess) what exists:
   - `pyproject.toml` / `requirements.txt` / `setup.py` → Python. From
     `pyproject.toml`, note the real test runner (pytest?), formatter/linter
     (ruff? black? isort?), type checker (mypy?), and package manager (`uv` lock
     file? `poetry`? plain pip?).
   - `package.json` → JS/TS; read the `scripts` block for real commands.
   - `railway.json` / `Procfile` / `vercel.json` → deploy target.
   - `.env.example` → expected env vars (NEVER read `.env` itself; the deny list
     blocks it — that's correct, don't work around it).
   State the detected stack in one line before writing anything.

2. **Write/patch CLAUDE.md** from `CLAUDE.template.md`. Fill Commands from the
   REAL detected commands only (e.g. `pytest`, `ruff check .`, `mypy .`). Keep it
   under 50 non-blank lines (hard cap; aim for 25). Do NOT duplicate code style —
   that lives in `rules/code-quality.md`.

3. **Install rules.** Copy the always-on rules (`code-quality.md`, `testing.md`)
   and the path-scoped rules that match this repo:
   - `python.md` (`**/*.py`) for any Python repo.
   - `security.md` if there's an `api/**` / `routes/**` / `handlers/**` surface.
   - `error-handling.md` for `services/**` / `handlers/**`.
   Skip rules with no matching paths — dead rules cost tokens. Drop `frontend.md`
   / `database.md` unless the repo actually has a UI or SQL migrations.

4. **Wire hooks.** Copy the four PreToolUse guards (`protect-files`,
   `warn-large-files`, `scan-secrets`, `block-dangerous-commands`),
   `format-on-save` + `auto-test` (PostToolUse), `session-start`, `notify`.
   Write `settings.json` with the matchers and the allow/deny permission list.
   Retune the allow-list for the stack: for Python add `Bash(pytest *)`,
   `Bash(ruff *)`, `Bash(mypy *)`, `Bash(python -m *)`, `Bash(uv *)`; keep the
   git/gh allows; drop the `npm` allows if there's no `package.json`.

5. **chmod +x** every hook (Git Bash): `chmod +x .claude/hooks/*.sh`.

6. **Write the fingerprint** so `session-start` can nudge on drift:
   `DOTCLAUDE_FINGERPRINT=1 .claude/hooks/session-start.sh > .claude/.dotclaude.json`.

7. **Verify, don't assume.** Actually run each command you wrote into CLAUDE.md
   once (lint, test, typecheck). If one fails or is missing, fix the CLAUDE.md
   line or mark it `# TODO: unverified` — never leave a command that doesn't run.

8. **Report** (terse): stack detected · files written · commands verified ·
   anything left as TODO. End with the single next action.
