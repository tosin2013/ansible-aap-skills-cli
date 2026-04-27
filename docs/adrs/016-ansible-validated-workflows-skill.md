---
title: "ADR-016: Ansible Validated Workflows Skill"
layout: default
parent: Architecture Decisions
nav_order: 16
---

# 16. Ansible Validated Workflows Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / Infrastructure Automation Workflows

## Context

The `redhat-cop/infra.ansible_validated_workflows` collection provides pre-built,
certified automation workflows for common infrastructure patterns: OS patching,
VM provisioning, compliance remediation, and certificate rotation.

These workflows are designed to be invoked as units with defined input/output contracts.
Without a dedicated skill, AI agents frequently:
- Write custom playbooks from scratch for tasks that validated workflows already solve
- Invoke validated workflow roles without providing required input variables, causing runtime failures
- Modify role internals instead of using the provided variable interface
- Omit output registration and assertion, leaving silent failures undetected
- Use incorrect variable naming (`target_hosts` instead of `avw_target_hosts`)

The `ansible-good-practices` baseline skill covers general Ansible conventions but
does not address the specific invocation contract for validated workflows.

## Decision

Add an **`ansible-validated-workflows` skill** covering:

1. Preference for validated workflows over custom playbooks for covered tasks
2. Required variable population before role invocation
3. The `avw_` variable prefix convention
4. Prohibition on modifying role internals (use variables or file upstream issues)
5. Output registration and assertion pattern
6. Integration with `ansible-good-practices` for the wrapping playbook

### Reference files

| File | Contents |
|:-----|:---------|
| `references/workflow-catalog.md` | Catalog of available workflows with required/optional variables and example invocations (`patch_rhel`, `provision_vm`, `remediate_compliance`, `rotate_certificates`) |

## Consequences

**Positive:**
- AI agents reuse certified, tested workflows rather than reinventing common patterns
- Required variable documentation prevents silent failures
- Output assertion pattern ensures workflow success is verified before proceeding

**Negative:**
- `infra.ansible_validated_workflows` collection adds new workflows over time; `skill-research` must track additions
- The `avw_` prefix convention must be verified against the actual collection before each reference update — the collection may not yet use a single uniform prefix across all workflows

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — SKILL.md format
- [ADR-009](009-ansible-good-practices.md) — wrapping playbook must follow good practices rules
- [ADR-011](011-research-reference-maintenance.md) — skill-research maintains the workflow catalog

## References

- infra.ansible_validated_workflows: https://github.com/redhat-cop/infra.ansible_validated_workflows
- Red Hat CoP automation good practices: https://redhat-cop.github.io/automation-good-practices/
