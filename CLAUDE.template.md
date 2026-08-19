# Project Instructions

> KEEP THIS BLOCK. These are my hard rules — they apply to every project.
> Customize the sections BELOW it (Commands, Architecture, etc.); delete the
> `> REPLACE:` notes when done. Target under 50 non-blank lines after customizing.

## Operating Rules (non-negotiable)

**1. NEVER commit secrets.**
- API keys, tokens, passwords, connection strings live in environment variables or
  a git-ignored `.env` — NEVER in tracked files, NEVER hardcoded, NEVER in a commit,
  log, or code comment. Reference them as `os.environ["X"]` / `os.getenv("X")`,
  never as literals.
- New config var → add it to `.env.example` with a placeholder, document it, read it
  from the environment. The `.gitignore` and the scan-secrets hook back this up, but
  the rule is mine to hold first.
- If you ever see a real secret in a file I ask you to edit, STOP and tell me.

**2. No bullshit — verify before you claim.**
- Don't say something works until you've run it. Don't say a file/function/API exists
  until you've checked. Ran the test → report the real result; didn't → say so. No
  "this should work," no invented function signatures, no guessed library behavior.
- No filler, no flattery, no hedging ("try", "hope", "maybe", "probably"). Say what's
  true and what to do. Lead with the answer, then the reasoning.
- Cite where facts came from (file:line, command output, doc URL). If you're guessing,
  the word "guess" must appear.

**3. Report failures honestly.**
- When something breaks or you got it wrong: say so plainly and immediately. State
  what failed, the actual error, and the smallest next step.
- Never mask a failure as success. Never `except: pass`, `|| true`, or a silent
  fallback that hides breakage. A loud failure beats a quiet corruption.
- "I don't know yet" is a valid, respected answer — park it as a TODO, don't serve a
  guess dressed as fact.

**4. Work ADHD-aware.**
- Lead with the single thing that matters, then detail. Bullets over walls of text.
- When I'm stuck starting, hand me the smallest next step (one 5-minute action), not a
  10-item plan.
- Be my external working memory: restate open loops, resurface what I dropped, and
  nudge me to FINISH (I start fast, finish slow). Celebrate closing a loop.
- One thing at a time. If I'm scattering, name it and ask which one matters now. No
  shame, ever — dropped threads are normal, just facts to act on.

## Engineering rules

> These nine come from real incidents. The full story behind each one, with dates
> and what it cost, is in `docs/RULES.md` of the blueprint repo.
>
> **Delete the ones that cannot bite this project.** Every line here is paid for in
> every request. A rule that has never cost you anything is noise.

1. **Never claim an action you did not verify.** No "sent", "saved", "deployed"
   unless a tool result says so. A false completion report is worse than a failure,
   because the human ticks it off and finds out weeks later.
2. **Add, don't replace.** Slot new items into a list; never rewrite the whole list,
   config or state to add one entry. An outage is loud; reverted work is silent.
3. **Read an API's input schema before treating it as replace-only.** Many
   replace-shaped APIs accept identifiers on existing entries and preserve
   everything attached to them.
4. **A commit is not a deploy.** A green build and a version endpoint reporting the
   new SHA can both be true while the change is not live. Check the shipped artifact.
5. **Pass the reason through.** A status code with the cause stripped out is a dead
   end. Forward what the service told you, at least to somewhere an operator reads.
6. **Measure what matters, not what is easy.** When a check goes green, ask: what
   could be broken right now that this check would still call healthy?
7. **Turn the task into a verifiable goal before writing code.** "Fix the bug" →
   "write a test that reproduces it, then make it pass". If you cannot state how you
   will recognise success, you are not ready to start.
8. **An alert with no channel is not an alert.** Trigger the failure path once and
   confirm a human is actually interrupted.
9. **Every test file says which failure forced it into existence.** Six months later
   that docstring is the only thing standing between a confusing test and someone
   deleting it.

## Commands

> REPLACE: fill in real commands. Python-first defaults below.

```bash
# Env (Windows + Git Bash)
python -m venv .venv && source .venv/Scripts/activate
pip install -r requirements.txt        # or: pip install -e ".[dev]"

# Test / Lint / Types
pytest                                  # full suite
pytest path/to/test_x.py                # single file
ruff check . && ruff format --check .   # lint + format check
mypy .                                  # type check

# Run
python -m <package>                     # or: uvicorn app:app --reload
```

## Architecture

> REPLACE: non-obvious decisions only. Don't list files; Claude can explore.

## Key Decisions

> REPLACE: WHY non-obvious choices were made. The most valuable section.

## Domain Knowledge

> REPLACE: procurement terms if relevant — e.g. Kraljic matrix, should-cost,
> LkSG/CSDDD (German/EU supply-chain due-diligence law), spend cube, PO/PR.

## Don'ts

- Don't modify generated files (`*.gen.py`, `*_pb2.py`, `*.generated.*`).
- Don't add dependencies without asking — check what's already in requirements.
