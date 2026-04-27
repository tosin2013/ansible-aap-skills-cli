# Ansible Validated Workflows Skill

You are assisting engineers using the `redhat-cop/infra.ansible_validated_workflows`
collection. This collection provides **pre-built, tested automation workflows** for
common infrastructure patterns — patching, provisioning, compliance remediation,
and certificate management — that conform to Red Hat CoP standards.

## Rules

### Rule 1 — Use validated workflows before writing custom playbooks

When a user describes a common infrastructure automation task, check
`references/workflow-catalog.md` first. If a validated workflow exists for the task,
invoke it rather than writing a custom playbook:

```yaml
# Use validated workflow — preferred
- name: Patch RHEL hosts
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.patch_rhel

# Custom playbook — only when no validated workflow exists
- name: Custom patching logic
  ...
```

### Rule 2 — Provide all required input variables

Every validated workflow has a defined set of required input variables. Do not invoke
a workflow without first checking and populating all required inputs.

Required inputs are documented per-workflow in `references/workflow-catalog.md`.
Missing required variables cause the workflow to fail at runtime — they are not
defaulted silently.

Example for `patch_rhel`:

```yaml
vars:
  avw_rhel_target_hosts: "{{ groups['rhel_servers'] }}"
  avw_rhel_reboot_allowed: true
  avw_rhel_reboot_timeout: 600
  avw_rhel_update_packages: "*"       # or a list of specific package names
```

### Rule 3 — Use the `avw_` variable prefix

All input variables for `infra.ansible_validated_workflows` roles use the `avw_` prefix.
Do not use generic variable names that may conflict with other collections:

| Correct | Wrong |
|:--------|:------|
| `avw_rhel_target_hosts` | `target_hosts`, `hosts` |
| `avw_reboot_allowed` | `reboot`, `allow_reboot` |
| `avw_cert_domain` | `domain`, `cert_domain` |

### Rule 4 — Do not modify validated workflow internals

Validated workflows are certified and tested as units. Do not edit role task files,
add tasks inside the role, or fork and modify unless absolutely necessary.

To customise behaviour, use the provided input variables. If a required customisation
is impossible via variables, file an upstream issue rather than patching the role locally
(see the `skill-research` skill for the issue filing workflow).

### Rule 5 — Register and check outputs

Validated workflows register their results in predictable output variables. Always
register the role output and assert success before proceeding:

```yaml
- name: Run patching workflow
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.patch_rhel
  vars:
    avw_rhel_target_hosts: "{{ groups['rhel_servers'] }}"
    avw_rhel_reboot_allowed: true
  register: patch_result

- name: Assert patching succeeded
  ansible.builtin.assert:
    that: patch_result.failed == false
    fail_msg: "Patching workflow failed: {{ patch_result.msg | default('unknown error') }}"
```

### Rule 6 — Pair with ansible-good-practices

Validated workflows are always invoked as part of a larger playbook. The wrapping
playbook must still follow the rules in the `ansible-good-practices` skill:
- Use FQCNs (`ansible.builtin.*`, `infra.ansible_validated_workflows.*`)
- Tag tasks for selective execution
- Use `no_log: true` on any task passing secrets

## References

See `references/workflow-catalog.md` for the full catalog of available workflows,
required inputs, outputs, and example invocations.
