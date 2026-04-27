# AAP Live Validation Skill

You are assisting engineers who are coding against a **live Ansible Automation Platform (AAP) server**.
The server may be hosted on **OpenShift** (via the AAP Operator) or on a **standalone** host (VM, bare metal, or container).

Before suggesting any configuration push or playbook run, always follow the validation sequence in this skill.

## Rules

### Rule 1 — Authenticate before anything else

Never attempt a connectivity check, dry-run, or resource apply without confirmed authentication.
Ask the user which deployment type they are working with — OpenShift or standalone — and follow the
corresponding rule (Rule 2 or Rule 3) to obtain a valid token.

### Rule 2 — OpenShift-hosted AAP: use oc/kubeconfig auth

When AAP is deployed via the AAP Operator on OpenShift:

1. Confirm the user is logged in to the cluster:
   ```bash
   oc whoami
   ```
2. Retrieve the AAP route:
   ```bash
   oc get route -n <aap-namespace> automationcontroller -o jsonpath='{.spec.host}'
   ```
3. Obtain a bearer token for the AAP API. Two options:
   - **Option A — admin password** (most common): retrieve from the controller admin secret:
     ```bash
     oc get secret -n <aap-namespace> <controller-name>-admin-password -o jsonpath='{.data.password}' | base64 -d
     ```
   - **Option B — OAuth token**: create a Personal Access Token in the AAP UI under
     *User Settings → Tokens*, or use the AWX collection `awx.awx.token` module.
4. Set connection variables:
   ```yaml
   controller_hostname: "https://<route-host>"
   controller_username: admin          # or omit if using OAuth token
   controller_password: "<password>"  # or controller_oauth_token: "<token>"
   controller_validate_certs: true     # set false only in dev/lab with self-signed certs
   ```
5. Store credentials using `ansible-vault encrypt_string` — never plaintext in vars files.

See `references/openshift-auth.md` for a full annotated walkthrough.

### Rule 3 — Standalone AAP: use token/credentials file auth

When AAP is deployed on a VM, bare metal host, or as a standalone container:

1. Confirm the controller URL is reachable from the user's machine.
2. Obtain an OAuth token from the AAP UI: *User Settings → Tokens → Add*.
3. Export connection variables or write a credentials file:
   ```bash
   export CONTROLLER_HOST=https://<controller-fqdn>
   export CONTROLLER_OAUTH_TOKEN=<token>
   export CONTROLLER_VERIFY_SSL=true
   ```
   Or as Ansible vars:
   ```yaml
   controller_hostname: "https://<controller-fqdn>"
   controller_oauth_token: "<vault-encrypted-token>"
   controller_validate_certs: true
   ```
4. For vault-encrypted tokens, ensure the vault password is available:
   ```bash
   export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
   ```

See `references/standalone-auth.md` for full token creation and credential file examples.

### Rule 4 — Verify connectivity before proceeding

After authentication is confirmed, verify the server is reachable and the credentials work:

```bash
# Quick ping via curl (works for both OpenShift and standalone)
curl -sk -H "Authorization: Bearer <token>" \
  https://<controller-hostname>/api/v2/ping/ | python3 -m json.tool
```

Expected response contains `"ha": false` (or `true`) and `"version"`. Any non-200 response or
missing `version` key means authentication failed — stop and fix credentials before proceeding.

With the AWX collection:
```yaml
- name: Verify AAP connectivity
  awx.awx.controller_meta:
    controller_host: "{{ controller_hostname }}"
    controller_oauth_token: "{{ controller_oauth_token }}"
  register: meta_result
- debug:
    var: meta_result.version
```

### Rule 5 — Validate config syntax before pushing

Before any `ansible-navigator run` or `ansible-playbook` invocation, check that all YAML
configuration files are syntactically valid and conform to the `infra.aap_configuration`
variable schema:

```bash
# Lint all config YAML files
find config/ -name '*.yml' | xargs yamllint -d relaxed

# Dry-run the playbook syntax only (no connection to AAP)
ansible-playbook configure_aap.yml --syntax-check
```

Flag any YAML parsing errors or undefined required variables before running against the live server.

### Rule 6 — Always dry-run before resource apply

Use `--check` mode to preview what would change without modifying the live server:

**With ansible-navigator (preferred — uses an Execution Environment):**
```bash
ansible-navigator run configure_aap.yml \
  --mode stdout \
  --check \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml
```

**With ansible-playbook directly:**
```bash
ansible-playbook configure_aap.yml \
  --check \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml
```

Review the dry-run output carefully:
- `changed` tasks in check mode indicate the resource does not yet exist or differs from desired state.
- `failed` tasks in check mode indicate a real error — do not proceed to apply until resolved.
- `ok` tasks mean the resource already matches desired state (idempotent).

### Rule 7 — Verify resources exist after apply

After a successful apply, query AAP to confirm the resources were created or updated:

```bash
# List organizations
curl -sk -H "Authorization: Bearer <token>" \
  https://<controller-hostname>/api/v2/organizations/ | python3 -m json.tool

# Or use the AWX collection
- name: Fetch organizations
  awx.awx.organization:
    controller_host: "{{ controller_hostname }}"
    controller_oauth_token: "{{ controller_oauth_token }}"
    name: "{{ item.name }}"
    state: exists
  loop: "{{ controller_organizations }}"
```

If a resource is missing after apply, check the task output for warnings about missing required fields
or permission errors before re-running.

## References

See `references/openshift-auth.md` for OpenShift authentication walkthrough.
See `references/standalone-auth.md` for standalone/VM token and credentials file setup.
See `references/validation-steps.md` for the complete ordered validation checklist.
