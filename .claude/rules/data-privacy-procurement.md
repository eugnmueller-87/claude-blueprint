---
paths:
  - "**/data/**"
  - "**/suppliers/**"
  - "**/spend/**"
  - "**/ingest/**"
  - "**/compliance/**"
  - "**/*supplier*.py"
  - "**/*spend*.py"
---

# Data Privacy — Procurement Domain

- Treat all supplier, spend, contract, and personal-contact data as **confidential + GDPR-relevant**. Default deny: don't copy it into logs, prompts, LLM traces, eval fixtures, or test data unredacted.
- **Minimize before sending to any external LLM/API.** Redact or pseudonymize supplier names, prices, contract terms, and personal data unless the task genuinely requires them and the provider terms allow it. Prefer local/self-hosted models for the most sensitive slices.
- Never train/fine-tune or send data to a provider that trains on inputs without explicit sign-off; note data-processing terms per provider.
- Compliance data (OFAC/UN sanctions, LkSG/CSDDD due-diligence): record **source + retrieval date** for every screening result; a finding without provenance is not a finding (ties to `no-bullshit` cite rule). Screening logic is due-diligence — never let the LLM invent a sanctions hit; verify against the actual list.
- PII (contact names, emails) stays out of derived product output unless it's a real, sourced relationship; align with the "no shit in" gate.
- Retention: don't hoard raw supplier dumps; keep raw in a controlled store, strip PII from derived artifacts.
