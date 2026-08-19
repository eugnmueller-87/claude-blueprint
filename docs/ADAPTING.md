# Adapting this to your project

The method matters. My nine rules do not.

---

## Step 1: delete what does not apply

Read `CLAUDE.md` top to bottom and cut anything that cannot bite you:

| Rule | Delete it if |
|---|---|
| 4 (commit ≠ deploy) | you have no build step or no deploy pipeline |
| 5 (pass the reason through) | you call no external services |
| 6 (measure what matters) | you have no health checks or monitoring |
| 8 (alert needs a channel) | you have no scheduled checks |
| 3 (read the input schema) | you write no API calls that mutate remote state |

**Rules 1, 2, 7 and 9 apply to essentially every project.** The rest are situational.

Deleting is not vandalism. **Every line you keep is paid for in every request.**

---

## Step 2: fill in the header

The four bracketed lines at the top of `CLAUDE.md` do more work than any rule:

```markdown
**Project:** [what this is, in one sentence]
**Stack:** [languages, framework, where it runs]
**Deploys from:** [branch, and what triggers it]
**Never touch:** [secrets, generated files, anything with a separate owner]
```

`Never touch` in particular. It is the cheapest possible guard rail, and the one
most projects are missing.

---

## Step 3: add your own project's hard-won rules

Anything you already know your agent gets wrong in *this* codebase goes in now. You
do not need the `incident-rule` skill for these — you already know them. Just write
them with the same specificity:

> ❌ Be careful with the database
> ✅ Never run a migration without checking whether the previous one is applied on
> the target. On 2026-03-04 a migration ran twice on staging and duplicated 4,100
> rows. Check `SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 1` first.

---

## Step 4: let it grow from real damage

From here, use the `incident-rule` skill. **Do not sit down and brainstorm rules.**
Brainstormed rules are the ones that read like a mood board and get ignored.

Wait until something costs you an afternoon, then capture it while the details are
sharp. A `CLAUDE.md` that grows by one rule a month, each one paid for, will beat
anything written in one sitting.

---

## A note on length

Rough guidance from running this in production:

| Length | What happens |
|---|---|
| under 50 lines | too thin to change behaviour meaningfully |
| **50 to 150 lines** | the sweet spot |
| 150 to 300 lines | still works, but check for rules that have never cost anything |
| over 300 lines | individual lines stop carrying weight, and you pay for all of it every turn |

**These are observations from one project, not measured thresholds.** Treat them as a
prompt to prune, not as a law.

When you cross a threshold, do not just trim words. **Ask which rule has never
prevented anything, and delete that one.**

---

## Multi-repo setups

If you work across several repos, resist the urge to write one giant shared
`CLAUDE.md`.

- **Per-repo `CLAUDE.md`** for anything specific to that codebase: its deploy path,
  its known traps, its structure
- **User-level rules** (`~/.claude/CLAUDE.md`) for how you personally want to be
  worked with: tone, when to ask, how much to explain

The nine rules here are mostly project-level. The "house rules" block at the bottom
of the template is mostly user-level — move it up to your user config if you want it
everywhere.

---

## What to do when a rule stops working

If the agent keeps breaking a rule you wrote, the rule is usually not specific
enough. Three fixes, in order of preference:

1. **Add the moment.** *"Don't be destructive"* → *"before calling any endpoint whose
   name starts with `update`, read its input type"*
2. **Replace it with a check.** A test, a hook, or a lint rule beats an instruction
   every time. Instructions are advisory; a failing test is not.
3. **Move it up.** If it is truly load-bearing, put it in the first 30 lines and mark
   it. Position matters.

---

*Part of [claude-blueprint](https://github.com/eugnmueller-87/claude-blueprint).*
