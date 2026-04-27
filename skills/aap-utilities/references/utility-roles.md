# AAP Utilities Role Catalog

<!-- Last updated: 2026-04-27 -->

Reference for roles available in `redhat-cop/aap_utilities`. All roles share
the same connection variable contract (`aap_hostname`, `aap_token`, `aap_validate_certs`).

---

## Connection variables (required for all roles)

```yaml
aap_hostname: "https://aap.example.com"        # controller URL
aap_token: "{{ vault_aap_token }}"              # OAuth token (vault-encrypted)
aap_validate_certs: true                         # set false only for self-signed lab certs
```

---

## `controller_ping`

Verifies connectivity and token validity. Returns controller version in registered output.

```yaml
- name: Ping controller
  ansible.builtin.include_role:
    name: aap_utilities.controller_ping
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_validate_certs: "{{ aap_validate_certs }}"
  register: ping_result

- name: Show controller version
  ansible.builtin.debug:
    msg: "Controller version: {{ ping_result.version }}"
```

---

## `export_config`

Exports the full controller configuration to a JSON file. Useful for backups and
config drift detection.

```yaml
- name: Export configuration
  ansible.builtin.include_role:
    name: aap_utilities.export_config
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_export_path: "/tmp/aap-config-{{ ansible_date_time.date }}.json"
    aap_export_include:               # optional: limit exported resource types
      - organizations
      - credentials
      - job_templates
      - projects
```

---

## `bulk_tag`

Applies tags to multiple AAP resources in a single operation.

```yaml
- name: Tag all production resources
  ansible.builtin.include_role:
    name: aap_utilities.bulk_tag
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_token }}"
    aap_tag_resources:
      - resource_type: job_template
        name_filter: "prod-*"
        tags:
          environment: production
          managed_by: ansible
```

---

## `manage_tokens`

Creates, lists, or revokes OAuth personal access tokens for AAP users.

```yaml
# Create a token
- name: Create deploy token
  ansible.builtin.include_role:
    name: aap_utilities.manage_tokens
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_admin_token }}"
    aap_token_action: create
    aap_token_username: "deploy-user"
    aap_token_description: "CI deploy token"
    aap_token_scope: write
  register: new_token

# Revoke a token
- name: Revoke token by ID
  ansible.builtin.include_role:
    name: aap_utilities.manage_tokens
  vars:
    aap_hostname: "{{ aap_hostname }}"
    aap_token: "{{ aap_admin_token }}"
    aap_token_action: revoke
    aap_token_id: "{{ token_id_to_revoke }}"
```

---

## `dispatch_config`

Runs an AAP configuration playbook against multiple controllers in sequence or parallel.
Useful for multi-controller environments (hub + spokes).

```yaml
- name: Dispatch configuration to all controllers
  ansible.builtin.include_role:
    name: aap_utilities.dispatch_config
  vars:
    aap_dispatch_targets:
      - hostname: "https://hub.example.com"
        token: "{{ vault_hub_token }}"
      - hostname: "https://spoke1.example.com"
        token: "{{ vault_spoke1_token }}"
    aap_dispatch_playbook: "configure_aap.yml"
    aap_dispatch_extra_vars:
      env: "{{ target_env }}"
```

---

## Upstream references

- aap_utilities collection: https://github.com/redhat-cop/aap_utilities
- AAP Token API: https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html
