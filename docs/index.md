---
title: Home
layout: home
nav_order: 1
---

# ansible-aap-skills-cli

A CLI installer that delivers **AI agent skills** for the Red Hat Communities of Practice Ansible AAP ecosystem.

Skills use the [`SKILL.md`](https://github.com/tosin2013/rhel-devops-skills-cli) open standard and work with both **Claude Code** and **Cursor IDE**, giving your AI assistant deep, domain-specific context for repositories like `aap_configuration_template`, `infra.aap_configuration`, and `ansible-execution-environment`.

---

## Quick Start

```bash
git clone https://github.com/tosin2013/ansible-aap-skills-cli.git
cd ansible-aap-skills-cli
./install.sh install
```

The installer auto-detects Claude Code (`~/.claude/`) and Cursor IDE (`~/.cursor/`) and installs all skills to both.

---

## What Are Skills?

A **skill** is a `SKILL.md` file placed in your AI assistant's skills directory. When you open a repository the skill targets, your AI automatically loads the skill context and follows its rules — for example:

- Always use `version: 3` for `execution-environment.yml`
- Never suggest plaintext secrets — use `ansible-vault encrypt_string`
- Use Makefile targets with `CONTAINER_ENGINE=podman`, not direct `ansible-builder` calls

---

## Available Skills

| Skill | Target Repository | What It Does |
|:---|:---|:---|
| [`aap-config-structure`](skills/aap-config-structure) | `aap_configuration_template` | Enforces `config/all/` vs `config/<env>/` structure |
| [`aap-secrets-management`](skills/aap-secrets-management) | `aap_configuration_template` | Requires `ansible-vault encrypt_string`; forbids plaintext |
| [`aap-infra-roles`](skills/aap-infra-roles) | `infra.aap_configuration` | Async task pattern and `aap_` variable naming |
| [`ee-yaml-schema`](skills/ee-yaml-schema) | `ansible-execution-environment` | `version: 3` schema; external `files/` dependencies |
| [`ee-build-workflow`](skills/ee-build-workflow) | `ansible-execution-environment` | Makefile targets with `CONTAINER_ENGINE=podman` |
| [`ansible-good-practices`](skills/ansible-good-practices) | All repositories | Red Hat CoP Zen of Ansible baseline (always installed) |

---

## Requirements

- Bash 4.0+
- Claude Code (`~/.claude/`) and/or Cursor IDE (`~/.cursor/`) installed

---

## Inspiration

This project is inspired by and follows the architecture of [`tosin2013/rhel-devops-skills-cli`](https://github.com/tosin2013/rhel-devops-skills-cli).

---

## References

- [Red Hat CoP AAP Config as Code](https://redhat-cop.github.io/aap_config_as_code_docs/)
- [Red Hat CoP Automation Good Practices](https://redhat-cop.github.io/automation-good-practices/)
- [ansible-execution-environment](https://github.com/tosin2013/ansible-execution-environment)
