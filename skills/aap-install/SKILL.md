# AAP Install Skill

You are assisting engineers with installing or validating **Red Hat Ansible Automation
Platform (AAP) 2.6** on either **Red Hat OpenShift** (via the AAP Operator) or a
**self-hosted environment** (VM, bare metal, or standalone container).

This skill targets **AAP 2.6** specifically. For other versions, update the operator
channel and inventory variables accordingly. Installation procedures change with every
release — this skill always directs you to the **official Red Hat documentation** for
the exact steps that match AAP 2.6.

## Rules

### Rule 1 — Always identify the target AAP version before suggesting any steps

Before recommending installation steps, determine:
1. Which AAP version the user is targeting (e.g., 2.4, 2.5, 25.x)
2. Which deployment platform (OpenShift or self-hosted)

This skill targets **AAP 2.6**. Fetch the version-specific guide from the official documentation:

> **AAP 2.6 documentation index**: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6

For other versions, navigate the top-level index:
> https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform

Always use the version-specific URL (with `/2.6` in the path) when suggesting steps
to avoid surfacing docs for a different release.

### Rule 2 — Pre-flight: verify all prerequisites before starting installation

A failed installation is almost always caused by skipping pre-flight checks. Before any
install step, verify:

**Subscriptions and entitlements:**
- Red Hat subscription with AAP entitlement is active
- `subscription-manager status` shows `Overall Status: Current`
- Manifest file downloaded from https://access.redhat.com/management/subscription_allocations

**Operating system (self-hosted):**
- RHEL 9.x (preferred) or RHEL 8.x
- `dnf update` applied; system rebooted if kernel was updated
- `selinux` in `enforcing` mode (do not disable — AAP supports SELinux)

**Network and firewall:**
- Required ports open — see `references/preflight-checklist.md` for the full port table
- DNS resolution working for all nodes in the inventory
- All nodes reachable via SSH from the installer host (self-hosted)

**Resources (minimum per component):**
- Automation Controller: 4 vCPU, 16 GB RAM, 40 GB disk
- Automation Hub: 4 vCPU, 8 GB RAM, 60 GB disk (more for large collection storage)
- EDA Controller: 4 vCPU, 16 GB RAM, 40 GB disk

> **AAP 2.6 sizing guide**: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/

See `references/preflight-checklist.md` for the complete checklist.

### Rule 3 — OpenShift install: deploy via the AAP Operator

When AAP is deployed on OpenShift, always use the **AAP Operator** via OperatorHub
or the CLI. Never attempt a manual pod deployment.

High-level steps (fetch current steps from the linked guide):

1. **Subscribe the operator** — create a `Subscription` in the `ansible-automation-platform` namespace:
   ```yaml
   apiVersion: operators.coreos.com/v1alpha1
   kind: Subscription
   metadata:
     name: ansible-automation-platform-operator
     namespace: ansible-automation-platform
   spec:
     channel: 'stable-2.6'
     installPlanApproval: Automatic
     name: ansible-automation-platform-operator
     source: redhat-operators
     sourceNamespace: openshift-marketplace
   ```

2. **Create the AutomationController CR** — after the operator is ready:
   ```yaml
   apiVersion: automationcontroller.ansible.com/v1beta1
   kind: AutomationController
   metadata:
     name: automationcontroller
     namespace: ansible-automation-platform
   spec:
     admin_user: admin
     replicas: 1
   ```

3. **Verify pods are Running**:
   ```bash
   oc get pods -n ansible-automation-platform
   oc wait --for=condition=Ready pod -l app=automationcontroller \
     -n ansible-automation-platform --timeout=600s
   ```

> **AAP 2.6 OpenShift installation guide**: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/

> **GitOps-ready Kustomize overlays (Red Hat CoP)**: https://github.com/redhat-cop/gitops-catalog/tree/main/ansible-automation-platform
> Use these overlays instead of writing raw YAML when deploying via GitOps/ArgoCD.

See `references/ocp-install.md` for annotated CR examples, the gitops-catalog overlay structure, and troubleshooting tips.

### Rule 4 — Self-hosted install: inventory file and `setup.sh`

When installing on VMs or bare metal, use the official AAP installer bundle (`aap-setup.tar.gz`).

**Do not** use `ansible-playbook` directly against the installer roles — always run `./setup.sh`.

Key steps:

1. **Download the installer** from https://access.redhat.com/downloads/content/480
   Select the correct AAP version and architecture.

2. **Edit the inventory file** — the installer ships with a sample `inventory` file.
   Minimum required groups and variables:
   ```ini
   [automationcontroller]
   controller.example.com

   [database]
   # Leave empty to use the embedded PostgreSQL on the controller node
   # Or specify an external DB host here

   [automationhub]
   hub.example.com

   [all:vars]
   admin_password='<vault-encrypted-or-strong-password>'
   pg_host=''
   pg_port='5432'
   pg_database='awx'
   pg_username='awx'
   pg_password='<vault-encrypted-or-strong-password>'
   ```

3. **Run the installer**:
   ```bash
   cd aap-setup-<version>/
   ./setup.sh
   ```

4. **Common flags**:
   ```bash
   ./setup.sh -- -e 'registry_username=<rhn-user>' \
                  -e 'registry_password=<rhn-password>'  # for connected installs
   ./setup.sh -e @extra_vars.yml                          # extra vars from file
   ```

> **AAP 2.6 self-hosted installation guide**: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/

See `references/self-hosted-install.md` for the annotated inventory template and common failure patterns.

### Rule 5 — Post-install validation

After installation completes, verify all components are healthy before handing off to the user.

**Automation Controller:**
```bash
# Health check — must return HTTP 200 with version key
curl -sk https://<controller-host>/api/v2/ping/ | python3 -m json.tool

# Verify admin login works
curl -sk -u admin:<password> https://<controller-host>/api/v2/me/ \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])"
```

**Automation Hub** (if deployed):
```bash
curl -sk https://<hub-host>/api/galaxy/v3/plugin/ansible/search/collection-versions/ \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Hub OK, collections:', d.get('meta',{}).get('count',0))"
```

**EDA Controller** (if deployed):
```bash
curl -sk https://<eda-host>/api/eda/v1/auth/session/login/
# Expected: 405 Method Not Allowed (endpoint exists but GET not allowed = service is up)
```

**OpenShift — check all pods:**
```bash
oc get pods -n ansible-automation-platform
# All pods should be in Running or Completed state
# No pods in CrashLoopBackOff or Pending (unless init containers)
```

After validation passes, proceed to the `aap-live-validation` skill for first-use
authentication and configuration workflow.

### Rule 6 — Always surface the AAP 2.6 doc URL; flag if user is on a different version

This skill targets AAP 2.6. Installation steps change between releases. When a user asks
how to perform a specific install step, respond with:
1. The AAP 2.6 doc URL (base: `https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/`)
2. A summary of what to look for in that section
3. Any common pitfalls from `references/`

Do not copy-paste multi-step procedures from documentation into chat — direct the user
to the doc and explain the key decisions.

## References

See `references/preflight-checklist.md` for the full pre-flight checklist with port tables and sizing links.
See `references/ocp-install.md` for OpenShift CR examples, channel list, and troubleshooting.
See `references/self-hosted-install.md` for the annotated inventory file and common install failures.
