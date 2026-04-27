---
title: "ADR-012: AAP Live Validation Skill"
layout: default
parent: Architecture Decisions
nav_order: 12
---

# 12. AAP Live Validation Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / Live Infrastructure Validation

## Context

Engineers coding against the `redhat-cop/aap_configuration_template` or
`redhat-cop/infra.aap_configuration` repositories need to validate their configuration
against a **live Ansible Automation Platform (AAP) server** during development and CI.

Two distinct deployment topologies exist in the field:

1. **OpenShift-hosted AAP** — installed via the AAP Operator on Red Hat OpenShift. The
   controller endpoint is an OpenShift Route; the admin password is stored in a Kubernetes
   Secret; authentication is often routed through `oc login` and kubeconfig.

2. **Standalone AAP** — installed via the AAP `aap-setup` installer on a VM, bare metal
   server, or container. The controller is accessed directly via its FQDN; authentication
   uses an OAuth Personal Access Token or username/password.

Without structured guidance, AI agents frequently:
- Attempt configuration pushes without first verifying authentication or connectivity
- Skip `--check` mode dry-runs, causing unintended resource creation on live servers
- Hardcode credentials or fail to use `ansible-vault` for token storage
- Apply configuration without post-apply verification, leaving failures undetected

An existing skill (`aap-config-structure`) covers the directory layout convention, but
no skill addresses the live-server interaction workflow.

## Decision

Add a **`aap-live-validation` skill** that provides AI agents with an ordered, platform-aware
validation sequence covering:

1. **Authentication** — separate rule sets for OpenShift (route + admin Secret) and standalone
   (OAuth token + credentials file / environment variables)
2. **Connectivity check** — assert the server is reachable and the token is valid via
   `GET /api/v2/ping/` before any configuration push
3. **Config syntax validation** — `yamllint` and `--syntax-check` before running against a live server
4. **Dry-run** — `ansible-navigator run --check` or `ansible-playbook --check` to preview
   changes without modifying the live server
5. **Resource apply** — use `redhat-cop/aap_configuration_template` Makefile targets or
   `ansible-navigator` with appropriate env files
6. **Post-apply verification** — query the AAP REST API to confirm resources were created
   or updated

### Scope of the skill's rules

| Rule | Description |
|:-----|:------------|
| Rule 1 — Auth first | Never attempt connectivity or apply without confirmed authentication |
| Rule 2 — OpenShift auth | `oc get route`, admin Secret retrieval, OAuth token creation via API |
| Rule 3 — Standalone auth | OAuth PAT creation, vault-encrypted storage, CI environment variable pattern |
| Rule 4 — Connectivity check | `GET /api/v2/ping/` must return 200 + `version` key before proceeding |
| Rule 5 — Syntax check | `yamllint` + `--syntax-check` gate before any live server interaction |
| Rule 6 — Dry-run gate | `--check` mode required; review `changed`/`failed` before applying |
| Rule 7 — Post-apply verify | Query representative resources via REST API to confirm apply succeeded |

### Reference files

| File | Contents |
|:-----|:---------|
| `references/openshift-auth.md` | `oc login`, route retrieval, admin Secret extraction, OAuth token creation |
| `references/standalone-auth.md` | OAuth PAT creation, vault encryption, CI env var pattern |
| `references/validation-steps.md` | Complete ordered checklist with commands and pass/fail criteria |

## Consequences

**Positive:**
- AI agents follow a consistent, safe sequence when interacting with live AAP servers
- Platform split (OpenShift vs standalone) prevents agents from suggesting wrong auth patterns
- Dry-run gate reduces accidental resource creation or deletion on shared/production servers
- Post-apply verification closes the loop — agents can confirm success without manual inspection

**Negative:**
- Skill must be updated when AAP API versions change (managed via the `skill-research` meta-skill)
- The `controller_validate_certs: false` escape hatch for self-signed lab certs could be misused
  in production if agents do not enforce the caveat; the SKILL.md explicitly restricts this to dev/lab
- OAuth token rotation is not covered — users with short-lived tokens must re-authenticate;
  a future enhancement could add a token refresh reference

## Implementation Plan

1. Create `skills/aap-live-validation/` with `SKILL.md`, `config.sh`, and three reference files
2. Create `docs/adrs/012-aap-live-validation-skill.md` (this file)
3. Add `docs/skills/aap-live-validation.md` to the GitHub Pages site
4. Update `docs/skills/index.md`, `docs/adrs/index.md`, and `README.md`
5. Update `skills/skill-research/references/sources-catalog.md` with AAP API and ansible-navigator URLs
6. Commit and push

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — defines the SKILL.md format this skill follows
- [ADR-003](003-documentation-embedding-via-references.md) — references/ convention used here
- [ADR-006](006-secrets-management.md) — ansible-vault pattern this skill reinforces
- [ADR-011](011-research-reference-maintenance.md) — skill-research will maintain the reference files

## References

- AAP REST API guide: https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html
- ansible-navigator documentation: https://ansible.readthedocs.io/projects/navigator/
- AAP Operator on OpenShift: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform
- awx.awx collection: https://github.com/ansible/awx/tree/devel/awx_collection
