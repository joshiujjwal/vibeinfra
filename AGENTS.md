# AGENTS.md

Guidance for AI coding agents working in **vibeinfra**. (OpenAI AGENTS.md standard.)

## Setup commands

```bash
go mod download          # fetch deps
go build -o bin/vibe ./cmd/vibe
go test ./...            # run before and after every change
golangci-lint run        # lint (TODO: config added in Phase 0)
```

> First action in any session: run `go test ./...` to orient on health and coverage.

## Project shape

- Go 1.20+ single-binary CLI in `cmd/vibe`; logic in `internal/*`.
- `vibe <command> [subcommand] [flags] [arguments]` (mirrors `tfctl`).
- Architecture: **agent proposes → policy engine (OPA/Rego) disposes (deny-by-default)**.
- See `docs/spec.md` for the data model and `TODO.md` for the evidence-gated plan.

## Code style (Go)

- Run `gofmt`/`goimports`; keep functions small with **early returns** (avoid deep nesting).
- Prefer pure, testable functions; inject dependencies via interfaces.
- Wrap errors with context: `fmt.Errorf("detect: %w", err)`.
- Exported identifiers documented; comments only where logic is non-obvious.
- No global mutable state except the command registry.
- Provider adapters implement the `Provider` interface and pass the conformance suite.

## Testing (red/green TDD — mandatory)

1. Write a failing test first; **confirm it fails** (red).
2. Implement the minimum to pass; **confirm green** with `go test ./...`.
3. Cover edge cases: unknown framework, empty repo, policy-denied plan, agent
   attempting `destroy`, missing token, model error → must be **valid JSON**.
4. Never delete or weaken existing tests to go green.
5. Table-driven tests preferred; name tests `Test_<unit>_<behavior>_when_<condition>`.

## Safety rules (hard constraints)

- **Deny-by-default**: do not weaken policies to pass tests.
- **No destructive ops by agents**: never run `vibe destroy` / destructive provider calls.
- **Dry-run by default**; mutations need explicit confirmation.
- **Provider-neutral**: never bias away from the cheapest viable provider.

## PR instructions

- Title: `[phase N] <concise change>`.
- **Include evidence**: paste `go test ./...` output and/or manual-test notes. No unreviewed AI code.
- Keep PRs small and single-concern. Review the AI-written description too — it may be wrong.
- Update `CLAUDE.md` / `TODO.md` Lessons if you learned something durable.
- Commit trailer: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`.

## Attribution

Patterns adapted from `hashicorp/tfctl-cli` (MPL 2.0). Credit sources when reusing concepts.
