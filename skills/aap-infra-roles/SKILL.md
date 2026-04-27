# AAP Infrastructure Roles Skill

You are assisting engineers working in the `redhat-cop/infra.aap_configuration` collection.

## Rules

### Variable Naming Conventions

All variables MUST use the `aap_` prefix to avoid namespace collisions:

| Variable | Correct Name | Wrong Name |
|:---|:---|:---|
| Controller hostname | `aap_hostname` | `controller_host`, `hostname` |
| Controller token | `aap_token` | `tower_token`, `token` |
| Controller username | `aap_username` | `username` |
| Controller password | `aap_password` | `password` |
| Validate certs | `aap_validate_certs` | `validate_certs` |

### Async Task Pattern

The `infra.aap_configuration` collection processes large numbers of resources
(job templates, credentials, inventories) using Ansible's async mechanism to
avoid sequential timeouts.

### The `collect_async_status` Pattern

Always use this pattern when configuring multiple AAP resources:

```yaml
- name: Configure {{ resource_type }}
  ansible.builtin.include_role:
    name: infra.aap_configuration.{{ resource_type }}
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_validate_certs: "{{ aap_validate_certs | default(true) }}"
  async: 3600
  poll: 0
  register: "{{ resource_type }}_async"

- name: Wait for {{ resource_type }} configuration
  ansible.builtin.include_role:
    name: infra.aap_configuration.collect_async_status
  vars:
    async_results: "{{ {{ resource_type }}_async }}"
```

See `references/async-pattern.yml` for a complete multi-resource example.

### Role Invocation Rules

### Rule 1 — Always pass connection variables explicitly

Never rely on environment variables or group_vars for connection info.
Pass `aap_hostname`, `aap_token`, and `aap_validate_certs` explicitly to every role.

### Rule 2 — Use collect_async_status for any role that modifies resources

Any role that creates, updates, or deletes AAP resources should be called with
`async: 3600` and `poll: 0`, followed by `collect_async_status`.

### Rule 3 — Order matters

Configure resources in dependency order:
1. Organizations
2. Credential types
3. Credentials
4. Projects
5. Inventories + Inventory sources
6. Job templates
7. Workflow templates

## References

See `references/async-pattern.yml` for the complete async task pattern with multiple resources.
