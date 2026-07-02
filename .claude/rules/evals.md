---
paths:
  - "**/evals/**"
  - "**/eval/**"
  - "**/*_eval.py"
  - "**/test_prompts*.py"
  - "**/golden/**"
  - "**/fixtures/llm/**"
---

# Evals (LLM output correctness)

- Maintain a **golden set** of representative inputs to expected outputs/assertions. New behavior gets a case before it ships.
- Assert on properties, not exact strings, for generative output: schema-valid, required fields present, in allowed set, factual claim grounded in provided source, no PII leak.
- LLM-as-judge is allowed only with a rubric + a pinned judge model, spot-checked against human labels; never a bare "is this good?" call.
- Track a scorecard over time (pass rate, cost, latency per case). A prompt/model change that lowers the score is a regression — block it.
- Evals never hit prod data or paid APIs uncontrolled: use recorded fixtures; gate live-API eval runs behind an env flag and a cost cap.
- Retrieval and generation get separate eval suites (accuracy of what's fetched vs. quality of the answer).
