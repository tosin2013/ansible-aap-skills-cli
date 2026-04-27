---
title: "ADR-015: AAP Utilities Skill"
layout: default
parent: Architecture Decisions
nav_order: 15
---

# 15. AAP Utilities Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / AAP Operational Tasks

## Context

The `redhat-cop/aap_utilities` collection provides helper roles for **operational and
administrative tasks** against AAP Controller — health checks, configuration export,
bulk tagging, token management, and multi-controller dispatch.

These tasks sit between pure resource configuration (`infra.aap_configuration`) and
live server validation (`aap-live-validation`). Without a dedicated skill, AI agents
frequently:
- Suggest `infra.aap_configuration` roles for tasks that `aap_utilities` handles more
  cleanly (e.g., pinging the controller, exporting config)
- Mix `controller_host`/`tower_token` variable naming with `aap_utilities` roles that
  expect the `aap_` prefix
- Perform bulk operations without first verifying connectivity
- Embed token values inline instead of using vault-encrypted variables

## Decision

Add an **`aap-utilities` skill** covering:

1. Clear guidance on which tasks belong to `aap_utilities` vs `infra.aap_configuration`
2. The `aap_` variable naming convention shared with `infra.aap_configuration`
3. Health check gate before bulk operations
4. Export-before-destruct safety pattern
5. Vault-encrypted tokens (cross-reference with `aap-secrets-management`)

### Reference files

| File | Contents |
|:-----|:---------|
| `references/utility-roles.md` | Catalog of available roles with connection vars, required inputs, and example invocations |

## Consequences

**Positive:**
- Clear task routing (utilities vs configuration) prevents wrong-collection invocations
- Health check pattern reduces failed bulk operations
- Consistent `aap_` prefix across both `infra.aap_configuration` and `aap_utilities` calls

**Negative:**
- `aap_utilities` collection evolves; new roles may not be covered until `skill-research` updates the reference
- `dispatch_config` is a multi-controller pattern not all environments need; the skill documents it but should not suggest it unless the user has multiple controllers

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — SKILL.md format
- [ADR-006](006-secrets-management.md) — vault-encrypted token pattern referenced by Rule 5
- [ADR-012](012-aap-live-validation-skill.md) — aap-live-validation uses controller_ping as its connectivity check

## References

- aap_utilities collection: https://github.com/redhat-cop/aap_utilities
- infra.aap_configuration: https://github.com/redhat-cop/infra.aap_configuration
