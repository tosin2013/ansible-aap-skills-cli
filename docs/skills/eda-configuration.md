---
title: eda-configuration
layout: default
parent: Skills
nav_order: 10
---

# eda-configuration

**Target**: `eda_configuration`  
**Version**: 1.0.0  
**ADRs**: [ADR-014](../adrs/014-eda-configuration-skill)

## Purpose

Guides AI agents through structuring **Event-Driven Ansible (EDA)** resources as code
using the `redhat-cop/eda_configuration` collection. Enforces resource creation order,
variable naming, rulebook structure, and activation settings.

## Key Rules

| Rule | Description |
|:-----|:------------|
| Creation order | Decision environments → credentials → projects → activations |
| `eda_` prefix | All connection and role variables must use `eda_` prefix |
| Rulebook structure | Must have `name:`, `sources:`, and `rules:` with `condition:` + `action:` |
| Extra vars separation | Environment values go in activation `extra_vars`, not in rulebook YAML |
| Restart policy | Always set `restart_policy: always \| never \| on-failure` explicitly |
| DE image | Full registry path required — no bare image names |

## Minimal Activation Example

```yaml
eda_activations:
  - name: "watch-failed-jobs"
    rulebook: "watch_failed_jobs.yml"
    project: "eda-rules"
    decision_environment: "de-supported"
    restart_policy: always
    enabled: true
    extra_vars:
      queue_url: "{{ vault_sqs_queue_url }}"
      aws_region: "us-east-1"
```

## Install

```bash
./install.sh install --skill eda-configuration
```

## Reference Files

- `references/rulebook-structure.md` — annotated patterns for conditions, actions, throttle, event source plugins
- `references/activation-vars.md` — full variable schemas for activations, DEs, projects, credentials
