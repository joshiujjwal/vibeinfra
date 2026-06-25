# CLAUDE.md — Agent Context for vibeinfra

Keep this file current. It is the handoff doc between agent sessions. Only include
what you can't infer from the code.

## What this is

An agentic, multi-cloud deployment CLI: bring any code → governed plan → reliable
deploy. Core principle: **agent proposes, deterministic policy engine disposes
(deny-by-default).** Read `docs/spec.md` and `TODO.md` before working.

## Commands (update as they become real)

```bash
go build -o bin/vibe ./cmd/vibe   # build CLI            (TODO: valid once cmd/vibe exists)
go test ./...                     # run ALL tests        (run this FIRST every session)
golangci-lint run                 # lint                 (TODO: add config in Phase 0)
go run ./cmd/vibe <command>       # run without building
```

## Workflow (do this in order)

1. **Run the tests first** (`go test ./...`) to orient yourself and gauge health.
2. Read `TODO.md`; pick the next unchecked item in the current phase.
3. **Red:** write a failing test for the item. Confirm it fails.
4. **Green:** implement the minimum to pass. Confirm `go test ./...` is green.
5. Review your own diff. Provide evidence (test output) in the PR.
6. Commit (descriptive message + co-author trailer).
7. If you learned something durable, append to `## Lessons` below and to `AGENTS.md`.

## Directory map

| Path | Purpose |
|---|---|
| `cmd/vibe/` | CLI entrypoint + command router |
| `internal/detect/` | Repo runtime/framework detection |
| `internal/plan/` | Deployment planning (agent-proposes) |
| `internal/policy/` | OPA/Rego gate (policy-disposes) |
| `internal/providers/` | Pluggable provider adapters |
| `internal/profile/` | Layered config + profiles |
| `internal/audit/` | Immutable audit log |
| `policies/` | Rego policy bundles |
| `docs/` | spec.md, strategy.md, adr/ |

## Non-obvious conventions & gotchas

- **Deny-by-default is non-negotiable.** Never weaken a policy rule to make a test
  pass — fix the *plan*, not the *guard*. An unmatched action is denied.
- **Dry-run by default.** Mutating commands require explicit confirmation / `--yes`.
- **Destructive ops are human-gated.** Agents must never run `vibe destroy` or any
  destructive provider call. The agent skill enforces this.
- **Model/agent errors must return valid JSON.** No bare strings on the error path.
- **Provider neutrality.** No adapter may steer selection away from the cheapest
  viable provider.
- **Profiles precedence:** profile → env (`VIBE_*`) → local config.
- Phase-1 unimplemented adapters return `ErrNotImplemented` as valid JSON, not panics.

## Attribution

CLI/profile/harness patterns adapted from `hashicorp/tfctl-cli` (MPL 2.0). Strategy
from `docs/strategy.md`. Credit sources when reusing concepts.

## Lessons

- _(append durable, cross-session lessons here)_
