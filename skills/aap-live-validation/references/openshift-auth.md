# OpenShift-Hosted AAP Authentication

<!-- Last updated: 2026-04-27 -->

This reference covers authenticating to an AAP Controller that was deployed via the
**Ansible Automation Platform Operator** on Red Hat OpenShift.

---

## Prerequisites

- `oc` CLI installed and configured for the cluster
- Access to the namespace where the AAP Operator is installed (commonly `aap` or `ansible-automation-platform`)
- Cluster-admin or namespace-admin role (required to read the admin-password Secret)

---

## Step 1 — Log in to the OpenShift cluster

```bash
# Interactive login (browser-based)
oc login --web https://<openshift-api-url>:6443

# Token-based login (for CI or scripted flows)
oc login --token=<token> --server=https://<openshift-api-url>:6443

# Verify you are authenticated
oc whoami
```

---

## Step 2 — Identify the AAP namespace and controller name

```bash
# List AutomationController resources across all namespaces
oc get automationcontroller --all-namespaces

# Example output:
# NAMESPACE   NAME                    AGE
# aap         automationcontroller    14d
```

Set variables for subsequent commands:
```bash
AAP_NS="aap"
CONTROLLER_NAME="automationcontroller"
```

---

## Step 3 — Retrieve the controller route (hostname)

```bash
CONTROLLER_HOST=$(oc get route -n "${AAP_NS}" "${CONTROLLER_NAME}" \
  -o jsonpath='{.spec.host}')
echo "Controller host: ${CONTROLLER_HOST}"
```

The full URL will be `https://${CONTROLLER_HOST}`.

---

## Step 4 — Retrieve the admin password

The AAP Operator stores the admin password in a Secret named `<controller-name>-admin-password`:

```bash
ADMIN_PASSWORD=$(oc get secret -n "${AAP_NS}" \
  "${CONTROLLER_NAME}-admin-password" \
  -o jsonpath='{.data.password}' | base64 -d)
echo "Admin password retrieved (do not log this in CI)"
```

> **Security note:** Never print `ADMIN_PASSWORD` to CI logs. Use a masked variable or
> pass it directly to `ansible-vault encrypt_string`.

---

## Step 5 — (Optional) Create an OAuth token instead of using the password

Using a long-lived OAuth token is preferred over embedding the admin password:

```bash
# Create a token via the AAP API
curl -sk -X POST \
  -u "admin:${ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '{"description":"ci-token","application":null,"scope":"write"}' \
  "https://${CONTROLLER_HOST}/api/v2/tokens/" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])"
```

Store the result with ansible-vault:
```bash
ansible-vault encrypt_string '<token-value>' --name 'controller_oauth_token'
```

---

## Step 6 — Set Ansible connection variables

```yaml
# group_vars/all/aap_connection.yml
controller_hostname: "https://{{ lookup('env','CONTROLLER_HOST') }}"
controller_oauth_token: "{{ vault_controller_oauth_token }}"
controller_validate_certs: true   # set false only for self-signed lab certs
```

Or as environment variables for ansible-navigator:

```bash
export CONTROLLER_HOST="https://${CONTROLLER_HOST}"
export CONTROLLER_OAUTH_TOKEN="${OAUTH_TOKEN}"
export CONTROLLER_VERIFY_SSL="true"
```

---

## Step 7 — Verify connectivity

```bash
curl -sk \
  -H "Authorization: Bearer ${OAUTH_TOKEN}" \
  "https://${CONTROLLER_HOST}/api/v2/ping/" | python3 -m json.tool
```

Expected response:
```json
{
  "ha": false,
  "version": "4.x.y",
  "active_node": "...",
  "install_uuid": "..."
}
```

---

## Upstream references

- AAP Operator documentation: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform
- OpenShift oc CLI: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html
- AAP REST API guide: https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html
