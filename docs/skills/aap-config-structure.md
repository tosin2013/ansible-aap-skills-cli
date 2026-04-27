---
title: aap-config-structure
layout: default
parent: Skills
nav_order: 1
---

# aap-config-structure

**Target**: `redhat-cop/aap_configuration_template`  
**Version**: 1.0.0  
**ADRs**: [ADR-001](../adrs/001-skill-format-standard), [ADR-003](../adrs/003-documentation-embedding-via-references)

## Purpose

Enforces the two-tier directory convention used by `aap_configuration_template` for
Ansible Automation Platform configuration-as-code. Prevents AI agents from placing
environment-specific settings in global files or vice versa.

## Key Rules

| Rule | Description |
|:---|:---|
| Global settings → `config/all/` | Organizations, teams, credential types, projects — same in every env |
| Environment overrides → `config/<env>/` | Inventories, secrets — differ per dev/qa/prod |
| One file per resource type | `credentials.yml`, `organizations.yml`, not mixed files |
| Variable loading order | `config/all/` loaded first, `config/<env>/` overlays on top |

## Directory Structure

```
config/
├── all/                    # Global settings
│   ├── organizations.yml
│   ├── credentials.yml
│   └── job_templates.yml
├── dev/
│   ├── inventories.yml
│   └── secrets.yml
├── qa/
│   └── ...
└── prod/
    └── ...
```

## Install

```bash
./install.sh install --skill aap-config-structure
```

## Reference Files

The skill includes supplementary reference files in `references/`:
- `directory-layout.md` — fully annotated repository tree
- `example-vars.yml` — sample global vs env-scoped variable files
