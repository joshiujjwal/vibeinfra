---
applyTo: "policies/**,internal/policy/**"
---

# Policy engine instructions

- **Deny-by-default**: an action that matches no `allow` rule is denied. Never
  invert this default.
- **Never weaken a policy to make a test pass.** If a plan is denied, fix the
  *plan*, not the guard.
- Every denial must be **explainable**: emit a rule id + human-readable reason for
  the audit log.
- Policies are versioned; record the bundle version in each `PolicyVerdict`.
- Baseline rules to maintain: approved providers, allowed regions / data residency,
  monthly cost ceiling, and **deny `destroy` for agent contexts**.
- Keep Rego pure and table-testable; add an allow *and* a deny test for every rule.
