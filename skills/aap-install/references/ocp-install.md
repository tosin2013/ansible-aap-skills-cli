# AAP on OpenShift — Install Reference

<!-- Last updated: 2026-04-27 -->

> **AAP 2.6 OpenShift deployment guide (fetch before following these steps):**
> https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/

This file provides structural guidance and annotated examples. The official guide
contains the authoritative, version-correct steps.

---

## Option A — GitOps install (recommended): use the redhat-cop/gitops-catalog

The Red Hat CoP maintains production-ready **Kustomize overlays** for the AAP Operator
and instances. Use these instead of hand-crafting raw YAML when deploying via ArgoCD,
OpenShift GitOps, or any Kustomize-based pipeline.

**Repository:** https://github.com/redhat-cop/gitops-catalog/tree/main/ansible-automation-platform

Structure:
```
ansible-automation-platform/
├── operator/          # Namespace + OperatorGroup + Subscription
├── instance/          # AutomationController CR
└── hub-instance/      # AutomationHub CR
```

### Apply with Kustomize directly

```bash
# 1 — Install the operator
oc apply -k https://github.com/redhat-cop/gitops-catalog/ansible-automation-platform/operator

# 2 — Wait for operator to become ready
oc wait --for=condition=Established crd automationcontrollers.automationcontroller.ansible.com \
  --timeout=120s

# 3 — Deploy the AutomationController instance
oc apply -k https://github.com/redhat-cop/gitops-catalog/ansible-automation-platform/instance
```

### Use as a base in your own overlay

Create a local overlay that references the catalog as a remote base:

```yaml
# kustomization.yaml in your repo
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://github.com/redhat-cop/gitops-catalog/ansible-automation-platform/operator
  - https://github.com/redhat-cop/gitops-catalog/ansible-automation-platform/instance
patches:
  - target:
      kind: AutomationController
      name: automationcontroller
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
```

### Apply with ArgoCD / OpenShift GitOps

Create an `Application` CR pointing at the gitops-catalog (or your overlay):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aap-operator
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/redhat-cop/gitops-catalog
    targetRevision: main
    path: ansible-automation-platform/operator
  destination:
    server: https://kubernetes.default.svc
    namespace: ansible-automation-platform
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Option B — Manual install (raw YAML / CLI)



```bash
oc new-project ansible-automation-platform
```

---

## Step 2 — Subscribe to the AAP Operator

**Via OperatorHub UI:** OpenShift Console → Operators → OperatorHub → search "Ansible Automation Platform"
→ Install → choose namespace `ansible-automation-platform`.

**Via CLI:**

```yaml
# aap-subscription.yml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ansible-automation-platform-operator
  namespace: ansible-automation-platform
   spec:
     channel: 'stable-2.6'         # AAP 2.6 channel — see channel table below for other versions
  installPlanApproval: Automatic
  name: ansible-automation-platform-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

```bash
oc apply -f aap-subscription.yml
oc get csv -n ansible-automation-platform -w   # wait for Succeeded
```

### Operator channel table

| AAP Version | Operator channel |
|:------------|:----------------|
| AAP 2.6 | `stable-2.6` *(this skill)* |
| AAP 2.5 | `stable-2.5` |
| AAP 2.4 | `stable-2.4` |
| AAP 2.3 | `stable-2.3` |

> Check current channels: `oc get packagemanifest ansible-automation-platform-operator -o jsonpath='{.status.channels[*].name}'`

---

## Step 3 — Create the AutomationController CR

```yaml
# automationcontroller.yml
apiVersion: automationcontroller.ansible.com/v1beta1
kind: AutomationController
metadata:
  name: automationcontroller
  namespace: ansible-automation-platform
spec:
  admin_user: admin
  replicas: 1
  # Optional: specify a custom admin password secret
  # admin_password_secret: my-admin-password-secret

  # Optional: configure external PostgreSQL
  # database_secret: my-db-secret

  # Optional: set resource limits
  # web_resource_requirements:
  #   requests:
  #     cpu: 500m
  #     memory: 1Gi
  #   limits:
  #     cpu: 2
  #     memory: 4Gi
```

```bash
oc apply -f automationcontroller.yml
oc get automationcontroller -n ansible-automation-platform -w
```

---

## Step 4 — (Optional) Create AutomationHub CR

```yaml
apiVersion: automationhub.ansible.com/v1beta1
kind: AutomationHub
metadata:
  name: automationhub
  namespace: ansible-automation-platform
spec:
  storage_type: File    # or S3 for production
  file_storage_storage_class: <your-rwx-storage-class>
```

---

## Step 5 — Verify pods are Running

```bash
# Watch all pods until stable
oc get pods -n ansible-automation-platform -w

# Wait for controller pod readiness
oc wait --for=condition=Ready pod \
  -l app.kubernetes.io/name=automationcontroller \
  -n ansible-automation-platform \
  --timeout=600s
```

Expected pods (controller only):
- `automationcontroller-<hash>` — main controller pod
- `automationcontroller-postgres-<hash>` — embedded PostgreSQL (if no external DB)
- `automationcontroller-task-<hash>` — task dispatcher
- `automationcontroller-web-<hash>` — web frontend

---

## Step 6 — Retrieve admin credentials and route

```bash
# Admin password (auto-generated if not specified)
oc get secret automationcontroller-admin-password \
  -n ansible-automation-platform \
  -o jsonpath='{.data.password}' | base64 -d

# Controller route
oc get route automationcontroller \
  -n ansible-automation-platform \
  -o jsonpath='{.spec.host}'
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|:--------|:-------------|:----|
| Pod stuck in `Pending` | No available PVC / storage class | Check `oc get pvc -n aap`; verify default storage class |
| `CrashLoopBackOff` on controller pod | DB connection failure | Check `oc logs <pod>` for postgres connection error; verify DB secret |
| Operator CSV stuck in `Installing` | Pull secret missing `registry.redhat.io` | Add registry credentials to cluster pull secret |
| Route not created | Operator version mismatch | Check operator CSV version matches the CR API version |

For AAP 2.6 troubleshooting guidance:
https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/

---

## Upstream references

- AAP 2.6 Operator on OCP: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/
- AAP 2.6 documentation index: https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/
- Red Hat CoP gitops-catalog (AAP): https://github.com/redhat-cop/gitops-catalog/tree/main/ansible-automation-platform
- OpenShift GitOps / ArgoCD docs: https://docs.openshift.com/gitops/latest/understanding_openshift_gitops/about-redhat-openshift-gitops.html
- OpenShift Operator Lifecycle Manager: https://docs.openshift.com/container-platform/latest/operators/understanding/olm/olm-understanding-olm.html
