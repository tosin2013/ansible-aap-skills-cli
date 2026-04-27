---
title: "ADR-017: AAP Install Skill"
layout: default
parent: Architecture Decisions
nav_order: 17
---

# 17. AAP Install Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / AAP Installation and Validation

## Context

Every existing skill in this repository assumes AAP is already installed and running.
The `aap-live-validation` skill (ADR-012) explicitly begins with an authenticated,
reachable controller. No skill covers the steps that get you to that point: pre-flight
checks, installation, and post-install verification.

Engineers frequently ask AI agents for help with:
- Verifying prerequisites before starting an install
- Deploying the AAP Operator on OpenShift via OperatorHub or GitOps tooling
- Configuring the `aap-setup` inventory file for self-hosted installs
- Confirming all AAP components are healthy after installation

Without a dedicated skill, AI agents either:
- Guess at installation steps from training data (often outdated)
- Provide steps for the wrong AAP version
- Skip pre-flight checks that prevent the majority of failed installations

A key design challenge is **version sensitivity**: AAP installation procedures change
with every minor release (operator channel names, inventory variable names, component
names like the rename of Tower → Controller). Vendoring step-by-step instructions would
create a perpetual maintenance burden.

## Decision

Add an **`aap-install` skill** targeting **AAP 2.6** that:

1. Uses **inline links to official Red Hat documentation** (versioned `/2.6/` URLs)
   rather than vendoring installation steps — agents surface the live docs rather than
   stale copies
2. Adds the **Red Hat CoP `gitops-catalog`** as the preferred deployment method for
   OpenShift installations, providing ready-made Kustomize overlays and ArgoCD `Application`
   examples
3. Covers four areas with dedicated rules and reference files:
   - Pre-flight checklist (ports, sizing, subscriptions, DNS, SSH)
   - OpenShift install via AAP Operator (Option A: gitops-catalog, Option B: raw YAML)
   - Self-hosted install via `aap-setup` inventory and `setup.sh`
   - Post-install validation (Controller ping, Hub API, EDA, pod status)

### Why inline URLs instead of vendored steps

| Approach | Risk |
|:---------|:-----|
| Vendor step-by-step instructions | Steps go stale with each AAP release |
| Vendor only key structural patterns | Partial staleness — misleading |
| Inline links to versioned official docs | Agent fetches latest correct steps at use time |

The skill provides structural guidance (what to do, in what order, what to watch for)
and always delegates the exact commands to the versioned official doc. The `skill-research`
skill (ADR-011) will track when the `/2.6/` URLs change (e.g., when 2.7 releases and
2.6 docs move to an archive path).

### Scope of the skill's rules

| Rule | Description |
|:-----|:------------|
| Rule 1 — Identify version | Confirm AAP 2.6 target; surface version index if different |
| Rule 2 — Pre-flight | Subscription, OS, ports, DNS, SSH, OpenShift RBAC/storage |
| Rule 3 — OpenShift install | gitops-catalog overlays (preferred) or raw Subscription/CR YAML |
| Rule 4 — Self-hosted install | `inventory` file groups/vars, `setup.sh` flags, air-gapped bundle |
| Rule 5 — Post-install validation | Controller `/api/v2/ping/`, Hub Pulp API, EDA, pod status |
| Rule 6 — Version-matched doc URL | Always use `/2.6/` path; flag if user is on a different version |

### Reference files

| File | Contents |
|:-----|:---------|
| `references/preflight-checklist.md` | Port table, OS/subscription requirements, sizing table, OpenShift RBAC checks |
| `references/ocp-install.md` | GitOps-catalog overlays + ArgoCD Application CR, raw Subscription/CR YAML, troubleshooting table |
| `references/self-hosted-install.md` | Annotated inventory templates (single-node, multi-node, air-gapped), `setup.sh` flags, failure patterns |

## Consequences

**Positive:**
- AI agents surface live, version-correct documentation rather than stale in-skill steps
- The gitops-catalog reference gives OpenShift engineers a production-quality starting point
- Pre-flight checklist reduces failed installations caused by skipped prerequisites
- Post-install validation creates a clean handoff to the `aap-live-validation` skill

**Negative:**
- Inline URL pattern depends on Red Hat's documentation structure remaining stable; if
  URL paths change (e.g., doc reorganisation), `skill-research` must update the references
- The skill targets AAP 2.6 specifically; teams on 2.4/2.5 must substitute the version
  segment in URLs manually until a version-parameterised skill pattern is established
- The gitops-catalog reference may not include the latest AAP 2.6 operator channel
  immediately after release; `skill-research` should verify the channel name on update

## Implementation Plan

1. Create `skills/aap-install/` with `config.sh`, `SKILL.md`, and three reference files
2. Create `docs/adrs/017-aap-install-skill.md` (this file)
3. Add `docs/skills/aap-install.md` to the GitHub Pages site
4. Update `docs/skills/index.md`, `docs/adrs/index.md`, `README.md`, `sources-catalog.md`
5. Commit and push

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — SKILL.md format this skill follows
- [ADR-012](012-aap-live-validation-skill.md) — aap-live-validation is the natural next skill after installation
- [ADR-011](011-research-reference-maintenance.md) — skill-research maintains the versioned URL references

## References

- AAP 2.6 documentation index: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/
- AAP 2.6 planning guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/
- AAP 2.6 OpenShift install guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/
- AAP 2.6 self-hosted install guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/
- Red Hat CoP gitops-catalog (AAP): https://github.com/redhat-cop/gitops-catalog/tree/main/ansible-automation-platform
