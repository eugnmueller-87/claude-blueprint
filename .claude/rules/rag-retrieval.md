---
paths:
  - "**/rag/**"
  - "**/retrieval/**"
  - "**/embeddings/**"
  - "**/vectorstore/**"
  - "**/*_index.py"
  - "**/ingest/**"
---

# RAG & Retrieval

- Chunk deliberately: size + overlap chosen for the content, documented. No silent 512-default magic numbers.
- Pin the embedding model id in config; **re-embed the whole store on any model change** — never mix embedding spaces in one index.
- Prefer **hybrid retrieval** (dense + keyword/BM25) over pure vector; re-rank when precision matters. Return top-k with scores + source metadata for citation.
- Every retrieved chunk carries provenance (source id, path, offset) so answers can cite — this powers the "cite the source" rule.
- Ground generation strictly in retrieved context; instruct the model to say "not found in sources" rather than hallucinate. Show the sources it used.
- Store index build config (model, chunker, params) alongside the index; a stale-config index is a bug.
- Evaluate retrieval separately from generation (recall/precision on a fixed query set) — see `evals.md`.
