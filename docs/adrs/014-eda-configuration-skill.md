---
title: "ADR-014: EDA Configuration Skill"
layout: default
parent: Architecture Decisions
nav_order: 14
---

# 14. EDA Configuration Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / Event-Driven Ansible

## Context

The Red Hat Communities of Practice provide the `redhat-cop/eda_configuration` collection
for managing **Event-Driven Ansible (EDA) Controller** resources as code. EDA resources
include rulebooks, activations, decision environments, projects, credentials, and event sources.

EDA configuration introduces unique ordering constraints (rulebooks and projects must exist
before activations), variable naming conventions (`eda_` prefix), and structural requirements
for rulebooks (sources, conditions, actions) that differ from standard AAP configuration.

Without dedicated guidance, AI agents frequently:
- Create activations referencing projects or rulebooks that don't exist yet
- Embed environment-specific values directly in rulebook YAML instead of passing them as `extra_vars`
- Omit `restart_policy` from activations, relying on an undefined default
- Use bare image names for decision environments instead of full registry paths

The existing skills target AAP Controller configuration; none address EDA Controller.

## Decision

Add an **`eda-configuration` skill** covering:

1. Resource creation order (decision environments → credentials → projects → activations)
2. `eda_` variable prefix convention for collection role inputs
3. Rulebook structure requirements (name, sources, rules/conditions/actions)
4. Activation variable separation (`extra_vars` vs rulebook YAML)
5. Explicit `restart_policy` on every activation
6. Full registry image paths for decision environments

### Reference files

| File | Contents |
|:-----|:---------|
| `references/rulebook-structure.md` | Annotated rulebook patterns: conditions, actions, throttle, common event source plugins |
| `references/activation-vars.md` | Full `eda_activations`, `eda_decision_environments`, `eda_projects`, `eda_credentials` schemas |

## Consequences

**Positive:**
- AI agents follow the correct resource creation order, preventing activation failures
- Rulebooks produced by AI agents have valid structure without manual correction
- `extra_vars` separation makes rulebooks reusable across environments

**Negative:**
- EDA Controller API and `eda_configuration` collection evolve; `skill-research` must track changes
- The skill targets `eda_configuration` collection patterns; engineers using raw EDA API or AWX CLI directly are outside scope

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — SKILL.md format
- [ADR-003](003-documentation-embedding-via-references.md) — references/ convention
- [ADR-011](011-research-reference-maintenance.md) — skill-research maintains reference files

## References

- eda_configuration collection: https://github.com/redhat-cop/eda_configuration
- EDA rulebook documentation: https://ansible.readthedocs.io/projects/rulebook/
- Event-Driven Ansible event source plugins: https://github.com/ansible/event-driven-ansible
