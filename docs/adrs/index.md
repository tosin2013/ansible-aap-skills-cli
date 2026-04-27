---
title: Architecture Decisions
layout: default
nav_order: 4
has_children: true
---

# Architecture Decision Records

All architectural decisions for `ansible-aap-skills-cli` are documented here using the
[Nygard ADR format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

ADRs capture the context, decision, and consequences of each significant choice — providing
a permanent record of *why* the project is built the way it is.

---

## ADR Index

| # | Title | Status | Domain |
|:---|:---|:---|:---|
| [ADR-001](001-skill-format-standard) | Skill Format Standard | Accepted | AI Agent Integration |
| [ADR-002](002-target-ai-assistants) | Target AI Assistants | Accepted | AI Agent Integration |
| [ADR-003](003-documentation-embedding-via-references) | Documentation Embedding via References | Accepted | Knowledge Management |
| [ADR-004](004-shell-based-cli-installer) | Shell-Based CLI Installer | Accepted | Distribution |
| [ADR-005](005-repository-structure) | Repository Structure | Accepted | Project Organization |
| [ADR-006](006-secrets-management) | Secrets Management | Accepted | Security |
| [ADR-007](007-execution-environment-yaml-schema) | EE YAML Schema Version | Accepted | Build Toolchain |
| [ADR-008](008-ee-build-toolchain) | EE Build Toolchain | Accepted | Build Toolchain |
| [ADR-009](009-ansible-good-practices) | Ansible Good Practices Baseline | Accepted | Engineering Standards |
| [ADR-010](010-github-pages-documentation) | GitHub Pages Documentation Site | Accepted | Documentation |
| [ADR-011](011-research-reference-maintenance) | Research and Reference Maintenance | Accepted | Knowledge Management |

---

## About ADRs

Each ADR follows this structure:

- **Context** — the problem or situation that required a decision
- **Decision** — what was decided and why
- **Consequences** — positive and negative outcomes of the decision
- **Implementation Plan** — concrete steps to realise the decision
