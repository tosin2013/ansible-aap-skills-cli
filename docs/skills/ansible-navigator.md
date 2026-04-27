---
title: ansible-navigator
layout: default
parent: Skills
nav_order: 9
---

# ansible-navigator

**Target**: `ansible-execution-environment`, `aap_configuration_template`  
**Version**: 1.0.0  
**ADRs**: [ADR-013](../adrs/013-ansible-navigator-skill), [ADR-008](../adrs/008-ee-build-toolchain)

## Purpose

Configures `ansible-navigator.yml` for consistent runs across team members and CI, and
guides the **EE image smoke test** that should run after every build and before every push.

Sits between the `ee-build-workflow` skill (which builds the image) and the `aap-live-validation`
skill (which runs against a live AAP server) in the EE lifecycle:

```
ee-yaml-schema → ee-build-workflow → ansible-navigator → aap-live-validation
  (manifest)       (make build)       (smoke test +        (live server run)
                                       configure)
```

## Key Rules

| Rule | Description |
|:-----|:------------|
| Config file | All settings in `ansible-navigator.yml` at repo root — not CLI flags |
| Mode | `stdout` for CI; `interactive` locally; never hard-code `interactive` in config |
| Local EE images | Use `localhost/<image>:<tag>` prefix; set `pull.policy: never` |
| Vault secrets | `--vault-password-file` only; never `--ask-vault-pass` in CI |
| Smoke test | Run collections + exec + smoke-test.yml **before** `make push` |
| Artifacts | Enable in CI; disable locally; never commit `.json` artifact files |

## Smoke Test Sequence

After `CONTAINER_ENGINE=podman make build` and before `make push`:

```bash
IMAGE="localhost/ansible-execution-environment:latest"

# 1 — verify collections
ansible-navigator collections \
  --execution-environment-image "${IMAGE}" \
  --pull-policy never \
  --mode stdout

# 2 — run smoke-test.yml
ansible-navigator run smoke-test.yml \
  --execution-environment-image "${IMAGE}" \
  --pull-policy never \
  --mode stdout
```

## Minimal ansible-navigator.yml

```yaml
ansible-navigator:
  execution-environment:
    enabled: true
    image: localhost/ansible-execution-environment:latest
    pull:
      policy: missing
  mode: stdout
  playbook-artifact:
    enable: false
```

## Install

```bash
./install.sh install --skill ansible-navigator
```

## Reference Files

- `references/navigator-config.example.yml` — fully annotated `ansible-navigator.yml` with all options
- `references/ee-smoke-test.md` — step-by-step smoke test with a copyable `smoke-test.yml` playbook
