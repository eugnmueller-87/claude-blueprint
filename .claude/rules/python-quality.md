---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---

# Python Quality

- Target **Python 3.11+**. Full type hints on public function signatures; run `mypy`/`pyright` where configured.
- Format + lint with **ruff** (or black + ruff). Don't hand-format; let the formatter own style.
- Prefer `pathlib.Path` over `os.path`; f-strings over `%`/`.format`; `dataclasses`/`pydantic` models over bare dicts for structured data.
- Dependency + env management: **uv** or venv + pinned `requirements.txt`/`pyproject`. Never `pip install` into system Python; never ship a project with unpinned deps.
- No mutable default args. Use context managers (`with`) for files, DB, network, and API clients — never leak handles.
- Logging via the `logging` module, not `print`, in anything that ships. One module-level logger per module.
- Public functions/classes get a one-line docstring at the boundary; not every internal helper (defer to `code-quality`).
- No bare `except:`; catch specific exceptions (see `error-handling.md`).
