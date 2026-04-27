---
title: aap-infra-roles
layout: default
parent: Skills
nav_order: 3
---

# aap-infra-roles

**Target**: `redhat-cop/infra.aap_configuration`  
**Version**: 1.0.0  
**ADR**: [ADR-001](../adrs/001-skill-format-standard)

## Purpose

Teaches AI agents the async task pattern used in `infra.aap_configuration` and enforces
the correct variable naming conventions (`aap_` prefix) to avoid namespace collisions.

## Key Rules

| Rule | Description |
|:---|:---|
| `aap_` prefix | All connection variables: `aap_hostname`, `aap_token`, `aap_validate_certs` |
| Async tasks | Use `async: 3600` + `poll: 0` for all resource-configuring roles |
| `collect_async_status` | Always follow async tasks with the `collect_async_status` role |
| Dependency order | Organizations → Credential types → Credentials → Projects → Inventories → Templates |
| Pass vars explicitly | Always pass `aap_hostname`, `aap_token`, `aap_validate_certs` to every role call |

## Async Pattern

```yaml
- name: Configure organizations
  ansible.builtin.include_role:
    name: infra.aap_configuration.organizations
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
  async: 3600
  poll: 0
  register: organizations_async

- name: Wait for organizations
  ansible.builtin.include_role:
    name: infra.aap_configuration.collect_async_status
  vars:
    async_results: "{{ organizations_async }}"
```

## Install

```bash
./install.sh install --skill aap-infra-roles
```

## Reference Files

- `async-pattern.yml` — complete multi-resource async configuration playbook
