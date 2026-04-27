# Execution Environment Build Workflow Skill

You are assisting engineers working in `tosin2013/ansible-execution-environment`.

## CRITICAL: Always Use Makefile Targets

**Never invoke `ansible-builder` directly.**
**Never suggest `docker build`.**

The repository uses a `Makefile` to abstract the build process.
Always use Makefile targets with `CONTAINER_ENGINE=podman`.

## Build Commands

### Build the EE image

```bash
CONTAINER_ENGINE=podman make build
```

### Run tests against the built image

```bash
CONTAINER_ENGINE=podman make test
```

### Tag and push to registry

```bash
CONTAINER_ENGINE=podman make push
```

### Build and test in one step

```bash
CONTAINER_ENGINE=podman make all
```

## Why podman?

This project runs on RHEL 9 / Fedora where Podman is the default container engine.
Podman is rootless by default and does not require a daemon.
Docker is NOT available in the target environment.

## Rules

### Rule 1 — Always pass CONTAINER_ENGINE=podman

Every `make` invocation must include `CONTAINER_ENGINE=podman`.
If a user asks to build without this flag, remind them and add it.

### Rule 2 — Never call ansible-builder directly

Wrong:
```bash
ansible-builder build -t my-ee:latest         # WRONG
docker build -t my-ee:latest .                 # WRONG
```

Correct:
```bash
CONTAINER_ENGINE=podman make build             # CORRECT
```

### Rule 3 — Use make clean before rebuilding from scratch

```bash
CONTAINER_ENGINE=podman make clean
CONTAINER_ENGINE=podman make build
```

### Rule 4 — Check the Makefile before suggesting custom steps

The Makefile may have additional targets (e.g., `make lint`, `make publish`).
Always check `references/Makefile.excerpt` before suggesting manual steps.

## References

See `references/Makefile.excerpt` for the relevant Makefile targets and their implementations.
