---
paths:
  - "**/*.sql"
  - "**/*.ipynb"
  - "**/data/**"
  - "**/etl/**"
  - "**/analysis/**"
  - "**/*_pipeline.py"
---

# Data: pandas / SQL / Power BI

- **Parameterized SQL only**, always (see `security.md`) — no string-built queries, even in notebooks.
- pandas: never `inplace=True` chains that hide dtype coercions; prefer explicit assignment. Set/validate dtypes on load; parse dates explicitly. Use `chunksize` for large files — don't load a giant spend export into RAM blind.
- No `SettingWithCopyWarning` left unresolved — use `.loc`, `.copy()`. No silent NaN handling: decide and document fill/drop; don't let NaN propagate into savings/spend numbers.
- **Financial numbers use `Decimal` or integer cents**, never binary float, for money/savings/should-cost. Carry the currency; never sum mixed currencies.
- Every transform is reproducible: raw input to output via committed code, no manual Excel steps baked in. Record source file + row count in/out.
- Notebooks are for exploration; **promote reusable logic into a `.py` module** with tests before it becomes a pipeline. Clear notebook outputs before commit (no data/PII in cell outputs in git).
- Power BI / exports: document the query + refresh source; don't hardcode a local file path that only exists on one machine.
