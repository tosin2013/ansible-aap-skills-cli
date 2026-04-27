---
title: aap-utilities
layout: default
parent: Skills
nav_order: 11
---

# aap-utilities

**Target**: `aap_utilities`, `aap_configuration_template`  
**Version**: 1.0.0  
**ADRs**: [ADR-015](../adrs/015-aap-utilities-skill), [ADR-006](../adrs/006-secrets-management)

## Purpose

Guides AI agents when using the `redhat-cop/aap_utilities` collection for **operational
and administrative AAP tasks**: health checks, configuration export, bulk tagging, token
management, and multi-controller dispatch.

Complements `aap-infra-roles` (resource configuration) and `aap-live-validation`
(connectivity checks).

## Key Rules

| Rule | Description |
|:-----|:------------|
| Task routing | Use `aap_utilities` for operational tasks; `infra.aap_configuration` for resource creation |
| `aap_` prefix | Same variable naming as `aap-infra-roles` skill |
| Health check gate | Run `controller_ping` before any bulk operation |
| Export before destruct | Use `export_config` before bulk-delete or major reconfiguration |
| Vault tokens | Token values must always be vault-encrypted |

## Quick Reference

```yaml
# Ping the controller
- ansible.builtin.include_role:
    name: aap_utilities.controller_ping
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_validate_certs: true

# Export config backup
- ansible.builtin.include_role:
    name: aap_utilities.export_config
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_export_path: "/tmp/aap-backup-{{ ansible_date_time.date }}.json"
```

## Install

```bash
./install.sh install --skill aap-utilities
```

## Reference Files

- `references/utility-roles.md` — full catalog of roles with connection vars, required inputs, and examples
