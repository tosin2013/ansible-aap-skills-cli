# EDA Configuration Skill

You are assisting engineers working in the `redhat-cop/eda_configuration` collection.
This collection manages **Event-Driven Ansible (EDA) resources** — rulebooks,
activations, event sources, decision environments, and credentials — as code.

## Rules

### Rule 1 — Always define rulebooks before activations

Activations reference a rulebook. The rulebook must exist in EDA Controller before
an activation is created. Configure resources in this dependency order:

1. Decision environments
2. Credentials
3. Projects (which sync rulebooks)
4. Rulebook activations

When using the `eda_configuration` collection roles, invoke them in the order above.

### Rule 2 — Use the `eda_` variable prefix

All variables passed to `eda_configuration` roles MUST use the `eda_` prefix:

| Variable | Correct | Wrong |
|:---------|:--------|:------|
| Controller host | `eda_host` | `controller_host`, `host` |
| Controller token | `eda_token` | `token`, `eda_api_token` |
| Validate certs | `eda_validate_certs` | `validate_certs` |

### Rule 3 — Rulebook structure requirements

Every rulebook file MUST contain:
- A `name:` field at the top level
- At least one `sources:` block referencing a valid event source plugin
- At least one `rules:` block with a `condition:` and an `action:`

Minimal valid rulebook:

```yaml
---
- name: "Watch for failed jobs"
  hosts: all
  sources:
    - ansible.eda.aws_sqs_queue:
        queue_url: "{{ queue_url }}"
        region: "{{ aws_region }}"
  rules:
    - name: Remediate on failure
      condition: event.detail.state == "FAILED"
      action:
        run_job_template:
          name: "Remediate"
          organization: "Default"
```

See `references/rulebook-structure.md` for annotated examples of common patterns.

### Rule 4 — Activation variables belong in the activation definition, not the rulebook

Do NOT embed environment-specific values (queue URLs, hostnames, thresholds) directly
in the rulebook YAML. Instead, pass them as `extra_vars` in the activation definition:

```yaml
# config/all/activations.yml
eda_activations:
  - name: "watch-failed-jobs"
    rulebook: "watch_failed_jobs.yml"
    project: "eda-rules"
    decision_environment: "de-supported"
    extra_vars:
      queue_url: "{{ vault_sqs_queue_url }}"
      aws_region: "us-east-1"
    enabled: true
```

### Rule 5 — Restart policy must be explicit

Always set `restart_policy` on activations. Do not rely on the default:

| Policy | Use when |
|:-------|:---------|
| `always` | Production activations that must stay running |
| `never` | One-shot or test activations |
| `on-failure` | Activations that should retry on error |

```yaml
eda_activations:
  - name: "watch-failed-jobs"
    restart_policy: always
```

### Rule 6 — Decision environments must reference a registry image

Never use a bare image name without a registry. Specify the full path:

```yaml
eda_decision_environments:
  - name: "de-supported"
    image_url: "registry.redhat.io/ansible-automation-platform/de-supported-rhel9:latest"
    credential: "registry-credential"
```

## References

See `references/rulebook-structure.md` for annotated rulebook patterns (conditions, actions, filters).
See `references/activation-vars.md` for the full activation variable schema and common configurations.
