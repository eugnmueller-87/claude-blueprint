# Optional skills

These are complete, working skills that are **not** loaded by default because
they only apply to some projects. They live here so they're discoverable without
taxing every project's context. To activate one, move its directory up into
`.claude/skills/`:

```bash
mv .claude/skills/optional/deploy-check .claude/skills/
```

| Skill | Activate when the project… | Does |
|---|---|---|
| [deploy-check](deploy-check/SKILL.md) | deploys to Railway or Vercel | Pre/post-deploy sanity: env vars present, health endpoint, clean logs. |
| [perf-scan](perf-scan/SKILL.md) | has a real performance surface | Finds N+1 queries, blocking calls in async, unbatched API calls, pandas full-scans. |
| [data-contract](data-contract/SKILL.md) | ingests external data (CSV/API/df) | Validates a payload against an expected schema before it enters a pipeline. |
