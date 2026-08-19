# The nine rules, and what they cost

Every rule in `CLAUDE.md` comes from a real incident while building and running a
personal AI assistant in production: a Python/FastAPI backend on Railway, a React
PWA front end, ~30 tools, integrations with mail, calendar, GitHub and a note vault.

Dates are real. Numbers are real. Nothing here is a hypothetical.

**Read this once to understand why the rules are phrased the way they are, then
work from `CLAUDE.md`.**

---

## 1. Never claim an action you did not verify

**What happened (2026-08-09).** Two tools reported success and did nothing:

| Tool | Said | Did |
|---|---|---|
| CSV export | *"Sending the file now."* | nothing — the function that delivers files was never called |
| Email reply staging | *"staged for approval"* | nothing — the confirmation step had no caller |

**Same root cause.** The part that executed had lived in a Telegram bot. The bot was
removed on 2026-08-08. **The sentence stayed in the code; the action left with the
bot.**

**Why it is rule 1.** A failure that announces itself gets fixed. A false completion
report gets believed. The user ticks the task off and finds out weeks later.

**How to check.** For every string in your codebase that claims an action, find the
line that performs it. If you cannot, that string is a lie waiting to be told.

---

## 2. Add, don't replace

**What happened (2026-08-12).** A project board's single-select field had its option
list replaced twice in one day, each time to add exactly one option. **Both times
the platform dropped all 63 card assignments.**

Worse, a saved snapshot of "how the board should look" was written back, which would
have silently reverted moves the user had made himself.

**Why it is rule 2.** An outage is loud: the board is empty, you notice. **Reverted
work is quiet.** Nobody notices until they look for something that was there
yesterday.

**The general form.** Assume the human is working in the same system in parallel.
No stored snapshot is ever the authority.

---

## 3. Read the input schema before believing an API can only replace

**The follow-up to rule 2, and the more useful half.**

The original note said "this API can only replace the whole list, so the loss was
unavoidable". **That was wrong.** The input type has an `id` field. Existing entries
sent *with* their id keep every assignment. Sent *without*, the platform treats them
as new options and every card loses its value.

**Three total losses in one day traced back to one missing line.**

**How to check.** Before writing "this API can only replace": open its input type
definition. Look for an identifier field on the nested objects. It is there more
often than not.

---

## 4. A commit is not a deploy

**What happened (2026-08-17).** A one-line front-end fix was committed, pushed, and
deployed. The deploy succeeded. The version endpoint reported the new commit SHA.
**The change was not live.**

The `Dockerfile` installed Python dependencies and started the server. There was no
`npm` step. What actually shipped was a pre-built bundle committed to the repo. The
source change compiled nowhere.

**The tell that was missed.** "The version endpoint reports the new commit" was
treated as proof. The commit SHA says nothing about whether a build step ran.

**The check that settled it, in one line:**

```bash
curl -s https://app/assets/index-<hash>.js | grep -o '\.code?`[^`]*`'
```

Present in the new bundle, absent in the old. **That is proof; a commit SHA is not.**

---

## 5. Pass the reason through

**What happened (2026-08-17), three times in one codebase in one day.**

| Layer | What it dropped |
|---|---|
| Vault file download | Threw away the platform's explanation, reported only `HTTP 403` |
| Stream error handling | Collapsed every non-retryable 4xx into one fixed sentence |
| Front-end error display | Received a stable error `code` over the wire and rendered only the message |

The third one is the sharpest: **the cause was already on the wire.** The server had
been sending it all along. The UI just did not read the field.

**What it cost.** An evening. The actual cause was an exhausted API credit balance,
which the provider returns as a `400 invalid_request_error` — the same class as a
malformed request or an oversized conversation. Four very different causes, one
indistinguishable message. Deploys, a rollback and three discarded hypotheses later,
topping up the account fixed it in thirty seconds.

**The general form.** Uniform messages for users are a legitimate security choice.
But the cause must survive somewhere an operator can reach: a log line, an error
code, a status page. **Classify the error, then forward what you learned.**

---

## 6. Measure what matters, not what is easy

**What happened (2026-08-17).** The health endpoint reported:

```
anthropic   ok   key valid
```

while every single request was failing. **Both statements were true.** The key *was*
valid. `GET /v1/models` returns 200 with a zero balance. The check measured what it
could measure rather than what mattered.

**The fix was not a better probe.** A billable call on every health check is money
spent on a question a real failure already answers. Instead the router now remembers
the last genuine credit failure and the health endpoint asks it.

**How to check.** When a check goes green, ask: *what could be broken right now that
this check would still call healthy?* If the answer is "the actual feature", you are
measuring the wrong thing.

---

## 7. Turn the task into a verifiable goal before writing code

**The generalisation of rules 4 and 6**, and the only rule here that is preventive
rather than forensic.

Both of those failures were goal failures before they were technical ones:

- Rule 4's goal was *"the commit is live"* instead of *"the change is provable in
  the shipped artifact"*
- Rule 6's goal was *"the credential works"* instead of *"a request succeeds"*

**In both cases the wrong goal was easy to hit and told you nothing.**

Write the acceptance criterion before the code. If you cannot state how you will
recognise success, you are not ready to start.

---

## 8. An alert with no channel is not an alert

**What happened (2026-08-17).** A scheduled health check correctly detected that
three capabilities were dead. It failed five consecutive runs over two hours. The
log line read:

```
CAPABILITY DEAD: file fetch, file export, search
no webhook URL configured, skipping (the platform still emails)
```

**The detection worked perfectly. There was nobody to tell.** The chat webhook
variable had never been set. The previous notification channel had been removed nine
days earlier along with the bot that used it.

The system knew at 15:35. The human found out at about 21:00 by trying to use a
feature, and spent the evening debugging an outage that had already been diagnosed
by his own monitoring.

**The irony.** The workflow file contained a comment reading *"an alert in a channel
nobody opens is not an alert"*. The comment was right. The wiring was not.

**How to check.** Trigger the failure path deliberately. If no human is interrupted,
you have logging, not alerting.

---

## 9. Every test says which failure forced it into existence

**Not an incident. A practice that made the other eight stick.**

Each test file opens with a docstring: what happened, on what date, what it cost,
and which test in the file is the one that matters. For example:

```python
"""A 403 without a reason is a dead end.

On 2026-08-17 a file request failed and the assistant reported
"vault access error (HTTP 403, not something on your end to fix)".

The reassurance was invented — the model had nothing else. The download
function forwarded only the status code and discarded the platform's own
explanation, while the function directly beside it had always passed the
reason through.

Core test: test_rate_limit_names_the_wait.
"""
```

**Why it matters.** Six months later this docstring is the only thing standing
between a confusing test and someone deleting it during a cleanup. A test nobody
understands gets removed the first time it is inconvenient — usually right before it
would have caught the same bug again.

**It also makes the rule survive the person.** `CLAUDE.md` says what to do. The test
docstring says why, in the place where the code lives.

---

## The meta-rule

**If a rule has never cost you anything, delete it.**

Every line in `CLAUDE.md` is paid for in every request. Nine rules that each cost a
real afternoon beat forty that sound sensible. Borrow this file to understand the
method, then replace the incidents with your own.
