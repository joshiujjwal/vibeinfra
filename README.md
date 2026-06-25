# vibeinfra

> Bring any code. Get it deployed reliably, anywhere — with guardrails the AI agent can't cross.

![Status](https://img.shields.io/badge/status-🚧%20early%20development-orange)
![License](https://img.shields.io/badge/license-MPL%202.0-brightgreen)

**vibeinfra** is an agentic, multi-cloud deployment composer. You point it at a
repository; it detects the runtime, an AI agent **proposes** a governed
deployment plan, a deterministic **policy engine disposes** (deny-by-default),
and — once approved — it deploys to the cheapest viable provider (Vercel, AWS,
Cloudflare, Azure, Railway, Fly.io, Render) and tracks cost & drift.

The wedge is **not** "upload & deploy" (easily copied). It is the
**agent-proposes / policy-engine-disposes** architecture plus **neutral
cross-provider cost arbitrage** — the durable, governance-first surface
identified in [`docs/strategy.md`](docs/strategy.md).

## Why it's different

| Capability | Retool | Vercel/v0 | Terraform/Pulumi | **vibeinfra** |
|---|---|---|---|---|
| Non-engineer accessible | partial | yes | no | yes (NL + CLI) |
| Real multi-cloud infra | no | no | yes | **yes** |
| Cross-provider price arbitrage | no | no | no | **yes** |
| Agent-enforced policy guardrails | no | no | plan/apply only | **yes (deny-by-default)** |

## Tech stack

- **CLI core:** Go 1.20+ (single portable binary, like `tfctl`)
- **Policy engine:** Open Policy Agent (OPA) / Rego — deny-by-default
- **Provider adapters:** pluggable Go interface (Vercel, AWS, Cloudflare, Azure, Railway, Fly.io, Render)
- **Agent/web layer:** TypeScript (later phase)
- **Config:** layered profiles (profile → env → local), inspired by `tfctl`

## Getting started

```bash
git clone <repo-url> && cd vibeinfra

# Build the CLI
go build -o bin/vibe ./cmd/vibe      # TODO: confirm once cmd/vibe is implemented

# Run tests (do this first — see CLAUDE.md)
go test ./...

# Lint
golangci-lint run                     # TODO: add golangci-lint config in Phase 0
```

### First run (target UX)

```bash
vibe auth login                       # browser token flow, stored per profile
vibe profile set default_provider vercel
vibe detect ./my-app                  # what runtime did we find?
vibe plan ./my-app                    # agent proposes; policy gates; cost estimate
vibe deploy ./my-app --provider vercel
```

> `vibe destroy` and other high-blast-radius operations are **human-gated** and
> denied to non-human agents by default (see `.github/skills/vibe`).

## Project structure

```
vibeinfra/
├── cmd/vibe/            # CLI entrypoint (vibe <command> [subcommand] [flags])
├── internal/
│   ├── detect/          # repo runtime/framework detection
│   ├── plan/            # deployment planning (agent-proposes)
│   ├── policy/          # OPA/Rego gate (policy-disposes, deny-by-default)
│   ├── providers/       # pluggable provider adapters
│   ├── profile/         # layered config + profiles
│   └── audit/           # immutable audit log
├── policies/            # Rego policy bundles
├── tests/               # integration tests
├── docs/                # spec.md, strategy.md, adr/
└── .github/             # copilot-instructions, path instructions, agent skill
```

## Contributing

This repo is built for **agentic, evidence-gated development**:

1. **Red/green TDD** — write a failing test first, then implement until green.
2. **Evidence in every PR** — paste test output / manual-test notes. No unreviewed AI code.
3. **Small, focused PRs** — one concern per PR; review the diff *and* the AI-written description.
4. **Policy is sacred** — never weaken a deny-by-default rule to make a test pass.
5. **Compound loop** — update `CLAUDE.md` / `AGENTS.md` when you learn something durable.

See [`AGENTS.md`](AGENTS.md) and [`CLAUDE.md`](CLAUDE.md) for the full workflow.

## Credits & attribution

- CLI ergonomics, profile config, and the human-gated agent-skill pattern are
  adapted from HashiCorp's [`tfctl-cli`](https://github.com/hashicorp/tfctl-cli) (MPL 2.0).
- Market, moat, and architecture thesis derived from the internal research in
  [`docs/strategy.md`](docs/strategy.md) (see references therein: Spotify Golden
  Paths, Backstage, Power Platform CoE, Pulumi/Crossplane, a16z, FinOps Foundation).
