---
applyTo: "internal/providers/**"
---

# Provider adapter instructions

Every adapter implements the `Provider` interface (see `docs/spec.md` §6):
`ID, Detect, EstimateCost, Deploy, Destroy, Status`.

Rules:

- **Neutrality** — never bias selection toward your own provider; report honest
  cost estimates. The planner picks the cheapest *viable* option.
- **Destroy is human-gated** — `Destroy` must refuse when invoked by a non-human
  agent context; surface a clear, JSON-valid error.
- **Unimplemented adapters** (Azure, Railway, Fly.io, Render in Phase 1) return
  `ErrNotImplemented` as **valid JSON**, never panic.
- **No secrets in code** — read credentials from the active profile / env only.
- **Conformance** — every adapter must pass the shared adapter conformance suite.
- **Idempotency** — `Deploy` should be safe to retry; prefer plan→apply semantics.
