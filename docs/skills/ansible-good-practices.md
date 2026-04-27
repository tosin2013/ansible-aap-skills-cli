---
title: ansible-good-practices
layout: default
parent: Skills
nav_order: 6
---

# ansible-good-practices

**Target**: All repositories  
**Version**: 1.0.0  
**ADR**: [ADR-009](../adrs/009-ansible-good-practices)

## Purpose

A **baseline skill** that is always installed alongside any other skill. Encodes the
Red Hat Communities of Practice "Zen of Ansible" and role design principles, ensuring
all AI-generated Ansible code meets community standards regardless of which domain
skill is active.

## The Zen of Ansible

1. Simplicity is a feature
2. Idempotency is non-negotiable
3. Modules before shell
4. Declarative over imperative
5. Roles express what, not how

## Key Rules

| Rule | Description |
|:---|:---|
| Idempotency | Every task safe to run multiple times; `changed=0` on second run |
| Module priority | `ansible.builtin` → `community.general` → `command` → `shell` (last resort) |
| Variable naming | Prefix all role vars with role name: `aap_config_hostname`, not `hostname` |
| Tags on every task | At minimum the role name and resource type |
| FQCN | Always `ansible.builtin.copy`, never just `copy` |
| No template logic | Jinja2 templates render data; conditionals belong in tasks/vars |
| Molecule testing | New roles require a Molecule scenario |

## Always Installed

This skill is automatically installed whenever you run `./install.sh install`,
even if you specify `--skill <other-skill>`. You cannot skip it.

```bash
# Both of these install ansible-good-practices alongside the target skill
./install.sh install --skill aap-config-structure
./install.sh install
```

## Install

```bash
./install.sh install --skill ansible-good-practices
```

## Reference Files

- `zen-of-ansible.md` — full Red Hat CoP automation good practices summary including variable
  management, error handling, testing, and playbook design principles
