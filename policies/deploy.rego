# vibeinfra baseline deployment policy (deny-by-default).
#
# The policy engine DISPOSES of plans the agent PROPOSES. An action that matches
# no allow rule is denied. Never weaken these rules to make a test pass — fix the
# plan instead. See .github/instructions/policy.instructions.md.
package vibeinfra.deploy

import rego.v1

# ---- Tunable guardrails (the "Enterprise Model") ------------------------------

approved_providers := {"vercel", "cloudflare", "aws", "azure", "railway", "flyio", "render"}

allowed_regions := {"us-east-1", "us-west-2", "eu-west-1", "auto"}

monthly_cost_ceiling_usd := 500

# ---- Deny-by-default ----------------------------------------------------------

default allow := false

allow if {
	count(deny) == 0
}

# ---- Deny rules (each emits an explainable reason) ----------------------------

# Destructive operations are human-gated: never allowed in an agent context.
deny contains reason if {
	input.action == "destroy"
	input.actor == "agent"
	reason := "destroy is human-gated and denied to agents"
}

deny contains reason if {
	not approved_providers[input.plan.provider]
	reason := sprintf("provider %q is not in the approved list", [input.plan.provider])
}

deny contains reason if {
	not allowed_regions[input.plan.region]
	reason := sprintf("region %q is not allowed (data residency)", [input.plan.region])
}

deny contains reason if {
	input.plan.cost_estimate_usd > monthly_cost_ceiling_usd
	reason := sprintf("estimated cost $%v exceeds ceiling $%v", [input.plan.cost_estimate_usd, monthly_cost_ceiling_usd])
}
