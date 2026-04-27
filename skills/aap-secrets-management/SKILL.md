# AAP Secrets Management Skill

You are assisting engineers working in the `redhat-cop/aap_configuration_template` repository.

## CRITICAL: Never Generate Plaintext Secrets

**You MUST NOT produce plaintext credential values in any YAML file.**
If asked to add a password, token, or key to a configuration file, always use
`ansible-vault encrypt_string` instead.

## Rules

### Rule 1 — Use ansible-vault encrypt_string for all secrets

Every sensitive value (passwords, tokens, API keys, SSH keys) MUST be encrypted with:

```bash
ansible-vault encrypt_string --stdin-name <variable_name>
```

Example session:
```
$ ansible-vault encrypt_string --stdin-name controller_password
New Vault password:
Confirm New Vault password:
Reading plaintext input from stdin. (ctrl-d to end input)
MySecretPassword123!
controller_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          61333034323764373864386666613263373761303430343537363664343564353161386633393264
          ...
Encryption successful
```

### Rule 2 — Store encrypted strings in config/<env>/secrets.yml

```yaml
# config/dev/secrets.yml
---
controller_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  61333034323764373864386666613263...

controller_token: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  38393465353734383538386239653139...
```

### Rule 3 — Reference secrets via variable interpolation

In other config files, reference the vault variable by name. Never repeat the vault block:

```yaml
# config/all/credentials.yml
controller_credentials:
  - name: "AAP Admin"
    credential_type: "Red Hat Ansible Automation Platform"
    inputs:
      host: "https://{{ aap_hostname }}"
      password: "{{ controller_password }}"   # resolved from secrets.yml at runtime
      username: admin
```

### Rule 4 — secrets.yml MUST be committed

Vault-encrypted files are safe to commit. The values are unreadable without the vault password.
The vault password is stored separately (CI/CD secret, password file, not in this repo).

### Rule 5 — Vault password management

- Development: use a `.vault_password` file (add to `.gitignore`)
- CI/CD: inject vault password via `ANSIBLE_VAULT_PASSWORD_FILE` environment variable
- Never commit the vault password file

## References

See `references/secrets.yml.example` for a complete encrypted secrets file example.
See `references/vault-workflow.md` for the full encrypt/decrypt/rotate workflow.
