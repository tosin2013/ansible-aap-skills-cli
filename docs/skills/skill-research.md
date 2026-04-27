---
title: skill-research
layout: default
parent: Skills
nav_order: 7
---

# skill-research

**Target**: `ansible-aap-skills-cli` (this repository)  
**Version**: 1.0.0  
**ADR**: [ADR-011](../adrs/011-research-reference-maintenance)  
**Type**: Contributor meta-skill (opt-in)

## Purpose

A **contributor meta-skill** that closes the maintenance gap identified in [ADR-003](../adrs/003-documentation-embedding-via-references).
It gives AI agents a structured workflow for:

1. Populating `references/` directories with accurate, vendored upstream documentation
2. Detecting stale reference files (flagging content older than 90 days)
3. Filing GitHub issues in upstream repositories when problems are discovered — always with explicit user confirmation

This skill targets **contributors to `ansible-aap-skills-cli`**, not end users of AAP.

---

## Key Rules

| Rule | Description |
|:---|:---|
| Source discovery | Always consult `sources-catalog.md` for canonical upstream URLs — never guess |
| Fetch and format | Vendor minimum excerpt only; add `Last updated` comment; link to full source |
| Staleness detection | Flag files > 90 days old; check upstream commits since last-updated date |
| Update workflow | Four steps: check → fetch diff → show diff to user → update on approval |
| Issue classification | Classify as documentation bug, schema/API change, or missing documentation |
| Issue filing | Draft with user, confirm, then `gh issue create` — never auto-file |
| Confirmation gate | Never file a GitHub issue without explicit user approval |

---

## Reference Files

| File | Purpose |
|:---|:---|
| `references/sources-catalog.md` | Maps every skill to its authoritative upstream URL and issue repo |
| `references/staleness-checklist.md` | Step-by-step audit procedure for detecting and fixing stale content |
| `references/issue-template.md` | GitHub issue template, pre-flight checklist, and `gh issue create` command |

---

## Issue Filing Target Repos

| Skill | Upstream Repo |
|:---|:---|
| `aap-config-structure` | `redhat-cop/aap_configuration_template` |
| `aap-secrets-management` | `redhat-cop/aap_configuration_template` |
| `aap-infra-roles` | `redhat-cop/infra.aap_configuration` |
| `ee-yaml-schema` | `tosin2013/ansible-execution-environment` |
| `ee-build-workflow` | `tosin2013/ansible-execution-environment` |
| `ansible-good-practices` | `redhat-cop/automation-good-practices` |
| `skill-research` | `tosin2013/ansible-aap-skills-cli` |

---

## Install

This skill is **opt-in** — it is not part of the auto-install baseline.

```bash
./install.sh install --skill skill-research
```

---

## Typical Workflows

### Audit all references for staleness

Ask your AI assistant:
> "Audit all references/ directories for staleness and report which files need updating."

The AI will run the checklist in `references/staleness-checklist.md` and produce a report
before touching anything.

### Update a specific reference file

Ask your AI assistant:
> "The ee-yaml-schema skill's schema-versions.md looks outdated. Can you fetch the latest from upstream and update it?"

The AI will fetch from the URL in `sources-catalog.md`, show you the diff, and wait for your approval.

### File an upstream issue

Ask your AI assistant:
> "I found that the aap-infra-roles async pattern example is broken — the collect_async_status variable name changed. Can you file an issue?"

The AI will classify the problem, check for existing issues, draft the issue body, show it to you, and only run `gh issue create` after you confirm.
