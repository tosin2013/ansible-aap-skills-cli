---
title: "ADR-013: ansible-navigator Skill"
layout: default
parent: Architecture Decisions
nav_order: 13
---

# 13. ansible-navigator Skill

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Skill Development / EE Testing and Configuration

## Context

Two existing skills cover the Execution Environment lifecycle:

- `ee-yaml-schema` — enforces the `version: 3` manifest schema for `execution-environment.yml`
- `ee-build-workflow` — enforces `CONTAINER_ENGINE=podman make build` and related Makefile targets

Neither skill addresses what happens **after** the image is built and **before** it is pushed to a
registry: verifying that the image actually works. Without a smoke test step, broken images can
be pushed and silently fail when used by `ansible-navigator` on a live AAP server.

A second gap exists in configuration: engineers frequently set `ansible-navigator` options via
ad-hoc CLI flags rather than committing an `ansible-navigator.yml` file to the repository. This
leads to inconsistent runs across team members and CI pipelines, where the same playbook is
invoked with different EE images, pull policies, or execution modes.

Neither the `aap-live-validation` skill nor the `ee-build-workflow` skill is the right home for
these concerns: `aap-live-validation` is server-agnostic and covers the full validation sequence,
while `ee-build-workflow` is focused purely on the build step.

## Decision

Add a dedicated **`ansible-navigator` skill** covering:

1. **Configuration** — rules for `ansible-navigator.yml` structure, EE image selection
   (`image:` + `pull.policy:`), execution mode (`stdout` for CI, `interactive` locally),
   vault password passing, and playbook artifact settings
2. **EE smoke testing** — a post-build, pre-push verification sequence using
   `ansible-navigator collections`, `ansible-navigator exec`, and `ansible-navigator run`
   against a minimal `smoke-test.yml`

### Why a separate skill (not an extension of an existing one)

| Option | Reason rejected |
|:-------|:----------------|
| Add to `ee-build-workflow` | Build workflow skill should stay focused on `make` targets; navigator config is a separate concern |
| Add to `aap-live-validation` | That skill is about live-server interaction; smoke tests run against `localhost` without a server |
| Add to `ee-yaml-schema` | That skill is about the manifest file format, not runtime behaviour |

A separate skill allows it to be installed independently by engineers who use `ansible-navigator`
without also working on EE image builds.

### Scope of the skill's rules

| Rule | Description |
|:-----|:------------|
| Rule 1 — Config file | Project settings belong in `ansible-navigator.yml`; not CLI flags |
| Rule 2 — Mode | `stdout` for CI; `interactive` for local; never hard-code `interactive` in config |
| Rule 3 — Local EE images | `localhost/` prefix for podman; `pull.policy: never` for local images |
| Rule 4 — Vault secrets | `--vault-password-file` only; never `--ask-vault-pass` in CI |
| Rule 5 — Smoke test | `ansible-navigator collections` + `exec` + `run smoke-test.yml` before `make push` |
| Rule 6 — Artifacts | Enable artifacts in CI; disable locally; never commit `.json` files |

### Cross-skill relationships

```
ee-yaml-schema      ──► defines execution-environment.yml
ee-build-workflow   ──► builds the EE image (make build)
ansible-navigator   ──► configures navigator + smoke tests the image  ◄─ this skill
aap-live-validation ──► runs playbooks against a live AAP server
```

### Reference files

| File | Contents |
|:-----|:---------|
| `references/navigator-config.example.yml` | Fully annotated `ansible-navigator.yml` with all key options |
| `references/ee-smoke-test.md` | Step-by-step smoke test: image inspect → collections → exec → run |

## Consequences

**Positive:**
- Broken EE images are caught before push rather than at runtime on a live AAP server
- Consistent `ansible-navigator.yml` in every project repository prevents mode/image drift
- Smoke test reference is concrete and immediately actionable (copy `smoke-test.yml` and run)
- Clear boundary between build (ee-build-workflow) and runtime (ansible-navigator) concerns

**Negative:**
- Adds an eighth domain skill to maintain
- `ansible-navigator` settings schema changes with each release; the `skill-research` skill must
  track the navigator changelog to keep `navigator-config.example.yml` current
- The `smoke-test.yml` playbook in `ee-smoke-test.md` is a template — engineers must adapt
  collection assertions for their specific EE contents

## Implementation Plan

1. Create `skills/ansible-navigator/` with `SKILL.md`, `config.sh`, and two reference files
2. Create `docs/adrs/013-ansible-navigator-skill.md` (this file)
3. Add `docs/skills/ansible-navigator.md` to the GitHub Pages site
4. Update `docs/skills/index.md`, `docs/adrs/index.md`, `README.md`, and `sources-catalog.md`
5. Commit and push

## Related ADRs

- [ADR-001](001-skill-format-standard.md) — SKILL.md format this skill follows
- [ADR-007](007-execution-environment-yaml-schema.md) — EE YAML schema (upstream of this skill)
- [ADR-008](008-ee-build-toolchain.md) — EE build toolchain (upstream of this skill)
- [ADR-012](012-aap-live-validation-skill.md) — live validation (downstream consumer of this skill)

## References

- ansible-navigator documentation: https://ansible.readthedocs.io/projects/navigator/
- ansible-navigator settings reference: https://ansible.readthedocs.io/projects/navigator/settings/
- ansible-navigator subcommands: https://ansible.readthedocs.io/projects/navigator/subcommands/
