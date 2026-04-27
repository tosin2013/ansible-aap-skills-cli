# Ansible Vault Workflow for AAP Configuration

## Encrypting a New Secret

```bash
# Interactive — prompts for value on stdin
ansible-vault encrypt_string --stdin-name controller_password

# Non-interactive (CI-friendly)
echo -n "MySecret" | ansible-vault encrypt_string --stdin-name controller_password
```

Copy the output block (starting with `!vault |`) into `config/<env>/secrets.yml`.

## Using a Vault Password File

```bash
# Create a local vault password file (NEVER commit this)
echo "my-vault-password" > .vault_password
chmod 600 .vault_password

# Add to .gitignore
echo ".vault_password" >> .gitignore

# Encrypt using the file
ansible-vault encrypt_string --vault-password-file .vault_password \
  --stdin-name controller_password
```

## Running Playbooks with Vault

```bash
# Password file
ansible-playbook playbooks/configure_aap.yml \
  --vault-password-file .vault_password

# Environment variable (CI/CD)
export ANSIBLE_VAULT_PASSWORD_FILE=/path/to/.vault_password
ansible-playbook playbooks/configure_aap.yml
```

## Decrypting a Value (for verification)

```bash
# Decrypt the entire secrets file to stdout
ansible-vault decrypt config/dev/secrets.yml --output=-

# Decrypt a single inline vault string
echo '$ANSIBLE_VAULT;1.1;AES256
61333034323764...' | ansible-vault decrypt
```

## Rotating the Vault Password

```bash
# Re-key all vault-encrypted files to a new password
ansible-vault rekey config/dev/secrets.yml config/qa/secrets.yml config/prod/secrets.yml
```

## CI/CD Integration

GitHub Actions example:
```yaml
- name: Run AAP configuration
  env:
    ANSIBLE_VAULT_PASSWORD_FILE: ${{ secrets.VAULT_PASSWORD_FILE }}
  run: ansible-playbook playbooks/configure_aap.yml
```

Store the vault password as a GitHub Actions secret named `VAULT_PASSWORD_FILE`.
