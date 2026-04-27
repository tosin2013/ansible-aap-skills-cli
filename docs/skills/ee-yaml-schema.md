---
title: ee-yaml-schema
layout: default
parent: Skills
nav_order: 4
---

# ee-yaml-schema

**Target**: `tosin2013/ansible-execution-environment`, `redhat-cop/ee_utilities`  
**Version**: 1.0.0  
**ADR**: [ADR-007](../adrs/007-execution-environment-yaml-schema)

## Purpose

Ensures AI agents always generate `execution-environment.yml` manifests using
the version 3 schema and external dependency files — preventing the outdated
inline requirements style from versions 1 and 2.

## Key Rules

| Rule | Description |
|:---|:---|
| Always `version: 3` | First line of every `execution-environment.yml` |
| No inline requirements | Never list collections, Python, or system packages inline |
| `files/requirements.yml` | Ansible collections go here |
| `files/requirements.txt` | Python packages go here |
| `files/bindep.txt` | System packages go here |
| `additional_build_steps` | Custom RUN steps go in this block, not inline |

## Compliant Manifest

```yaml
version: 3
build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--pre'
images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform/ee-minimal-rhel9:latest
dependencies:
  galaxy: files/requirements.yml
  python: files/requirements.txt
  system: files/bindep.txt
```

## Install

```bash
./install.sh install --skill ee-yaml-schema
```

## Reference Files

- `execution-environment.yml.example` — complete valid v3 manifest
- `requirements.yml.example` — sample collection requirements file
- `schema-versions.md` — v1/v2/v3 history and migration guide
