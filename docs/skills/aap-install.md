---
title: aap-install
layout: default
parent: Skills
nav_order: 14
---

# aap-install

Guides pre-flight checks, OpenShift Operator install (GitOps-catalog and raw YAML paths),
self-hosted installer configuration, and post-install validation for
**Ansible Automation Platform 2.6**.

## Purpose

This skill helps AI agents drive or review every stage of an AAP 2.6 installation.
Rather than embedding version-specific commands that go stale, the skill surfaces
**inline links to official Red Hat documentation** and the **Red Hat CoP gitops-catalog**,
ensuring the agent always references current, authoritative instructions.

The skill hands off cleanly to `aap-live-validation` once installation is complete.

## Rules Overview

| # | Rule | Description |
|:--|:-----|:------------|
| 1 | Identify target version | Confirm AAP 2.6; surface version index if different version detected |
| 2 | Pre-flight checklist | Subscription, OS, ports, DNS, SSH, OpenShift RBAC / storage class |
| 3 | OpenShift install | gitops-catalog Kustomize overlays (preferred) or raw Subscription + CR YAML |
| 4 | Self-hosted install | `aap-setup` inventory groups/vars, `setup.sh` flags, air-gapped bundle |
| 5 | Post-install validation | Controller `/api/v2/ping/`, Hub Pulp API, EDA health, pod status |
| 6 | Version-matched doc URL | Always use `/2.6/` docs path; flag if user is on a different version |

## Targets

`ansible-automation-platform`

## Reference Files

| File | Contents |
|:-----|:---------|
| [`references/preflight-checklist.md`](https://github.com/tosin2013/ansible-aap-skills-cli/blob/main/skills/aap-install/references/preflight-checklist.md) | Port table, OS/subscription requirements, sizing, OCP RBAC checks |
| [`references/ocp-install.md`](https://github.com/tosin2013/ansible-aap-skills-cli/blob/main/skills/aap-install/references/ocp-install.md) | gitops-catalog overlays, ArgoCD Application CR, raw YAML, troubleshooting |
| [`references/self-hosted-install.md`](https://github.com/tosin2013/ansible-aap-skills-cli/blob/main/skills/aap-install/references/self-hosted-install.md) | Annotated inventory templates, `setup.sh` flags, air-gapped patterns |

## Upstream Documentation

- [AAP 2.6 documentation index](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/)
- [AAP 2.6 planning guide](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_planning_guide/)
- [AAP 2.6 OpenShift install guide](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/deploying_the_red_hat_ansible_automation_platform_operator_on_red_hat_openshift_container_platform/)
- [AAP 2.6 self-hosted install guide](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/red_hat_ansible_automation_platform_installation_guide/)
- [Red Hat CoP gitops-catalog — AAP](https://github.com/redhat-cop/gitops-catalog/tree/main/ansible-automation-platform)

## ADR

[ADR-017: AAP Install Skill](../adrs/017-aap-install-skill.md)

## Related Skills

- **aap-live-validation** — validates a running AAP server (the next step after installation)
- **ansible-navigator** — configures `ansible-navigator.yml` and tests Execution Environments
- **aap-utilities** — uses `redhat-cop/aap_utilities` helper roles for operational tasks
