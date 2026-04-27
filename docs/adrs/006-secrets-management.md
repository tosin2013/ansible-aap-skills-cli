# 6. Secrets Management

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Security

## Context

The `aap_configuration_template` repository stores Ansible Automation Platform configuration as code, which frequently includes sensitive values (credentials, tokens, passwords). AI agents assisting engineers in this repository must never suggest storing plaintext secrets in version-controlled YAML files.

Two patterns exist in the ecosystem:
1. **External vault references** (e.g., HashiCorp Vault, CyberArk) — requires additional infrastructure
2. **Inline ansible-vault encryption** (`ansible-vault encrypt_string`) — self-contained, no extra infrastructure, standard Red Hat CoP practice

## Decision

The `aap-secrets-management` skill will instruct AI agents to **exclusively use `ansible-vault encrypt_string`** for secrets and place the encrypted output in `config/<env>/secrets.yml`.

Specific rules encoded in the skill:
1. **Never** suggest or generate plaintext secret values in any YAML file
2. Use `ansible-vault encrypt_string --stdin-name <var_name>` to produce vault-encrypted strings
3. Store encrypted strings in `config/<env>/secrets.yml` (environment-scoped)
4. Reference secrets via Ansible variable interpolation (`"{{ vault_<var_name> }}"`)
5. `secrets.yml` files **must** be committed to the repository — they are safe because values are encrypted

## Consequences

**Positive:**
- No plaintext credentials ever appear in version history
- Self-contained: no external secrets manager infrastructure required
- Consistent with Red Hat CoP and community Ansible practices
- AI agents given explicit rules are less likely to hallucinate unsafe patterns

**Negative:**
- `ansible-vault` passwords must be managed separately (e.g., via a password file or CI/CD secret)
- Rotating the vault password requires re-encrypting all `secrets.yml` files

## Implementation Plan

1. Write `skills/aap-secrets-management/SKILL.md` with explicit rules (listed above)
2. Include an example `references/secrets.yml.example` showing the vault-encrypted format
3. Add a rule in `SKILL.md` instructing the AI to refuse to produce plaintext when asked for a credential value
4. Document the `ansible-vault` workflow in `references/vault-workflow.md`

## Related PRD Sections

- Section 4: Detailed Skill Requirements (`aap-secrets-management` row)

## References

- Ansible Vault documentation: https://docs.ansible.com/ansible/latest/vault_guide/
- Red Hat CoP `aap_configuration_template`: https://github.com/redhat-cop/aap_configuration_template
