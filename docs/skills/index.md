---
title: Skills
layout: default
nav_order: 3
has_children: true
---

# Skills

`ansible-aap-skills-cli` ships eight domain skills targeting the Red Hat CoP Ansible AAP ecosystem,
plus one contributor meta-skill for maintaining the repository itself.
Each skill is a `SKILL.md` file placed in your AI assistant's skills directory, providing
domain-specific rules and context for a specific repository or use case.

---

## Skills Overview

| Skill | Target Repositories | ADR |
|:---|:---|:---|
| [aap-config-structure](aap-config-structure) | `aap_configuration_template` | [ADR-001](../adrs/001-skill-format-standard), [ADR-003](../adrs/003-documentation-embedding-via-references) |
| [aap-secrets-management](aap-secrets-management) | `aap_configuration_template` | [ADR-006](../adrs/006-secrets-management) |
| [aap-infra-roles](aap-infra-roles) | `infra.aap_configuration` | [ADR-001](../adrs/001-skill-format-standard) |
| [ee-yaml-schema](ee-yaml-schema) | `ansible-execution-environment`, `ee_utilities` | [ADR-007](../adrs/007-execution-environment-yaml-schema) |
| [ee-build-workflow](ee-build-workflow) | `ansible-execution-environment` | [ADR-008](../adrs/008-ee-build-toolchain) |
| [ansible-navigator](ansible-navigator) | `ansible-execution-environment`, `aap_configuration_template` | [ADR-013](../adrs/013-ansible-navigator-skill) |
| [ansible-good-practices](ansible-good-practices) | All repositories | [ADR-009](../adrs/009-ansible-good-practices) |
| [aap-live-validation](aap-live-validation) | `aap_configuration_template`, `infra.aap_configuration` | [ADR-012](../adrs/012-aap-live-validation-skill) |
| [skill-research](skill-research) *(contributor, opt-in)* | `ansible-aap-skills-cli` | [ADR-011](../adrs/011-research-reference-maintenance) |

---

## How Skills Work

1. Run `./install.sh install` — skills are copied to `~/.claude/skills/` and/or `~/.cursor/skills/`
2. Open a target repository in your IDE
3. Your AI assistant automatically loads the skill context
4. The AI follows the rules in `SKILL.md` for every suggestion it makes

The `ansible-good-practices` skill is a **baseline** — it is always installed alongside any other skill.

The `skill-research` skill is **opt-in** for contributors: `./install.sh install --skill skill-research`.
