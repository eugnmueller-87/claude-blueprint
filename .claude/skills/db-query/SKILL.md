---
name: db-query
description: Safe read-only exploration of spend/supplier data via SQL or pandas — read-only by default, writes require explicit opt-in, and no destructive statement without a WHERE clause. Use to answer a data question against a spend/supplier dataset or database. Trigger phrases "query the spend data", "check this in SQL", "explore this dataset".
---

# db-query

Trigger: "query the spend data" / "check this in SQL" / "explore this dataset"

Standing rules: [`../_conventions.md`](../_conventions.md).

Answer the data question without risking the data. Read-only is the default.
Never run a destructive statement on a hunch, and never invent numbers — every
figure comes from a query you actually ran. Procurement domain: spend,
suppliers, categories, savings, compliance.

## Steps

1. **Locate the source.** A `.db`/`.sqlite`, a connection configured via env vars
   (never hardcoded creds), or a CSV/Parquet for pandas. Confirm which. If it's a
   live DB, connect with a read-only credential where possible.

2. **Understand the shape first.** For SQL: list tables and columns (`.schema` /
   `information_schema`). For pandas: `df.head()`, `df.dtypes`, `df.shape`. State
   the relevant columns before querying — don't guess column names.

3. **Read-only by default.** `SELECT` / pandas filters and aggregations only.
   Every exploratory query is non-mutating. Show the query, then the result.

4. **Writes require explicit opt-in.** If the task genuinely needs an
   `INSERT`/`UPDATE`/`DELETE`, STOP and confirm with Eugen first. Then:
   - Never `DELETE`/`UPDATE` without a `WHERE` clause (the
     `block-dangerous-commands` hook enforces this too).
   - Preview the affected rows with a `SELECT` using the same `WHERE` before
     running the mutation.
   - Wrap in a transaction where the engine supports it.

5. **Answer with the numbers.** Give the actual result — top suppliers by spend,
   savings %, category totals, compliance gaps, whatever was asked. Show the
   query so it's reproducible and auditable. Round money sensibly; state the
   currency and time window.

6. **Report** (terse): the answer first, then the query that produced it, then
   any caveat (nulls dropped, date range, dedupe applied). Never present a number
   you didn't compute from the data.
