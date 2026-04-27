---
title: "ADR-005: Repository Structure"
layout: default
parent: Architecture Decisions
nav_order: 5
---

# 5. Repository Structure

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Project Organization

## Context

A consistent, predictable repository layout reduces cognitive overhead for contributors and ensures the installer can locate skills reliably. The reference project `rhel-devops-skills-cli` established a layout that has proven navigable and extensible.

## Decision

The repository will **mirror the `rhel-devops-skills-cli` layout** with Ansible-specific adaptations:

```
ansible-aap-skills-cli/
├── install.sh                     # Main CLI installer
├── README.md
├── CONTRIBUTING.md
├── docs/
│   └── adrs/                      # Architecture Decision Records
├── tests/                         # Bash (bats) tests for the installer
└── skills/
    ├── aap-config-structure/
    │   ├── SKILL.md
    │   ├── config.sh              # Skill metadata (name, version, description)
    │   └── references/            # Supplementary docs / example YAML
    ├── aap-secrets-management/
    │   ├── SKILL.md
    │   └── config.sh
    ├── aap-infra-roles/
    │   ├── SKILL.md
    │   └── config.sh
    ├── ee-yaml-schema/
    │   ├── SKILL.md
    │   └── config.sh
    ├── ee-build-workflow/
    │   ├── SKILL.md
    │   └── config.sh
    └── ansible-good-practices/
        ├── SKILL.md
        └── config.sh
```

Each skill's `config.sh` exports metadata variables consumed by `install.sh`:

```bash
SKILL_NAME="aap-config-structure"
SKILL_VERSION="1.0.0"
SKILL_DESCRIPTION="Enforces AAP config-as-code directory structure"
SKILL_TARGETS="aap_configuration_template"
```

## Consequences

**Positive:**
- Familiar to contributors from `rhel-devops-skills-cli`
- `install.sh` can glob `skills/*/config.sh` to discover all skills dynamically
- Clear separation of installer logic, skill content, docs, and tests

**Negative:**
- Flat `skills/` directory does not group by target repository — acceptable at current scale of 6 skills
- `config.sh` metadata is informal; a YAML manifest could be more structured but adds tooling dependency

## Implementation Plan

1. Create the directory skeleton in Phase 1 scaffolding
2. Add a `config.sh` template that new skills must copy and fill in
3. Document the layout in `CONTRIBUTING.md`
4. Update `install.sh list` to parse `config.sh` for display

## Related PRD Sections

- Section 5: File Structure
- Section 6 Phase 1: CLI Scaffolding

## References

- `tosin2013/rhel-devops-skills-cli` — reference directory layout
