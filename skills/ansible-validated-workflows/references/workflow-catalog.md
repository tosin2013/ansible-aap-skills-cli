# Ansible Validated Workflows Catalog

<!-- Last updated: 2026-04-27 -->

Reference for workflows available in `redhat-cop/infra.ansible_validated_workflows`.
All roles use the `avw_` variable prefix.

---

## `patch_rhel`

Applies OS patches to RHEL hosts with optional reboot handling.

**Required variables:**

| Variable | Type | Description |
|:---------|:-----|:------------|
| `avw_rhel_target_hosts` | list/string | Target hosts or group name |
| `avw_rhel_reboot_allowed` | bool | Whether reboot is permitted after patching |

**Optional variables:**

| Variable | Default | Description |
|:---------|:--------|:------------|
| `avw_rhel_update_packages` | `"*"` | Package list to update; `"*"` = all |
| `avw_rhel_reboot_timeout` | `600` | Seconds to wait for host to come back |
| `avw_rhel_pre_tasks` | `[]` | List of task files to include before patching |
| `avw_rhel_post_tasks` | `[]` | List of task files to include after patching |

**Example:**

```yaml
- name: Patch all RHEL servers
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.patch_rhel
  vars:
    avw_rhel_target_hosts: "{{ groups['rhel_servers'] }}"
    avw_rhel_reboot_allowed: true
    avw_rhel_reboot_timeout: 300
```

---

## `provision_vm`

Provisions a VM on a supported cloud or virtualisation provider.

**Required variables:**

| Variable | Type | Description |
|:---------|:-----|:------------|
| `avw_vm_name` | string | Name of the VM to create |
| `avw_vm_provider` | string | `aws`, `azure`, `gcp`, `vmware`, `openstack` |
| `avw_vm_image` | string | Source image/AMI name or ID |
| `avw_vm_size` | string | Instance type / flavor |

**Optional variables:**

| Variable | Default | Description |
|:---------|:--------|:------------|
| `avw_vm_region` | provider default | Cloud region |
| `avw_vm_network` | provider default | Network/VPC name |
| `avw_vm_tags` | `{}` | Key-value tags to apply |
| `avw_vm_wait` | `true` | Wait for VM to be reachable after provisioning |

**Example:**

```yaml
- name: Provision web server
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.provision_vm
  vars:
    avw_vm_name: "web-prod-01"
    avw_vm_provider: aws
    avw_vm_image: "ami-0abcdef1234567890"
    avw_vm_size: "t3.medium"
    avw_vm_region: "us-east-1"
    avw_vm_tags:
      environment: production
      role: web
```

---

## `remediate_compliance`

Applies remediation tasks based on a compliance scan result (OpenSCAP or similar).

**Required variables:**

| Variable | Type | Description |
|:---------|:-----|:------------|
| `avw_compliance_target_hosts` | list/string | Target hosts |
| `avw_compliance_profile` | string | Compliance profile ID (e.g. `xccdf_...`) |

**Optional variables:**

| Variable | Default | Description |
|:---------|:--------|:------------|
| `avw_compliance_report_path` | `/tmp/compliance-report.xml` | Path to write the post-remediation report |
| `avw_compliance_dry_run` | `false` | Report only — do not apply remediations |

**Example:**

```yaml
- name: Remediate CIS compliance findings
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.remediate_compliance
  vars:
    avw_compliance_target_hosts: "{{ groups['rhel_servers'] }}"
    avw_compliance_profile: "xccdf_org.ssgproject.content_profile_cis"
    avw_compliance_report_path: "/tmp/cis-report-{{ ansible_date_time.date }}.xml"
```

---

## `rotate_certificates`

Rotates TLS certificates using Let's Encrypt or an internal CA.

**Required variables:**

| Variable | Type | Description |
|:---------|:-----|:------------|
| `avw_cert_target_hosts` | list/string | Hosts requiring certificate renewal |
| `avw_cert_domain` | string | Primary domain name for the certificate |
| `avw_cert_provider` | string | `letsencrypt`, `internal_ca`, `vault` |

**Optional variables:**

| Variable | Default | Description |
|:---------|:--------|:------------|
| `avw_cert_san` | `[]` | Subject Alternative Names |
| `avw_cert_reload_services` | `[]` | Services to reload after cert update (e.g. `["nginx", "httpd"]`) |
| `avw_cert_vault_mount` | `pki` | Vault PKI mount point (when `avw_cert_provider: vault`) |

**Example:**

```yaml
- name: Rotate web server certificates
  ansible.builtin.include_role:
    name: infra.ansible_validated_workflows.rotate_certificates
  vars:
    avw_cert_target_hosts: "{{ groups['web_servers'] }}"
    avw_cert_domain: "app.example.com"
    avw_cert_provider: vault
    avw_cert_san:
      - "www.example.com"
      - "api.example.com"
    avw_cert_reload_services:
      - nginx
```

---

## Upstream references

- infra.ansible_validated_workflows: https://github.com/redhat-cop/infra.ansible_validated_workflows
- Red Hat CoP automation good practices: https://redhat-cop.github.io/automation-good-practices/
