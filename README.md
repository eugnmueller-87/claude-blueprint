# claude-blueprint

**Start a Claude Code project with guard rails that hold.**

One command seeds a new repo with hooks that block secrets and dangerous commands,
a `CLAUDE.md` whose rules are anchored to real incidents, ten focused reviewers, and
twenty skills.

```bash
bash /path/to/claude-blueprint/seed.sh .
```

---

## The idea in two sentences

**Security is deterministic. Everything else is advisory.**

Rules and instructions are advice the model can reason around. Hooks block at the
tool-call boundary, *before* the model's intent matters. So put anything you cannot
afford to lose behind a hook, and make everything else specific enough that the
model actually follows it.

That second half is where most `CLAUDE.md` files fail.

---

## Why your CLAUDE.md gets ignored

You wrote *"write clean code"* and *"don't over-engineer"*. The model read it. The
model ignored it.

It ignored it because the rule has no teeth. *"Don't over-engineer"* is a mood, not
an instruction. There is no moment where the model can tell it is about to break the
rule, because the rule describes a feeling rather than a situation.

Compare:

> ❌ **Don't rewrite things unnecessarily.**

> ✅ **Never replace a whole list to add one item. If an API looks like it can only
> replace, read its input schema before you believe that.** On 2026-08-12 a project
> board's status options were replaced twice to add one option each time. Both times
> the platform silently dropped all 63 card assignments. The input type had an `id`
> field the whole time.

The second one wins because it names the exact moment, the exact wrong move, and
what it cost. **Rules need scars.**

All nine rules in `CLAUDE.template.md` come with the dated incident behind them in
[`docs/RULES.md`](docs/RULES.md). They are not hypotheticals.

---

## Quickstart

**New project:**

```bash
git clone https://github.com/eugnmueller-87/claude-blueprint.git
cd my-new-project
bash ../claude-blueprint/seed.sh .
# then: fill in CLAUDE.md, cp .env.example .env, git init
```

`seed.sh` copies `.claude/`, `.gitignore` and `.env.example`, renames
`CLAUDE.template.md` → `CLAUDE.md`, makes the hooks executable, and prints a
three-step checklist. **It never overwrites an existing `CLAUDE.md`, `.gitignore` or
`.env.example`.**

**Just the rules, nothing else:**

```bash
curl -O https://raw.githubusercontent.com/eugnmueller-87/claude-blueprint/master/CLAUDE.template.md
mv CLAUDE.template.md CLAUDE.md
```

---

## What is in the box

| | |
|---|---|
| **`.claude/hooks/`** (8) | Bash guards. Secrets and dangerous commands are blocked before the tool call runs |
| **`.claude/rules/`** (15) | Coding rules, most path-scoped so they cost nothing until you touch matching files |
| **`.claude/agents/`** (10) | Focused reviewers: security, silent failures, performance, docs, data pipelines, AI agents, frontend, PR tests |
| **`.claude/skills/`** (17 + 3 optional) | `ship` · `tdd` · `debug-fix` · `pr-review` · `refactor` · `secrets-check` · `incident-rule` · and more |
| **`CLAUDE.template.md`** | Starter instructions with four operating rules baked in |
| **`docs/RULES.md`** | Nine engineering rules with the incident behind each one |
| **`docs/ADAPTING.md`** | How to strip this down without breaking the method |
| **`seed.sh`** | One-shot installer |

**Tuned for:** Python-first, AI agents (Claude/OpenAI, LangChain/LangGraph, MCP,
RAG), data work (SQL, pandas), on **Windows + Git Bash**. The hooks are bash, so
macOS and Linux work too. The rules and skills are stack-agnostic.

---

## The three tiers

**MANDATORY CORE — never delete.**
`scan-secrets.sh`, `protect-files.sh`, the secret blocks in `.gitignore`, the `deny`
list in `settings.json`, and `block-dangerous-commands.sh`. This is the no-secrets
guarantee, enforced deterministically rather than by hoping the model remembers.
Also the Operating Rules block in `CLAUDE.template.md`.

**RECOMMENDED — on by default, safe to trim.**
`warn-large-files.sh`, `format-on-save.sh`, `auto-test.sh`, `session-start.sh`,
`notify.sh`, the `python-quality` and `ai-agents` rules, the `security-reviewer` and
`silent-failure-hunter` agents.

**OPTIONAL — path-scoped, cost nothing until you touch matching files.**
`data-pandas-sql`, `data-privacy-procurement`, `rag-retrieval`, `frontend`,
`db-migrations`, `evals`, and the corresponding reviewers.

**The core fails closed** (it blocks if `jq` is missing). **Convenience hooks fail
open** (they skip silently) so they never get in your way.

---

## The nine rules, one line each

1. **Never claim an action you did not verify.** No "sent", "saved", "deployed"
   unless a tool result says so.
2. **Add, don't replace.** Slot new items into a list; never rewrite the whole list.
3. **Read an API's input schema before treating it as replace-only.**
4. **A commit is not a deploy.** Verify the change is in what actually ships.
5. **Pass the reason through.** An error that drops the cause forces a guess.
6. **Measure what matters, not what is easy.** A health check that cannot fail is
   not a health check.
7. **Turn the task into a verifiable goal before writing code.**
8. **An alert with no channel is not an alert.**
9. **Every test file says which failure forced it into existence.**

Each one, with its incident: [`docs/RULES.md`](docs/RULES.md).

---

## The part that keeps this from going stale

Borrowed rules are a starting point. The rules that actually save you are the ones
you write after something breaks.

**Use the `incident-rule` skill.** Next time you lose an afternoon to something
avoidable, run it. It asks four questions:

1. What did we believe that turned out to be false?
2. What was the exact moment the wrong path was taken?
3. What did it cost?
4. How would we recognise the same moment next time?

Then it writes the rule in your voice and appends it to your `CLAUDE.md`. **It also
refuses to write one when nothing was actually at stake** — because every rule is
paid for in every future request.

---

## Test that the machinery works

```bash
# Should emit an "ask" decision and exit 2 (works with or without jq):
echo '{"tool_name":"Write","tool_input":{"file_path":"x.py","content":"key=\"sk-ant-api03-abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcd\""}}' \
  | bash .claude/hooks/scan-secrets.sh

# A clean env-var reference should ALLOW (exit 0):
echo '{"tool_name":"Write","tool_input":{"file_path":"x.py","content":"key = os.environ[\"ANTHROPIC_API_KEY\"]"}}' \
  | bash .claude/hooks/scan-secrets.sh
```

---

## Adding this to an existing project

1. **Copy the machinery, not the docs.** `cp -R claude-blueprint/.claude/ <proj>/`.
   If `.claude/` already exists, copy `hooks/`, `rules/`, `agents/`, `skills/`
   individually and **deep-merge** `settings.json` by hand — append your `allow`
   entries and the `hooks` blocks, do not clobber existing permissions.
2. **Merge `.gitignore`**, then immediately check nothing sensitive is already
   tracked:
   ```bash
   git ls-files | grep -iE '\.env|\.key|\.pem|credentials'
   ```
   Anything it returns is already in history. **Rotate it**, then `git rm --cached`.
3. **`CLAUDE.md`:** paste the Operating Rules block from `CLAUDE.template.md` at the
   top; keep your own Commands and Architecture sections.
4. **`chmod +x .claude/hooks/*.sh`** — required for the hooks to run.
5. **Verify:** run the scan-secrets test above and confirm it blocks.

---

## Prerequisites

- **Bash.** Git Bash on Windows, native elsewhere.
- **`jq`** — required by the security hooks. Without it they **fail closed**.
  `winget install jqlang.jq` · `brew install jq` · `apt install jq`
- Optional: `ruff` / `black`, `prettier`, `pytest`, `gh`.

---

## Contributing

Pull requests welcome, with one condition that is the whole point:

> **A rule without an incident will not be merged.** Tell us what broke, when, and
> what it cost. "This seems like good practice" is not enough. If it never hurt, it
> does not earn context space.

Hooks and skills are judged differently: they need a test, not a story.

---

## License

MIT. See [LICENSE](LICENSE). Use it, fork it, sell it. No attribution required.

---

## Credit

The four-rule shape of *think before coding · simplicity · surgical changes ·
goal-driven execution* circulates widely as a distillation of
[Andrej Karpathy's observations on LLM coding pitfalls](https://x.com/karpathy/status/2015883857489522876),
and rule 7 here is a direct descendant.

What this repo adds is the two halves that advice alone cannot cover: **hooks for
what must not be negotiable**, and **incidents for what the model needs to recognise**.

---

*By [eugnmueller-87](https://github.com/eugnmueller-87). Built and hardened while
running a personal AI assistant in production. Written with AI assistance and
reviewed by a human, which is also how the incidents in `docs/RULES.md` were found.*
