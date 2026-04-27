# Standalone AAP Authentication

<!-- Last updated: 2026-04-27 -->

This reference covers authenticating to an AAP Controller deployed on a **standalone host**
(physical server, VM, or container — not managed by the OpenShift AAP Operator).

---

## Prerequisites

- AAP Controller installed via the AAP installer or `aap-setup.tar.gz`
- Network access to the controller FQDN or IP on port 443
- Admin credentials or an existing OAuth token

---

## Step 1 — Confirm the controller URL is reachable

```bash
CONTROLLER_FQDN="aap.example.com"

# Basic reachability check
curl -sk "https://${CONTROLLER_FQDN}/api/v2/ping/" | python3 -m json.tool
```

If the ping endpoint returns a connection error, resolve DNS/firewall issues before proceeding.

---

## Step 2 — Create an OAuth Personal Access Token

1. Log in to the AAP web UI: `https://<controller-fqdn>`
2. Navigate to: **User menu (top-right) → User Details → Tokens tab → Add**
3. Set:
   - **Description**: meaningful name (e.g. `deploy-ci`, `local-dev`)
   - **Application**: leave blank (personal token, not tied to an OAuth application)
   - **Scope**: `Write`
4. Copy the token value immediately — it is shown only once.

Alternatively, create a token via the API:

```bash
ADMIN_USER="admin"
ADMIN_PASSWORD="<your-admin-password>"

OAUTH_TOKEN=$(curl -sk -X POST \
  -u "${ADMIN_USER}:${ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '{"description":"local-dev","application":null,"scope":"write"}' \
  "https://${CONTROLLER_FQDN}/api/v2/tokens/" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")
```

---

## Step 3 — Store the token securely with ansible-vault

Never store tokens in plaintext. Encrypt with ansible-vault:

```bash
ansible-vault encrypt_string "${OAUTH_TOKEN}" --name 'vault_controller_oauth_token'
```

Place the encrypted string in `config/<env>/secrets.yml`:

```yaml
# config/dev/secrets.yml
vault_controller_oauth_token: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  ...
```

Reference it in connection vars:
```yaml
# group_vars/all/aap_connection.yml
controller_hostname: "https://aap.example.com"
controller_oauth_token: "{{ vault_controller_oauth_token }}"
controller_validate_certs: true
```

---

## Step 4 — Environment variable method (for CI/CD pipelines)

For GitHub Actions, Jenkins, or other CI systems, inject credentials as masked environment variables:

```bash
export CONTROLLER_HOST="https://aap.example.com"
export CONTROLLER_OAUTH_TOKEN="<token-from-ci-secret>"
export CONTROLLER_VERIFY_SSL="true"
```

`ansible-navigator` and `ansible-playbook` with the `awx.awx` collection both honour these
environment variables automatically.

For GitHub Actions, store the token as a repository secret (`AAP_OAUTH_TOKEN`) and reference it:

```yaml
# .github/workflows/validate-aap.yml
env:
  CONTROLLER_HOST: ${{ secrets.AAP_CONTROLLER_HOST }}
  CONTROLLER_OAUTH_TOKEN: ${{ secrets.AAP_OAUTH_TOKEN }}
  CONTROLLER_VERIFY_SSL: "true"
```

---

## Step 5 — Vault password management

If using `ansible-vault` encrypted vars, the vault password must be available at runtime:

```bash
# File-based (local development)
echo "<vault-password>" > ~/.vault_pass
chmod 600 ~/.vault_pass
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

# Environment variable
export ANSIBLE_VAULT_PASSWORD="<vault-password>"
```

For CI, store the vault password as a secret and write it to a temp file:

```yaml
- name: Write vault password
  run: echo "${{ secrets.ANSIBLE_VAULT_PASSWORD }}" > /tmp/.vault_pass
- name: Run playbook
  run: ansible-playbook configure_aap.yml --vault-password-file /tmp/.vault_pass
```

---

## Step 6 — Verify connectivity

```bash
curl -sk \
  -H "Authorization: Bearer ${OAUTH_TOKEN}" \
  "https://${CONTROLLER_FQDN}/api/v2/ping/" | python3 -m json.tool
```

Expected successful response:
```json
{
  "ha": false,
  "version": "4.x.y",
  "active_node": "aap.example.com",
  "install_uuid": "..."
}
```

A `401 Unauthorized` response means the token is invalid or expired. Create a new token and retry.

---

## Upstream references

- AAP installation guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform
- AAP REST API guide: https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html
- awx.awx collection: https://github.com/ansible/awx/tree/devel/awx_collection
- ansible-vault documentation: https://docs.ansible.com/ansible/latest/vault_guide/
