# Execution Environment YAML Schema Skill

You are assisting engineers working in `tosin2013/ansible-execution-environment`
or `redhat-cop/ee_utilities`.

## CRITICAL: Always Use Schema Version 3

Every `execution-environment.yml` file MUST begin with `version: 3`.
Do NOT generate version 1 or version 2 manifests — they are incompatible with
the `ansible-builder` version used in these repositories.

## Rules

### Rule 1 — Set version: 3

```yaml
version: 3
```

This is the first line of every `execution-environment.yml`. Never omit it.

### Rule 2 — Do NOT inline dependency lists

Version 1/2 allowed inlining requirements directly in the manifest. Version 3 does NOT.
Always reference external files:

```yaml
# CORRECT (version 3)
dependencies:
  galaxy: files/requirements.yml
  python: files/requirements.txt
  system: files/bindep.txt

# WRONG — do not do this
dependencies:
  galaxy:
    collections:
      - name: ansible.posix   # <-- inline, version 1/2 style
```

### Rule 3 — Place all dependency files in files/

| Dependency type | File path |
|:---|:---|
| Ansible collections | `files/requirements.yml` |
| Python packages | `files/requirements.txt` |
| System packages (RPM/deb) | `files/bindep.txt` |

When asked to add a collection, update `files/requirements.yml`.
When asked to add a Python library, update `files/requirements.txt`.
When asked to add a system package, update `files/bindep.txt`.

### Rule 4 — Use additional_build_steps for custom steps

```yaml
additional_build_steps:
  prepend_galaxy:
    - RUN pip3 install --upgrade pip
  append_final:
    - RUN ansible-galaxy collection list
```

Do NOT use inline shell commands or hack the base image outside this block.

### Rule 5 — Minimal compliant manifest skeleton

```yaml
version: 3
build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--pre'

images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform/ee-minimal-rhel9:latest

dependencies:
  galaxy: files/requirements.yml
  python: files/requirements.txt
  system: files/bindep.txt
```

## References

See `references/execution-environment.yml.example` for a complete valid v3 manifest.
See `references/requirements.yml.example` for a sample collections requirements file.
See `references/schema-versions.md` for the v1 → v2 → v3 migration history.
