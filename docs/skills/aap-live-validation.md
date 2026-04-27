---
title: aap-live-validation
layout: default
parent: Skills
nav_order: 8
---

# aap-live-validation

**Target**: `aap_configuration_template`, `infra.aap_configuration`  
**Version**: 1.0.0  
**ADRs**: [ADR-012](../adrs/012-aap-live-validation-skill), [ADR-006](../adrs/006-secrets-management)

## Purpose

Guides AI agents through a safe, ordered validation sequence when coding against a **live AAP server**.
Covers both **OpenShift-hosted AAP** (AAP Operator) and **standalone AAP** (VM / bare metal),
with platform-specific authentication rules and a dry-run gate before any resource apply.

## Key Rules

| Rule | Description |
|:-----|:------------|
| Auth first | Never attempt connectivity or apply without confirmed authentication |
| OpenShift auth | `oc get route`, admin Secret retrieval, OAuth token creation via API |
| Standalone auth | OAuth PAT, vault-encrypted storage, CI environment variable pattern |
| Connectivity check | `GET /api/v2/ping/` must return 200 + `version` before proceeding |
| Syntax gate | `yamllint` + `--syntax-check` before any live-server interaction |
| Dry-run gate | `--check` mode required; review output before applying |
| Post-apply verify | Query REST API to confirm resources were created or updated |

## Validation Flow

```
Identify platform (OpenShift / Standalone)
        ↓
Authenticate (Rule 2 or Rule 3)
        ↓
Connectivity check — /api/v2/ping/
        ↓
Config syntax check — yamllint + --syntax-check
        ↓
Dry-run — ansible-navigator run --check
        ↓
Apply — ansible-navigator run
        ↓
Post-apply verify — curl /api/v2/organizations/ etc.
```

## Platform Split

### OpenShift-hosted AAP

```bash
# Get the controller route
oc get route -n aap automationcontroller -o jsonpath='{.spec.host}'

# Get the admin password
oc get secret -n aap automationcontroller-admin-password \
  -o jsonpath='{.data.password}' | base64 -d
```

### Standalone AAP

```bash
# Verify connectivity
curl -sk "https://<controller-fqdn>/api/v2/ping/" | python3 -m json.tool

# Create OAuth token via API
curl -sk -X POST \
  -u "admin:<password>" \
  -H "Content-Type: application/json" \
  -d '{"description":"local-dev","application":null,"scope":"write"}' \
  "https://<controller-fqdn>/api/v2/tokens/"
```

## Install

```bash
./install.sh install --skill aap-live-validation
```

## Reference Files

The skill includes supplementary reference files in `references/`:

- `openshift-auth.md` — complete OpenShift auth walkthrough (oc login → route → secret → token)
- `standalone-auth.md` — OAuth PAT creation, vault encryption, CI env var pattern
- `validation-steps.md` — ordered checklist with pass/fail criteria for each step
