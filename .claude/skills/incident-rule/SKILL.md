---
name: incident-rule
description: Turn a bug you just fixed into a permanent rule in CLAUDE.md, written in the user's own voice with the incident attached. Use right after debugging something avoidable, or when the user says "remember this", "don't do that again", "add this to CLAUDE.md", or "that cost me hours".
license: MIT
---

# incident-rule

**Turn the afternoon you just lost into a rule that stops it happening twice.**

A rule with an incident attached gets followed. A rule without one gets ignored,
because there is no moment where the agent can recognise it is about to break it.

---

## When to run this

- Right after fixing something that took far longer than it should have
- When the user says "remember this", "never do that again", "that cost me hours"
- At the end of a debugging session that ended in a facepalm
- **Not** for ordinary bugs. If it did not cost real time, it does not earn context
  space.

## The gate, before anything else

**Ask: did this actually cost something?**

If the answer is "not really, it was a normal bug", say so and stop. Do not write
the rule. Every rule is paid for in every future request, and a `CLAUDE.md` full of
mild preferences is worse than a short one full of scars.

---

## The four questions

Work these out from the session yourself wherever possible. Only ask the user what
you genuinely cannot determine.

**1. What did we believe that turned out to be false?**
Not "what broke" — what *assumption* broke. This is the part that generalises.
*Example: "a green deploy with the new commit SHA means the change is live."*

**2. What was the exact moment the wrong path was taken?**
The recognisable situation. If the rule cannot name a moment, it is a mood and will
be ignored.
*Example: "when treating a version endpoint as proof that a build step ran."*

**3. What did it cost?**
Hours, a rollback, lost data, a wrong answer given to someone. Be specific and be
honest — do not inflate it and do not round it down.

**4. How would we recognise the same moment next time?**
Ideally a command, a check, or a question. A rule that ends in a runnable check is
worth three that end in advice.
*Example: `curl the shipped artifact and grep for a distinctive string from the change`*

---

## Write it

Append to the project's `CLAUDE.md`, in this shape:

```markdown
## N. [The rule, as an imperative]

> **[One-line form, quotable.]**

[Two or three sentences on why, in the user's own voice. Match the tone of the
surrounding file: if the rest is terse, be terse.]

**What happened (YYYY-MM-DD):** [the incident, concretely — what was believed, what
was done, what it cost]

**How to check:** [the command, question or test]
```

### Rules for the writing

- **Use the user's language.** If the rest of `CLAUDE.md` is in German, write German.
  Match the existing tone, not a house style.
- **Keep the date.** It is what makes the rule credible in six months.
- **Name the cost plainly.** "Three total losses in one day" beats "caused issues".
- **No hedging.** Not "you should probably avoid" — "never do X".
- **Prefer a check to a warning.** If the incident can be caught by a test, write the
  test instead and let the rule point at it.

---

## After writing

**1. Check the file is not bloating.** If `CLAUDE.md` is past roughly 150 lines, say
so and ask which existing rule has never cost anything. Adding without pruning is
how instruction files become wallpaper.

**2. Offer the test.** Many rules are better as an executable check. If this one is,
say so and offer to write it — with a docstring naming the same incident, so the
lesson lives where the code lives.

**3. Do not touch anything else.** Append the rule. Do not reorganise, renumber for
tidiness, or "improve" neighbouring rules while you are in there. That is rule 2 of
the blueprint, and it applies to this file too.

---

## Example output

From a real session:

```markdown
## 4. A commit is not a deploy

> **Verify the change is present in what actually ships.**

A green build, a merged commit and a version endpoint reporting the new SHA can all
be true while the change is not live.

**What happened (2026-08-17):** a one-line front-end fix was committed, pushed and
deployed successfully. The health endpoint reported the new commit. The change was
not live: the Dockerfile has no npm step, and what ships is a pre-built bundle
committed to the repo. The source change compiled nowhere. Cost: one wasted deploy
cycle and a false "it's fixed" reported to the user.

**How to check:**
```bash
curl -s https://app/assets/index-<hash>.js | grep -o '<distinctive string>'
```
Present in the new bundle, absent in the old. A commit SHA is not proof.
```

---

*Part of [claude-blueprint](https://github.com/eugnmueller-87/claude-blueprint).*
