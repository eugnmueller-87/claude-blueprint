---
name: data-contract
description: Validate a dataframe, CSV, or API payload against an expected schema before it flows into a pipeline — required columns, types, nullability, ranges, and key uniqueness — so bad data fails loud at the boundary instead of silently corrupting downstream. Use for spend/supplier ingest. Trigger phrases "check this schema", "validate the data", "does this data match the contract".
---

# data-contract

Trigger: "check this schema" / "validate the data" / "does this data match the contract"

Standing rules: [`../../_conventions.md`](../../_conventions.md).

Bad data should fail at the door, not three transforms later as a silent wrong
number. Validate against an explicit contract and report every violation. Never
"clean" data silently — surface what's wrong and let the caller decide.

## Steps

1. **Establish the contract.** If the project has a schema (pandera, pydantic, a
   JSON Schema, a dbt/Great Expectations spec), use it. If not, derive the
   expected contract from how the data is consumed downstream and state it
   explicitly: required columns, dtype per column, nullable or not, allowed
   ranges/enums, unique keys.

2. **Load a sample and inspect.** `df.head()`, `df.dtypes`, `df.shape`,
   null counts per column. For an API payload, the top-level keys and types.

3. **Check against the contract:**
   - Missing/extra columns vs expected.
   - Type mismatches (numbers as strings, dates unparsed).
   - Nulls in non-nullable columns (count and %).
   - Out-of-range / invalid-enum values (negative spend, unknown currency,
     future dates).
   - Duplicate keys where a key must be unique (e.g. supplier id, invoice id).
   - Encoding/whitespace issues in join keys.

4. **Report violations, don't fix them.** List each violation: column · rule
   broken · count · a couple of example bad rows. Rank by how much it would
   corrupt downstream. Offer the fix as a proposal — don't mutate the source data
   without the OK.

5. **Verdict** (terse): PASS (matches the contract) or FAIL with the blocking
   violations. If FAIL, name the single most damaging one first. Only say PASS
   because you actually ran the checks.
