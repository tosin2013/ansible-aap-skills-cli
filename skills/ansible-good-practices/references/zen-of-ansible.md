# Red Hat CoP Automation Good Practices — Summary

Source: https://redhat-cop.github.io/automation-good-practices/

## Role Design Considerations

### Focus on functionality, not software implementation

A role should express *what* a resource should look like, not *how* the underlying software works.
The role consumer should not need to understand AAP internals to use the role.

### Roles should be generic and reusable

Write roles that can be used in multiple contexts. Avoid hard-coding organization-specific values.
Use variables with sensible defaults for everything that might differ between deployments.

### Single responsibility

Each role should do one thing well. A role that configures organizations should not also configure
job templates. Split responsibilities across roles and compose them in playbooks.

## Playbook Design

### Playbooks are orchestrators

Playbooks call roles. They do not contain tasks directly (except for setup/teardown).
Business logic lives in roles; playbooks express the order of operations.

### Use meaningful play names

```yaml
# Good
- name: Configure AAP organizations and teams
  hosts: localhost

# Bad
- hosts: localhost
```

## Variable Management

### Variable precedence awareness

Know the Ansible variable precedence order. Prefer:
- Role defaults (`defaults/main.yml`) for user-overridable values
- Role vars (`vars/main.yml`) for internal role constants
- Inventory variables for host/group-specific values
- Extra vars (`-e`) for runtime overrides only

### Document all variables

Every variable in `defaults/main.yml` must have a comment explaining:
- What it does
- What values are valid
- What the default means

```yaml
# defaults/main.yml

# Hostname of the Ansible Automation Platform controller
# Must be a fully qualified domain name or IP address
# No trailing slash
aap_hostname: ""

# Whether to validate TLS certificates when connecting to AAP
# Set to false only in development environments with self-signed certs
aap_validate_certs: true
```

## Error Handling

### Always handle expected failures

```yaml
- name: Check if resource exists
  ansible.builtin.uri:
    url: "https://{{ aap_hostname }}/api/v2/organizations/"
    status_code: [200, 404]
  register: check_result

- name: Create resource if missing
  when: check_result.status == 404
  ...
```

### Use block/rescue for cleanup

```yaml
- block:
    - name: Configure resources
      ...
  rescue:
    - name: Log failure and clean up
      ...
  always:
    - name: Remove temporary files
      ...
```

## Testing

### Idempotency test (mandatory)

Run your playbook twice. The second run must report `changed=0`.

```bash
ansible-playbook site.yml         # first run — some changes expected
ansible-playbook site.yml         # second run — must be changed=0
```

### Use check mode for validation

```bash
ansible-playbook site.yml --check --diff
```

This catches syntax errors and shows what would change without making changes.
