# AAP Pre-flight Checklist

<!-- Last updated: 2026-04-27 -->

Complete this checklist before starting any AAP installation (OpenShift or self-hosted).

> **AAP 2.6 planning guide (always verify prerequisites against this):**
> https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/

---

## Subscription and entitlement

- [ ] Red Hat account has an active AAP subscription
- [ ] `subscription-manager status` → `Overall Status: Current`
- [ ] Subscription manifest downloaded from https://access.redhat.com/management/subscription_allocations
  - Required for: disconnected installs, Automation Hub content sync
- [ ] Registry credentials for `registry.redhat.io` available
  - Obtain from: https://access.redhat.com/terms-based-registry/

---

## Operating system (self-hosted only)

- [ ] RHEL 9.x (recommended) or RHEL 8.x
- [ ] `dnf update -y` run; system rebooted if kernel updated
- [ ] SELinux in `enforcing` mode (`getenforce` → `Enforcing`)
  - Do NOT disable — AAP supports SELinux enforcing
- [ ] `firewalld` or `iptables` running (not disabled)
- [ ] Python 3.9+ available: `python3 --version`
- [ ] Sufficient disk space on all nodes (see sizing table below)

---

## Minimum sizing

| Component | vCPU | RAM | Disk |
|:----------|:-----|:----|:-----|
| Automation Controller | 4 | 16 GB | 40 GB |
| Automation Hub | 4 | 8 GB | 60 GB (+ collection storage) |
| EDA Controller | 4 | 16 GB | 40 GB |
| External PostgreSQL | 2 | 8 GB | 20 GB |

For AAP 2.6 production sizing recommendations:
https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/

---

## Network requirements

### Required ports (self-hosted)

| Port | Protocol | Direction | Purpose |
|:-----|:---------|:----------|:--------|
| 80 | TCP | Inbound | HTTP redirect |
| 443 | TCP | Inbound | HTTPS (Controller, Hub, EDA) |
| 5432 | TCP | Internal | PostgreSQL |
| 27199 | TCP | Internal | Receptor (mesh networking) |
| 8443 | TCP | Internal | EDA Controller |
| 8080 | TCP | Internal | Automation Hub content |
| 22 | TCP | Installer → nodes | SSH (installer) |

### Required ports (OpenShift)

| Port | Protocol | Direction | Purpose |
|:-----|:---------|:----------|:--------|
| 443 | TCP | Inbound | OpenShift Routes (HTTPS) |
| 6443 | TCP | Internal | Kubernetes API |

For the complete AAP 2.6 port list:
https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/

---

## DNS

- [ ] Forward DNS resolution works for all component hostnames
- [ ] Reverse DNS (PTR records) configured for all nodes
- [ ] All nodes resolvable from the installer host
  ```bash
  # Test from installer host
  for host in controller.example.com hub.example.com; do
    getent hosts "$host" && echo "OK: $host" || echo "FAIL: $host"
  done
  ```

---

## SSH (self-hosted only)

- [ ] Installer host can SSH to all inventory nodes without a password prompt
  ```bash
  ssh -o BatchMode=yes controller.example.com whoami
  ```
- [ ] SSH user has passwordless `sudo` or is `root`
- [ ] `~/.ssh/known_hosts` updated for all nodes (avoid interactive host-key prompts)

---

## OpenShift-specific pre-flight

- [ ] OCP 4.12+ (check: `oc version`)
- [ ] Cluster has sufficient worker node capacity for AAP pods
- [ ] `ansible-automation-platform` namespace exists or will be created by operator
- [ ] Cluster admin or sufficient RBAC to install operators
  ```bash
  oc auth can-i create subscriptions.operators.coreos.com -n ansible-automation-platform
  ```
- [ ] Default storage class configured for PVCs (`oc get storageclass`)
- [ ] Pull secret includes `registry.redhat.io` credentials
  ```bash
  oc get secret pull-secret -n openshift-config \
    -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | python3 -m json.tool \
    | grep registry.redhat.io
  ```
