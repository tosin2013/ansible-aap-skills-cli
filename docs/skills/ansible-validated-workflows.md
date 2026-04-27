---
title: ansible-validated-workflows
layout: default
parent: Skills
nav_order: 12
---

# ansible-validated-workflows

**Target**: `infra.ansible_validated_workflows`  
**Version**: 1.0.0  
**ADRs**: [ADR-016](../adrs/016-ansible-validated-workflows-skill), [ADR-009](../adrs/009-ansible-good-practices)

## Purpose

Guides AI agents to use the `redhat-cop/infra.ansible_validated_workflows` collection
for common infrastructure automation tasks (patching, provisioning, compliance, certificates)
rather than writing custom playbooks from scratch.

## Key Rules

| Rule | Description |
|:-----|:------------|
| Validated first | Check `references/workflow-catalog.md` before writing any custom playbook |
| Required vars | Populate all required inputs before invoking — no silent defaults |
| `avw_` prefix | All input variables use `avw_` prefix |
| No internal edits | Use variable interface only; file upstream issues for missing features |
| Register + assert | Always register role output and assert success |
| Good practices | Wrapping playbook must follow `ansible-good-practices` rules (FQCNs, tags, `no_log`) |

## Available Workflows

| Workflow role | Task |
|:-------------|:-----|
| `patch_rhel` | OS patching with optional reboot |
| `provision_vm` | VM provisioning on AWS, Azure, GCP, VMware, OpenStack |
| `remediate_compliance` | OpenSCAP compliance remediation |
| `rotate_certificates` | TLS certificate rotation (Let's Encrypt, internal CA, Vault) |

## Invocation Pattern

```yaml
- name: Run validated workflow
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.<workflow>
  vars:
    avw_<workflow>_<required_var>: "{{ value }}"
  register: workflow_result

- name: Assert success
  ansible.builtin.assert:
    that: workflow_result.failed == false
```

## Install

```bash
./install.sh install --skill ansible-validated-workflows
```

## Reference Files

- `references/workflow-catalog.md` — full catalog with required/optional variables and invocation examples for all workflows
