# ADR-0002: Agent-proposes / policy-engine-disposes

- **Status:** Accepted
- **Date:** 2026-06-24
- **Deciders:** Founding team

## Context

The defensible product is governance, not the deploy UX (see `docs/strategy.md`).
Letting an LLM directly mutate production cloud is not production-safe; reviewers
(CISOs, platform teams) require deterministic, auditable guardrails. The strategy
research is explicit: the naive "LLM directly mutates prod cloud" architecture
should be avoided.

## Decision

We will architect vibeinfra so that an **agent proposes** a `DeploymentPlan`, and a
**deterministic policy engine (OPA / Rego) disposes** — evaluating every plan
**deny-by-default** before any mutation. The LLM's creativity is bounded by a
verifiable policy layer; every decision is explainable and audit-logged.
Destructive operations are human-gated and denied to non-human agents.

## Alternatives considered

- **Trust the LLM (no deterministic gate)** — fastest demo, but unsafe for prod
  and unsellable to security teams. Rejected.
- **Custom Go policy DSL** — full control, but reinvents a solved problem and lacks
  the ecosystem/trust of OPA. Deferred as a fallback.
- **OPA / Rego** — industry-standard policy-as-code, explainable, deny-by-default,
  recognized by security reviewers. **Chosen.**

## Consequences

- Positive: production-safe; security-reviewable; audit trail; trust moat.
- Tradeoffs: Rego learning curve; planner must emit policy-evaluable plans.
- Follow-ups: define the "high blast radius" threshold that forces human approval.
