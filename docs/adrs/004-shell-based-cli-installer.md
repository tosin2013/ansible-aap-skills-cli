# 4. Shell-Based CLI Installer

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Distribution / Developer Experience

## Context

Skills need to be distributed to end-user machines with minimal friction. Options considered:

1. **Manual copy** — users clone the repo and copy files themselves
2. **Package manager** (e.g., pip, npm, Homebrew) — requires packaging infrastructure and platform-specific maintenance
3. **Bash script installer** — a single `install.sh` that handles copy, update, verification, and listing

The target audience (Ansible/Red Hat CoP engineers) is comfortable with shell scripting and `curl | bash` style installers. The reference project `rhel-devops-skills-cli` validated this approach successfully.

## Decision

The primary delivery mechanism will be a **Bash script (`install.sh`)** that supports the following sub-commands:

| Command | Description |
|---|---|
| `install` | Copy one or all skills to the target IDE path(s) |
| `update` | Re-copy skills to pick up upstream changes |
| `verify` | Check that installed skills match the source (checksum or presence check) |
| `list` | Print all available skills and their installation status |

The script will accept:
- `--skill <name>` — target a specific skill
- `--ide <claude\|cursor\|all>` — target a specific platform (default: `all`)
- `--dry-run` — preview actions without making changes

## Consequences

**Positive:**
- Zero runtime dependencies beyond Bash and coreutils
- Works in any POSIX environment (Linux, macOS, WSL)
- Simple mental model: one script, a few sub-commands
- Easy to test with Bash testing frameworks (e.g., bats)

**Negative:**
- Windows native (non-WSL) users are not supported
- Script complexity grows as features are added; requires disciplined modularization
- No dependency resolution — skills are self-contained by design

## Implementation Plan

1. Port the `install.sh` framework from `rhel-devops-skills-cli`
2. Refactor for Ansible-specific skill paths and naming conventions
3. Implement `detect_ides()`, `install_skill()`, `update_skill()`, `verify_skill()`, `list_skills()` as discrete functions
4. Add a `--help` flag with usage examples
5. Write bats tests covering each sub-command in `tests/`

## Related PRD Sections

- Section 2.3: Shell Installer (ADR-006)
- Section 4: Detailed Skill Requirements (install by `--skill <name>`)
- Section 6 Phase 1: CLI Scaffolding

## References

- `tosin2013/rhel-devops-skills-cli` — `install.sh` reference implementation
- bats-core: Bash Automated Testing System — https://github.com/bats-core/bats-core
