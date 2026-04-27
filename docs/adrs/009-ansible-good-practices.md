---
title: "ADR-009: Ansible Good Practices"
layout: default
parent: Architecture Decisions
nav_order: 9
---

# 9. Ansible Good Practices Baseline

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Ansible Engineering Standards

## Context

The Red Hat Communities of Practice publishes an authoritative set of Ansible good practices at https://redhat-cop.github.io/automation-good-practices/. These practices apply across all repositories in the target ecosystem and should inform AI suggestions regardless of which specific skill is active.

Without an explicit good-practices skill, AI agents may generate Ansible code that is functionally correct but violates community conventions (e.g., embedding logic in roles that should be in playbooks, using `shell` module where `command` suffices, ignoring idempotency).

## Decision

A dedicated **`ansible-good-practices` skill** will be created and applied to **all target repositories** as a baseline layer. This skill encodes the "Zen of Ansible" and Red Hat CoP role design considerations.

Key principles encoded in the skill:

1. **Focus on functionality, not software implementation** — roles should express *what* to configure, not *how* the underlying software works
2. **Idempotency is non-negotiable** — all tasks must be safe to run multiple times without side effects
3. **Use purpose-built modules first** — prefer Ansible modules over `shell`/`command`; use `shell` only when no module exists
4. **Variable naming conventions** — prefix role variables with the role name (e.g., `aap_config_hostname`)
5. **No logic in templates** — Jinja2 templates should render data, not contain conditionals beyond simple variable substitution
6. **Tags on every task** — tasks must have meaningful tags for selective execution
7. **Molecule for testing** — suggest Molecule scenarios for new roles

## Consequences

**Positive:**
- AI-generated Ansible code is immediately aligned with CoP community standards
- Reduces review cycles caused by style/convention violations
- Cross-cutting skill means practices are applied consistently regardless of which domain skill is active

**Negative:**
- The good-practices skill may conflict with legacy patterns in older CoP repositories; exceptions must be documented
- Keeping the skill current requires monitoring the upstream good-practices site for updates

## Implementation Plan

1. Write `skills/ansible-good-practices/SKILL.md` with the principles above
2. Add `references/zen-of-ansible.md` — an excerpt/summary of the Red Hat CoP automation good practices guide
3. Instruct `install.sh` to always install `ansible-good-practices` alongside any other skill (`--all` installs it by default; individual installs also pull it in)
4. Periodically review the upstream good-practices guide and update the skill

## Related PRD Sections

- Section 4: Detailed Skill Requirements (`ansible-good-practices` row)
- Section 3.3: Governance & Workflows

## References

- Red Hat CoP Automation Good Practices: https://redhat-cop.github.io/automation-good-practices/
- `redhat-cop/automation-good-practices`: https://github.com/redhat-cop/automation-good-practices
- `redhat-cop/infra.ansible_validated_workflows`: https://github.com/redhat-cop/infra.ansible_validated_workflows
