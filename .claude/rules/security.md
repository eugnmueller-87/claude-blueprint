---
paths:
  - "**/*.py"
  - "src/api/**"
  - "src/auth/**"
  - "src/middleware/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/agents/**"
  - "**/tools/**"
---

# Security

- Validate all user input at the system boundary. Never trust request parameters.
- Sanitize output to prevent XSS. Use framework-provided escaping.
- Authentication tokens must be short-lived. Store refresh tokens server-side only.
- Never log secrets, tokens, passwords, or PII.
- Use constant-time comparison (`hmac.compare_digest`) for secrets and tokens.
- Set appropriate CORS, CSP, and security headers. Rate-limit auth and LLM-cost-bearing endpoints.
- **Parameterized SQL only** — never f-string/`%`/`+` user input into a query (SQLAlchemy bound params, `?`/`%s` placeholders). Same for shell: never interpolate into `subprocess`; pass an arg list with `shell=False`.
- Never `eval`/`exec`/`pickle.load` untrusted input; use `yaml.safe_load`, not `yaml.load`.
- Validate all input at the boundary with **pydantic** models; reject unexpected fields.
- **LLM-specific:** treat model output as untrusted — never `eval`/exec it, validate/parse tool-call args before use, and sandbox or allowlist any tool the model can invoke that touches the filesystem, shell, or network.
