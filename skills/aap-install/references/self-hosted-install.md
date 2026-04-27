# AAP 2.6 Self-Hosted Install Reference

<!-- Last updated: 2026-04-27 -->

> **AAP 2.6 installation guide (always fetch before following these steps):**
> https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/

This file provides structural guidance and annotated templates for AAP 2.6 self-hosted
installations. The official guide contains the authoritative, version-correct steps.

---

## Step 1 — Download the AAP 2.6 installer

1. Go to: https://access.redhat.com/downloads/content/480
2. Select **Red Hat Ansible Automation Platform 2.6**
3. Download **Red Hat Ansible Automation Platform 2.6 Setup** (or the bundle for air-gapped installs)
4. Extract the archive:
   ```bash
   tar -xzf ansible-automation-platform-setup-2.6.*.tar.gz
   cd ansible-automation-platform-setup-2.6.*/
   ```

---

## Step 2 — Edit the inventory file

The installer ships with a sample `inventory` file at the root of the extracted directory.
Edit it before running `setup.sh`.

### Minimum all-in-one inventory (single node, all components)

```ini
[automationcontroller]
controller.example.com ansible_connection=local

[automationhub]
# Leave empty to skip Automation Hub, or add a host:
# hub.example.com

[automationeda]
# Leave empty to skip EDA Controller, or add a host:
# eda.example.com

[database]
# Leave empty to use the embedded PostgreSQL on the controller node

[all:vars]
# --- Required ---
admin_password='<strong-password>'

pg_host=''
pg_port='5432'
pg_database='awx'
pg_username='awx'
pg_password='<strong-password>'
pg_sslmode='prefer'

# --- Registry credentials (required for connected installs) ---
registry_url='registry.redhat.io'
registry_username='<rhn-service-account-username>'
registry_password='<rhn-service-account-password>'

# --- Optional: Automation Hub ---
# automationhub_admin_password='<strong-password>'
# automationhub_pg_host=''
# automationhub_pg_port='5432'
# automationhub_pg_database='automationhub'
# automationhub_pg_username='automationhub'
# automationhub_pg_password='<strong-password>'

# --- Optional: EDA Controller ---
# automationedacontroller_admin_password='<strong-password>'
# automationedacontroller_pg_host=''
# automationedacontroller_pg_port='5432'
# automationedacontroller_pg_database='automationedacontroller'
# automationedacontroller_pg_username='automationedacontroller'
# automationedacontroller_pg_password='<strong-password>'
```

### Multi-node inventory (separate nodes)

```ini
[automationcontroller]
controller1.example.com
controller2.example.com   # add for HA

[automationhub]
hub.example.com

[automationeda]
eda.example.com

[database]
db.example.com            # external PostgreSQL

[all:vars]
admin_password='<strong-password>'

pg_host='db.example.com'
pg_port='5432'
pg_database='awx'
pg_username='awx'
pg_password='<strong-password>'
pg_sslmode='prefer'

registry_url='registry.redhat.io'
registry_username='<rhn-service-account-username>'
registry_password='<rhn-service-account-password>'
```

---

## Step 3 — Run the installer

```bash
# Standard connected install
./setup.sh

# Pass registry credentials as extra vars (alternative to inventory vars)
./setup.sh -- -e 'registry_username=<user>' -e 'registry_password=<pass>'

# Pass extra vars from a file
./setup.sh -e @extra_vars.yml

# Dry-run (syntax check only — does not install)
./setup.sh -- --check

# Resume a failed install (skip already-completed tasks)
./setup.sh -- --tags install
```

The installer writes logs to `setup.log` in the extracted directory. Monitor with:
```bash
tail -f setup.log
```

---

## Step 4 — Air-gapped / disconnected install

For environments without internet access, download the **Bundle** installer which includes
all container images and collections:

1. Download: https://access.redhat.com/downloads/content/480
   Select **Red Hat Ansible Automation Platform 2.6 Setup Bundle**

2. Add to inventory:
   ```ini
   [all:vars]
   bundle_install=true
   bundle_dir='<path-to-extracted-bundle>'
   ```

3. Run:
   ```bash
   ./setup.sh
   ```

For full disconnected install guidance:
https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/

---

## Common failure patterns

| Symptom | Likely cause | Fix |
|:--------|:-------------|:----|
| `registry.redhat.io` pull fails | Missing or invalid registry credentials | Verify `registry_username` / `registry_password` in inventory |
| `TASK [preflight]: Checking for valid subscription` fails | No active AAP subscription | Run `subscription-manager attach --auto` or attach correct pool |
| PostgreSQL connection refused | `pg_host` unreachable or wrong port | Verify DB host connectivity: `nc -zv <pg_host> 5432` |
| `SELinux is set to permissive` warning | SELinux disabled or permissive | Set `SELINUX=enforcing` in `/etc/selinux/config` and reboot |
| SSH connection refused to managed node | Passwordless SSH not configured | Run `ssh-copy-id <node>` from installer host |
| `FAILED: ...receptor` task | Port 27199 blocked | Open TCP 27199 between controller nodes |
| Hub content sync fails | No manifest loaded | Upload a manifest via Hub UI: *System → Subscription* |

---

## Post-install: retrieve admin credentials

```bash
# Admin password is what you set in inventory
# Controller URL
echo "Controller: https://$(hostname -f)"

# Verify login
curl -sk -u "admin:<admin_password>" \
  "https://$(hostname -f)/api/v2/me/" \
  | python3 -c "import sys,json; print('Login OK:', json.load(sys.stdin)['username'])"
```

---

## Upstream references

- AAP 2.6 installation guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/
- AAP 2.6 planning guide: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/
- AAP downloads: https://access.redhat.com/downloads/content/480
- Registry service accounts: https://access.redhat.com/terms-based-registry/
