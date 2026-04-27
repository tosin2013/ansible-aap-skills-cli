---
title: aap-secrets-management
layout: default
parent: Skills
nav_order: 2
---

# aap-secrets-management

**Target**: `redhat-cop/aap_configuration_template`  
**Version**: 1.0.0  
**ADR**: [ADR-006](../adrs/006-secrets-management)

## Purpose

Prevents AI agents from ever generating plaintext credential values in YAML files.
Enforces the Red Hat CoP standard of using `ansible-vault encrypt_string` for all secrets
and storing encrypted strings in `config/<env>/secrets.yml`.

## Key Rules

| Rule | Description |
|:---|:---|
| Never plaintext | Refuse to produce unencrypted passwords, tokens, or API keys |
| Use `encrypt_string` | Always use `ansible-vault encrypt_string --stdin-name <var>` |
| Store in `secrets.yml` | Encrypted strings go in `config/<env>/secrets.yml` |
| Reference by variable | Use `"{{ vault_my_var }}"` in other config files |
| Commit encrypted files | `secrets.yml` is safe to commit — values are unreadable without vault password |

## Example

```bash
# Encrypt a value
ansible-vault encrypt_string --stdin-name controller_password
```

```yaml
# config/dev/secrets.yml
controller_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  61333034323764373864386666613263...
```

## Install

```bash
./install.sh install --skill aap-secrets-management
```

## Reference Files

- `secrets.yml.example` — complete vault-encrypted secrets file example
- `vault-workflow.md` — encrypt, decrypt, rekey, and CI/CD integration guide
