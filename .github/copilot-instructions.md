# GitHub Copilot Instructions — vibeinfra

## Stack

- **Go 1.20+** single-binary CLI (`cmd/vibe`), logic in `internal/*`.
- **OPA / Rego** policy engine (deny-by-default) in `internal/policy` + `policies/`.
- Pluggable **provider adapters** (Vercel, AWS, Cloudflare, Azure, Railway, Fly.io, Render).
- TypeScript agent/web layer comes later (see `TODO.md` Parking Lot).

## Architecture in one line

Agent **proposes** a `DeploymentPlan` → deterministic policy engine **disposes**
(deny-by-default) → approved plan deploys via a provider adapter. Read `docs/spec.md`.

## Coding conventions (Go)

- `gofmt`/`goimports` clean; small functions; **early returns** over nested `if`.
- Wrap errors with context (`fmt.Errorf("...: %w", err)`); never swallow errors.
- Prefer interfaces + dependency injection for testability; avoid global state.
- Provider adapters implement the `Provider` interface; unimplemented ones return
  `ErrNotImplemented` as **valid JSON**, never panic.
- Document exported identifiers; comment only non-obvious logic.

## Testing conventions

- **Red/green TDD**: failing test first, then implement. Never skip the red phase.
- Table-driven tests; names: `Test_<unit>_<behavior>_when_<condition>`.
- Always cover error paths and edge cases; **model/agent errors must be valid JSON**.
- Run `go test ./...` before and after changes.

## Safety (hard rules)

- **Deny-by-default** — never weaken a policy to make a test pass.
- **No destructive ops by agents** — never invoke `vibe destroy` or destructive provider calls.
- **Dry-run by default** — mutations require explicit confirmation.
- **Provider neutrality** — never bias selection away from the cheapest viable provider.

## Boundaries

- Only modify files relevant to the current `TODO.md` task.
- Don't refactor or "clean up" unrelated code unless asked.
- Don't remove or weaken existing tests.
- Add comments only when logic is non-obvious.
- Ask before large multi-file changes.

## Attribution

CLI/profile/harness patterns adapted from `hashicorp/tfctl-cli` (MPL 2.0). Credit
sources when reusing existing repos or concepts.
