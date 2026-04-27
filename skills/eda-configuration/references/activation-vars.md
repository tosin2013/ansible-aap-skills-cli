# EDA Activation Variable Schema

<!-- Last updated: 2026-04-27 -->

Reference for `eda_activations` and related variable keys used with
`redhat-cop/eda_configuration`.

---

## `eda_activations` — full schema

```yaml
eda_activations:
  - name: string                  # required — unique activation name
    description: string           # optional
    project: string               # required — EDA project name (must exist)
    rulebook: string              # required — rulebook filename (e.g. "watch_events.yml")
    decision_environment: string  # required — DE name (must exist)
    credential: string            # optional — credential name for the rulebook's event source
    enabled: bool                 # default: true — whether activation starts immediately
    restart_policy: string        # required — always | never | on-failure
    max_restarts: int             # optional — limit restarts for on-failure policy
    extra_vars: dict              # optional — runtime variables passed to the rulebook
    organization: string          # optional — defaults to "Default"
    log_level: string             # optional — debug | info | error | critical
    awx_token: string             # optional — token for run_job_template actions
```

---

## `eda_decision_environments`

```yaml
eda_decision_environments:
  - name: string          # required
    description: string   # optional
    image_url: string     # required — full registry path including tag
    credential: string    # optional — registry pull credential name
    organization: string  # optional
```

Supported images:
- `registry.redhat.io/ansible-automation-platform/de-supported-rhel9:latest`
- `registry.redhat.io/ansible-automation-platform/de-minimal-rhel9:latest`

---

## `eda_projects`

```yaml
eda_projects:
  - name: string              # required
    description: string       # optional
    url: string               # required — Git repo URL containing rulebooks
    credential: string        # optional — SCM credential for private repos
    organization: string      # optional
    verify_ssl: bool          # default: true
```

---

## `eda_credentials`

```yaml
eda_credentials:
  - name: string              # required
    description: string       # optional
    credential_type: string   # required — must match a credential type name
    organization: string      # optional
    inputs:
      username: string
      password: "{{ vault_<name> }}"   # always vault-encrypt secrets
```

---

## Connection variables

```yaml
# group_vars/all/eda_connection.yml
eda_host: "https://eda.example.com"
eda_token: "{{ vault_eda_token }}"
eda_validate_certs: true
```

For OpenShift-hosted EDA Controller, retrieve the route:
```bash
oc get route -n eda eda-controller -o jsonpath='{.spec.host}'
```

---

## Upstream references

- eda_configuration collection: https://github.com/redhat-cop/eda_configuration
- EDA Controller API: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform
