# AAP Utilities Skill

You are assisting engineers using the `redhat-cop/aap_utilities` collection.
This collection provides **helper roles** for common AAP operational tasks that
fall outside the scope of resource configuration (handled by `infra.aap_configuration`)
or EDA (handled by `eda_configuration`).

Typical uses: dispatching configuration across multiple controllers, tagging resources
in bulk, performing health checks, generating reports, and managing tokens.

## Rules

### Rule 1 — Use utility roles for operational tasks, not configuration roles

`aap_utilities` roles handle **operational and administrative tasks**. They are not
a substitute for `infra.aap_configuration` collection roles when the goal is to
create or update AAP resources (organizations, inventories, credentials).

| Task | Correct collection |
|:-----|:-------------------|
| Create an organization | `infra.aap_configuration.organizations` |
| Health check the controller | `aap_utilities.controller_ping` |
| Bulk-tag existing resources | `aap_utilities.bulk_tag` |
| Export configuration backup | `aap_utilities.export_config` |
| Manage user tokens | `aap_utilities.manage_tokens` |

### Rule 2 — Pass connection variables consistently with aap-infra-roles

`aap_utilities` roles accept the same `aap_` prefixed connection variables as
`infra.aap_configuration`:

```yaml
- name: Check controller health
  ansible.builtin.include_role:
    name: aap_utilities.controller_ping
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_validate_certs: "{{ aap_validate_certs | default(true) }}"
```

Never mix `controller_host` / `tower_token` naming with `aap_utilities` roles.

### Rule 3 — Run health checks before bulk operations

Before any bulk-tag, bulk-export, or dispatch operation, run `controller_ping` to
confirm the controller is reachable and the token is valid:

```yaml
- name: Verify controller is reachable
  ansible.builtin.include_role:
    name: aap_utilities.controller_ping
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"

- name: Run bulk operation
  ansible.builtin.include_role:
    name: aap_utilities.bulk_tag
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_tag_resources: "{{ tag_definitions }}"
```

### Rule 4 — Use export_config for backup before destructive changes

Before any bulk-delete or major reconfiguration, export the current state:

```yaml
- name: Export current configuration as backup
  ansible.builtin.include_role:
    name: aap_utilities.export_config
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_export_path: "/tmp/aap-backup-{{ ansible_date_time.date }}.json"
```

### Rule 5 — Never hardcode token values; use vault-encrypted variables

Tokens passed to any `aap_utilities` role must come from vault-encrypted variables
(see the `aap-secrets-management` skill). Never inline token values in task files or
`extra_vars` passed on the command line.

## References

See `references/utility-roles.md` for a catalog of available roles, their required
variables, and example invocations.
