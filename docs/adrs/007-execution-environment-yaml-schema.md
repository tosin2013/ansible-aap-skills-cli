# 7. Execution Environment YAML Schema Version

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Ansible Execution Environment / Build Toolchain

## Context

Ansible Execution Environments (EEs) are container images built with `ansible-builder`. The `execution-environment.yml` manifest has had multiple schema versions (1, 2, 3). The `tosin2013/ansible-execution-environment` repository targets **version 3**, which introduced significant structural changes including the separation of dependency files from the manifest itself.

AI agents that suggest outdated schema syntax (v1/v2 inline `requirements`) will produce incompatible manifests.

## Decision

The `ee-yaml-schema` skill will instruct AI agents to **always use `version: 3`** schema for `execution-environment.yml` and to follow these rules:

1. Set `version: 3` at the top of every `execution-environment.yml`
2. **Do not** inline Python requirements — reference `files/requirements.txt` instead
3. **Do not** inline system package requirements — reference `files/bindep.txt` instead
4. **Do not** inline Ansible collection requirements — reference `files/requirements.yml` instead
5. Use the `additional_build_steps` block for custom RUN steps (not inline shell hacks)

Example compliant manifest skeleton:
```yaml
version: 3
build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--pre'
dependencies:
  galaxy: files/requirements.yml
  python: files/requirements.txt
  system: files/bindep.txt
```

## Consequences

**Positive:**
- Generated manifests are compatible with the target repository's `ansible-builder` version
- Dependency files remain independently editable without touching the manifest
- AI is less likely to produce deprecated inline dependency syntax

**Negative:**
- If the target repository ever pins to v1/v2, this ADR must be revisited
- Agents must be aware of `files/` path conventions; mismatch causes build failures

## Implementation Plan

1. Write `skills/ee-yaml-schema/SKILL.md` encoding the rules above
2. Add `references/execution-environment.yml.example` — a valid v3 manifest
3. Add `references/requirements.yml.example` — a sample collection requirements file
4. Document the schema version history in `references/schema-versions.md` for agent context

## Related PRD Sections

- Section 4: Detailed Skill Requirements (`ee-yaml-schema` row)

## References

- ansible-builder EE definition schema: https://ansible.readthedocs.io/projects/builder/en/latest/definition/
- `tosin2013/ansible-execution-environment`: https://github.com/tosin2013/ansible-execution-environment
- `redhat-cop/ee_utilities`: https://github.com/redhat-cop/ee_utilities
