---
title: "ADR-003: Documentation Embedding via References"
layout: default
parent: Architecture Decisions
nav_order: 3
---

# 3. Documentation Embedding via References Subdirectory

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: AI Agent Integration / Knowledge Management

## Context

AI agents benefit from supplementary documentation (example YAML structures, upstream README excerpts, schema references) to provide accurate, context-aware suggestions. However, embedding all of this documentation directly inside a `SKILL.md` file would make skills unwieldy, hard to update, and difficult to review.

A mechanism is needed to keep the primary `SKILL.md` concise while still making supplementary material accessible to the AI at runtime.

## Decision

Each skill directory will include an optional **`references/`** subdirectory for supplementary documentation. The `SKILL.md` may reference files in `references/` by relative path so the AI can read them on demand.

```
skills/<skill-name>/
├── SKILL.md          # Primary instructions (concise)
├── config.sh         # Skill metadata for the installer
└── references/       # Supplementary docs (optional)
    ├── example.yml
    └── schema.md
```

The installer copies the entire skill directory (including `references/`) to the target IDE path.

## Consequences

**Positive:**
- `SKILL.md` remains readable and concise
- Reference material can be updated independently of the core instructions
- Upstream documentation can be vendored per-skill without polluting the repository root
- AI agents that support file-reading can access deep context without token bloat in the main skill file

**Negative:**
- Contributors must remember to update `references/` when upstream schemas change
- Skills with large reference trees may increase installer copy time marginally

## Implementation Plan

1. Define the `references/` convention in `CONTRIBUTING.md`
2. Update `install.sh install` to copy entire skill directory recursively (`cp -r`)
3. In each `SKILL.md`, add a `## References` section citing relative paths to key files in `references/`
4. For the initial skill set, vendor the most critical upstream docs (e.g., `aap_configuration_template` directory layout, EE schema `v3` spec)

## Related PRD Sections

- Section 2.2: Skill Format (ADR-003)
- Section 5: File Structure

## References

- `tosin2013/rhel-devops-skills-cli` — established the `references/` convention
- Red Hat CoP AAP configuration documentation
