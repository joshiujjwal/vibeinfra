# vibeinfra — Feature Specification

> Status: draft. Update this **before** implementing each phase (spec-driven development).

## 1. Overview & problem statement

Teams (and non-engineers) want to ship code without learning each cloud's
provisioning model, and orgs want governance without slowing delivery. Today:
shadow IT consumes 30–40% of IT spend, ~32% of cloud spend is wasted, and 89% of
orgs are multi-cloud (see `docs/strategy.md`). No tool combines non-engineer
accessibility, real multi-cloud infra, cross-provider price arbitrage, and
agent-enforced governance.

**vibeinfra** closes that gap: *bring any code → governed plan → reliable deploy
→ cost/drift observability*, where an AI agent **proposes** and a deterministic
policy engine **disposes** (deny-by-default).

## 2. Functional requirements

- [ ] **FR1** — Detect a repo's runtime (framework, build/output, port) from a path.
- [ ] **FR2** — Produce a `DeploymentPlan` for one or more candidate providers.
- [ ] **FR3** — Evaluate every plan against a deny-by-default policy bundle (OPA/Rego); output an explainable verdict.
- [ ] **FR4** — Deploy an approved plan to a selected provider and stream logs.
- [ ] **FR5** — Manage layered config via profiles (`vibe profile ...`), precedence: profile → env → local.
- [ ] **FR6** — Authenticate per provider (`vibe auth login`), tokens stored per profile.
- [ ] **FR7** — Estimate cost per candidate provider; report predicted vs. realized.
- [ ] **FR8** — Detect drift and report status (`vibe status`).
- [ ] **FR9** — Expose an agent skill that runs `vibe` but **denies destructive ops** to non-human agents.
- [ ] **FR10** — Append an immutable audit record for every auth, config change, plan, deploy, and destroy.

## 3. Non-functional requirements

- [ ] **NFR1** — Single portable Go binary; no runtime daemon required for the CLI.
- [ ] **NFR2** — Dry-run by default; mutations require explicit confirmation or `--yes`.
- [ ] **NFR3** — Deny-by-default: an unmatched action is denied, not allowed.
- [ ] **NFR4** — Every error returned by the agent/model layer is **valid JSON**.
- [ ] **NFR5** — Provider-neutral: no adapter may bias provider selection away from the cheapest viable option.
- [ ] **NFR6** — Reproducible plans: same repo + same policy bundle → same plan + verdict.

## 4. Data model (initial)

```go
// RuntimeProfile — output of detect
type RuntimeProfile struct {
    Framework  string   // "nextjs" | "static" | "docker" | "node-api" | "go-api" | "unknown"
    Runtime    string   // e.g. "nodejs20", "go1.20", "container"
    BuildCmd   string
    OutputDir  string
    Port       int
    Confidence float64
}

// DeploymentPlan — agent proposes, policy disposes
type DeploymentPlan struct {
    Repo         string
    Runtime      RuntimeProfile
    Provider     string             // candidate provider id
    Region       string
    Resources    []Resource
    CostEstimate Money              // monthly estimate
    Approved     bool               // set only after policy + human gate
}

// PolicyVerdict — explainable, deny-by-default
type PolicyVerdict struct {
    Allowed bool
    Denials []Denial   // rule id + human-readable reason
    Policy  string     // bundle version evaluated
}
```

## 5. Interface design (CLI)

`vibe <command> [subcommand] [flags] [arguments]` (mirrors `tfctl`).

| Command | Purpose |
|---|---|
| `vibe auth login` | Capture provider token (browser flow), store per profile |
| `vibe profile set <key> <value>` | Set layered config (e.g. `default_provider`) |
| `vibe detect <path>` | Print `RuntimeProfile` (human + `--json`) |
| `vibe plan <path>` | Build plan(s), run policy gate, show cost — **dry-run** |
| `vibe deploy <path> --provider <p>` | Execute approved plan, stream logs |
| `vibe status` | Drift detection + live status |
| `vibe destroy <id>` | **Human-gated**, denied to agents by default |
| `vibe harness install <agent>` | Install the agent skill |

## 6. Provider adapter contract

```go
type Provider interface {
    ID() string
    Detect(rp RuntimeProfile) (bool, error)        // can this provider host it?
    EstimateCost(p DeploymentPlan) (Money, error)
    Deploy(ctx context.Context, p DeploymentPlan) (DeployResult, error)
    Destroy(ctx context.Context, id string) error  // human-gated upstream
    Status(ctx context.Context, id string) (Status, error)
}
```

Phase-1 adapters: **Vercel, Cloudflare, AWS** implemented; **Azure, Railway,
Fly.io, Render** registered but return `ErrNotImplemented` (as valid JSON).

## 7. Test plan

- **Unit:** detect fixtures; policy allow/deny matrices; profile precedence; cost math.
- **Integration:** detect→plan→policy pipeline; adapter conformance suite.
- **Edge cases:** unknown framework; empty repo; policy-denied plan; agent attempting `destroy`; provider token missing; model error returns valid JSON.
- **Golden:** reproducible plan snapshots per fixture.

## 8. Open questions

- [ ] Where do we draw the "high blast radius" line for mandatory human approval?
- [ ] Normalized cross-provider pricing model — own SKU schema vs. provider pricing APIs?
- [ ] Token storage hardening beyond plain text (OS keychain?) — Phase 1 vs. later.
- [ ] Deterministic planner vs. LLM planner — keep deterministic as the verifiable floor.
