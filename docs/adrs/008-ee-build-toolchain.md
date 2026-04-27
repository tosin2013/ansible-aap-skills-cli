---
title: "ADR-008: EE Build Toolchain"
layout: default
parent: Architecture Decisions
nav_order: 8
---

# 8. Execution Environment Build Toolchain

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Ansible Execution Environment / Build Toolchain

## Context

The `tosin2013/ansible-execution-environment` repository uses a `Makefile` to abstract the `ansible-builder` invocation. Engineers and AI agents assisting with this repository must use the Makefile targets rather than calling `ansible-builder` directly, because the Makefile encodes environment-specific flags and container engine configuration.

The target environment uses **Podman** (not Docker) as the container engine, which requires an explicit flag when invoking `ansible-builder`.

## Decision

The `ee-build-workflow` skill will instruct AI agents to:

1. Use **Makefile targets** for all build operations — never invoke `ansible-builder` directly
2. Always pass `CONTAINER_ENGINE=podman` when executing make targets
3. Use the following canonical targets:

| Target | Purpose |
|---|---|
| `make build` | Build the execution environment image |
| `make test` | Run sanity/integration tests against the built image |
| `make push` | Tag and push the image to the registry |

4. When suggesting build commands, always use the form:
   ```bash
   CONTAINER_ENGINE=podman make build
   ```

5. Do **not** suggest `docker build` or direct `ansible-builder build` invocations

## Consequences

**Positive:**
- AI-generated commands are immediately runnable in the target environment (Podman)
- Makefile abstraction means build logic changes do not require skill updates
- Consistent with how the repository's CI/CD pipeline invokes builds

**Negative:**
- If the Makefile is restructured (targets renamed), the skill must be updated
- Agents unaware of `CONTAINER_ENGINE` may suggest Docker-only commands on Podman systems

## Implementation Plan

1. Write `skills/ee-build-workflow/SKILL.md` encoding the rules above
2. Add `references/Makefile.excerpt` showing the relevant build targets and their implementations
3. Add a note in `SKILL.md` explaining why `CONTAINER_ENGINE=podman` is required (rootless containers in RHEL/Fedora environments)

## Related PRD Sections

- Section 4: Detailed Skill Requirements (`ee-build-workflow` row)

## References

- `tosin2013/ansible-execution-environment`: https://github.com/tosin2013/ansible-execution-environment
- Podman documentation: https://docs.podman.io/
- ansible-builder documentation: https://ansible.readthedocs.io/projects/builder/
