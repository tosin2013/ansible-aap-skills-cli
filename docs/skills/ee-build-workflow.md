---
title: ee-build-workflow
layout: default
parent: Skills
nav_order: 5
---

# ee-build-workflow

**Target**: `tosin2013/ansible-execution-environment`  
**Version**: 1.0.0  
**ADR**: [ADR-008](../adrs/008-ee-build-toolchain)

## Purpose

Instructs AI agents to always use the repository's Makefile targets for building,
testing, and pushing Execution Environment images — never direct `ansible-builder`
or `docker build` invocations. Enforces `CONTAINER_ENGINE=podman` for RHEL/Fedora environments.

## Key Rules

| Rule | Description |
|:---|:---|
| Makefile only | Never call `ansible-builder` directly |
| Always podman | Pass `CONTAINER_ENGINE=podman` to every make target |
| No Docker | Never suggest `docker build` |

## Build Commands

```bash
# Build
CONTAINER_ENGINE=podman make build

# Test
CONTAINER_ENGINE=podman make test

# Push
CONTAINER_ENGINE=podman make push

# Clean and rebuild
CONTAINER_ENGINE=podman make clean
CONTAINER_ENGINE=podman make build
```

## Available Makefile Targets

| Target | Purpose |
|:---|:---|
| `make build` | Build the EE image |
| `make test` | Run sanity/integration tests |
| `make push` | Tag and push to registry |
| `make clean` | Remove build artifacts |
| `make all` | Build and test |

## Install

```bash
./install.sh install --skill ee-build-workflow
```

## Reference Files

- `Makefile.excerpt` — relevant Makefile targets from the upstream repository
