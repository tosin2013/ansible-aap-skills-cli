# Execution Environment Schema Version History

## Version 1 (deprecated)

- Dependencies were specified inline in `execution-environment.yml`
- No `images:` block — used implicit base image
- No `additional_build_steps:` fine-grained control

```yaml
# version 1 — DO NOT USE
version: 1
dependencies:
  galaxy: requirements.yml   # file reference (relative path)
  python: requirements.txt
  system: bindep.txt
```

## Version 2 (deprecated)

- Added `images:` block for explicit base image
- Still used relative paths without `files/` convention

```yaml
# version 2 — DO NOT USE
version: 2
images:
  base_image:
    name: quay.io/ansible/ansible-runner:latest
dependencies:
  galaxy: requirements.yml
  python: requirements.txt
```

## Version 3 (current — ALWAYS USE THIS)

- Explicit `files/` directory convention for all dependency files
- `build_arg_defaults:` for build-time ARGs
- Richer `additional_build_steps:` with named stages
- Full OCI compliance

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

## Migration: v2 → v3

1. Set `version: 3`
2. Move `requirements.yml` → `files/requirements.yml`
3. Move `requirements.txt` → `files/requirements.txt`
4. Move `bindep.txt` → `files/bindep.txt`
5. Update dependency paths in the manifest with `files/` prefix
6. Add explicit `images:` block if not already present
