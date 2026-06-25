# vibeinfra — Task Breakdown

## How to Use This File

Workflow per task (evidence-gated):

1. **Write tests FIRST** — confirm they fail (red).
2. **Implement** until tests pass (green).
3. **Review the diff** manually — including any AI-written description.
4. **Commit** with a descriptive message + co-author trailer.
5. **Update `CLAUDE.md` / `AGENTS.md`** if you learned something durable (compound loop).

Each **phase is an evidence gate**: do not start the next phase until the current
phase's tests pass *and* a human has reviewed the work. Legend: ⬜ todo · 🟡 in progress · ✅ done.

---

## Phase 0: Foundation ⬜

- [ ] `go mod init` + commit `go.mod` (Go 1.20+)
- [ ] Add `golangci-lint` config (`.golangci.yml`) + Makefile targets (`build`, `test`, `lint`)
- [ ] First smoke test: `vibe version` prints a semver — failing test first
- [ ] CLI skeleton in `cmd/vibe` using a command router (`vibe <command> [subcommand]`)
- [ ] CI: GitHub Actions running `go test ./...` + lint on PR
- [ ] Review AI config files (CLAUDE.md, AGENTS.md, copilot-instructions.md)

## Phase 1: Profiles & Auth (port tfctl patterns) ⬜

- [ ] Write spec section for layered config in `docs/spec.md`
- [ ] Failing tests for profile precedence: profile → env (`VIBE_*`) → local (red)
- [ ] Implement `internal/profile`: create/list/switch profiles, `vibe profile set <key> <val>`
- [ ] `vibe auth login` — provider token capture + plain-text store (document the tradeoff)
- [ ] Audit-log every auth + config mutation (`internal/audit`)

## Phase 2: Detect ⬜

- [ ] Spec the detection contract (input: repo path → output: `RuntimeProfile`)
- [ ] Failing tests with fixture repos: Next.js, static site, Dockerfile, generic Node/Go API (red)
- [ ] Implement `internal/detect`: framework, runtime, build/output dirs, port
- [ ] `vibe detect ./path` prints structured result (JSON + human)

## Phase 3: Policy Engine (deny-by-default) ⬜

- [ ] Embed OPA (Rego) evaluation in `internal/policy`
- [ ] Author baseline `policies/`: approved providers, allowed regions, cost ceiling, deny `destroy` for agents
- [ ] Failing tests: a plan that violates a rule is **denied**; compliant plan **allowed** (red)
- [ ] Decision output is explainable: *what* was denied and *why* (for audit)
- [ ] **Never** weaken a policy to pass a test — fix the plan instead

## Phase 4: Plan (agent-proposes / policy-disposes) ⬜

- [ ] Spec the `DeploymentPlan` data model in `docs/spec.md`
- [ ] Failing tests: detect → plan produces a valid plan; plan is run through policy gate (red)
- [ ] Implement `internal/plan`: deterministic planner first (LLM layer is later/optional)
- [ ] Cost estimate per candidate provider (stub pricing tables → arbitrage later)
- [ ] `vibe plan ./path` shows plan + policy verdict + cost; **dry-run by default**

## Phase 5: Provider Adapters ⬜

- [ ] Define `Provider` interface (`internal/providers`): `Detect`, `EstimateCost`, `Deploy`, `Destroy`, `Status`
- [ ] Implement **Vercel** adapter first (highest leverage, simplest) — red/green
- [ ] Implement **Cloudflare** adapter (Pages/Workers) — red/green
- [ ] Implement **AWS** adapter (start: static→S3/CloudFront, or App Runner) — red/green
- [ ] Stub registered adapters: **Azure, Railway, Fly.io, Render** (return `ErrNotImplemented`, valid JSON)
- [ ] Adapter conformance test suite all adapters must pass

## Phase 6: Deploy & Observe ⬜

- [ ] `vibe deploy ./path --provider <p>` — execute approved plan, stream logs
- [ ] Human-in-the-loop approval gate for high-blast-radius changes
- [ ] Custom domain attach
- [ ] Drift detection + `vibe status`
- [ ] Verified-cost reporting (predicted vs. realized) — flywheel input

## Phase 7: Agent Harness ⬜

- [ ] `.github/skills/vibe` skill: lets agents run `vibe`, **denies destroy/destructive ops**
- [ ] `vibe harness install <agent>` (adapt tfctl's harness install UX)
- [ ] Ensure every agent-driven action is policy-gated and audit-logged

## Phase 8: Ship ⬜

- [ ] End-to-end demo: upload sample repo → governed plan → deploy to Vercel → domain live
- [ ] Release binary + Homebrew tap notes
- [ ] Security-review package (audit log proof, policy whitepaper)

---

## Parking Lot 🅿️

- TypeScript agent/LLM proposal layer + minimal web upload UI
- Cross-provider price-arbitrage engine (normalized SKU/egress model)
- SSO/SCIM, SOC 2 controls, immutable remote audit sink
- "Enterprise Model" governance source-of-truth (org-wide policy bundles)

## Lessons Learned 📝

- _(append durable lessons here; mirror the important ones into CLAUDE.md/AGENTS.md)_
