---
title: "ADR-011: Research and Reference Maintenance"
layout: default
parent: Architecture Decisions
nav_order: 11
---

# 11. Research and Reference Maintenance Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Knowledge Management / Contributor Tooling

## Context

ADR-003 established the `references/` subdirectory convention for supplementary documentation
within each skill. Its only listed negative consequence was:

> *"Contributors must remember to update `references/` when upstream schemas change."*

This is a real maintenance risk. The six skills in this repository vendor content from six
different upstream sources (Red Hat CoP GitHub repositories, ansible-builder docs, etc.).
Without a structured process, vendored reference files silently go stale as upstream evolves.

A second gap emerged during initial skill development: when an upstream problem is discovered
(incorrect documentation, breaking schema change, missing docs for a feature), there is no
defined workflow for reporting it back to the upstream maintainers.

## Decision

Add a **`skill-research` meta-skill** that provides AI agents with:

1. A structured workflow for sourcing, formatting, and vendoring upstream documentation into `references/` directories
2. A staleness detection process based on `## Last updated` comments in vendored files
3. A guided upstream issue-filing workflow using `gh issue create` — always with explicit user confirmation before any issue is submitted

This skill targets **contributors** to `ansible-aap-skills-cli`, not end users of AAP.
It is opt-in (`./install.sh install --skill skill-research`) and is not part of the auto-install baseline.

### Scope of the skill's rules

| Rule | Description |
|:---|:---|
| Source discovery | Always consult `sources-catalog.md` for canonical upstream URLs before fetching |
| Fetch and format | Vendor only the minimum excerpt needed; never embed entire repositories |
| Staleness detection | Flag vendored files older than 90 days; compare upstream changelog |
| Update workflow | Structured four-step process: check → fetch diff → update file → update timestamp |
| Issue classification | Categorise upstream problems as documentation bug, schema/API change, or missing docs |
| Issue filing | Draft issue with user, require explicit confirmation, then run `gh issue create` |
| Confirmation gate | Never file an issue automatically — always show draft to user first |

### Issue filing target repos

Each skill maps to a specific upstream repository for issue filing:

| Skill | Upstream Repo |
|:---|:---|
| `aap-config-structure` | `redhat-cop/aap_configuration_template` |
| `aap-secrets-management` | `redhat-cop/aap_configuration_template` |
| `aap-infra-roles` | `redhat-cop/infra.aap_configuration` |
| `ee-yaml-schema` | `tosin2013/ansible-execution-environment` |
| `ee-build-workflow` | `tosin2013/ansible-execution-environment` |
| `ansible-good-practices` | `redhat-cop/automation-good-practices` |
| `skill-research` (this repo) | `tosin2013/ansible-aap-skills-cli` |

## Consequences

**Positive:**
- Closes the maintenance gap from ADR-003 with a structured, AI-assisted workflow
- Upstream problems found during reference research are captured as actionable issues rather than lost
- Contributors have a single place to look up authoritative upstream sources (`sources-catalog.md`)
- The confirmation gate on issue filing prevents accidental noise in upstream trackers

**Negative:**
- Adds a seventh skill to maintain
- The staleness threshold (90 days) is arbitrary — some references change rarely, others frequently; contributors may need to override per-skill
- `gh issue create` requires the contributor to be authenticated to GitHub CLI with write access to the upstream repo (or fork + PR flow for repos they don't own)

## Implementation Plan

1. Create `skills/skill-research/` with `SKILL.md`, `config.sh`, and three reference files
2. Add `docs/skills/skill-research.md` to the GitHub Pages site
3. Update `docs/skills/index.md` and `docs/adrs/index.md` to include the new entries
4. Commit and push

## Related ADRs

- [ADR-003](003-documentation-embedding-via-references.md) — establishes the `references/` convention this skill maintains
- [ADR-010](010-github-pages-documentation.md) — GitHub Pages site that will surface this ADR

## References

- `gh issue create` documentation: https://cli.github.com/manual/gh_issue_create
- Red Hat CoP contribution guidelines: https://github.com/redhat-cop/.github/blob/main/CONTRIBUTING.md
