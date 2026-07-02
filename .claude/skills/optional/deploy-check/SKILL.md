---
name: deploy-check
description: Pre- and post-deploy sanity check for a Railway or Vercel target — confirm required env vars are set, the health endpoint responds, and the logs are clean after release. Use before or right after deploying a service (e.g. the Telegram bot on Railway). Trigger phrases "check the deploy", "is it live", "did the deploy work".
---

# deploy-check

Trigger: "check the deploy" / "is it live" / "did the deploy work"

Standing rules: [`../../_conventions.md`](../../_conventions.md).

Confirm the deploy is actually healthy — don't declare it live off a green build
badge. Check the running thing. Never print secret values while inspecting env
config.

## Steps

1. **Identify the target.** `railway.json` / `Procfile` → Railway;
   `vercel.json` → Vercel. Confirm which service and environment (prod vs
   staging). Use the platform CLI if present (`railway`, `vercel`) or the MCP
   tools if configured.

2. **Env-var presence (not values).** Compare `.env.example` against the deploy
   target's configured variables. Report any REQUIRED var that's missing — by
   name only, never value. A missing key is the most common silent deploy
   failure.

3. **Health check.** Hit the health/root endpoint (or, for the Telegram bot,
   confirm the webhook is set / the worker is running). Expect a 200 / a live
   response. If it times out or errors, that's the finding — show the status.

4. **Logs.** Pull recent logs (`railway logs`, `vercel logs`, or the dashboard).
   Scan for tracebacks, boot loops, `ModuleNotFoundError`, or repeated restarts
   in the minutes after deploy. Quote the first real error, not the noise.

5. **Report** (terse): target + env · env vars OK / missing (names) · health
   200? · logs clean? End with a clear verdict — live and healthy, or the one
   thing blocking it. Don't say "live" unless the endpoint actually answered.
