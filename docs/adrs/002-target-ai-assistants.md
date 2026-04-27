# 2. Target AI Assistants

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: AI Agent Integration

## Context

Two AI coding assistants are in active use within the target engineering community: **Claude Code** and **Cursor IDE**. Each platform loads agent skills from a different filesystem path:

- Claude Code reads skills from `~/.claude/skills/`
- Cursor IDE reads skills from `~/.cursor/skills/`

The installer must handle both platforms without requiring users to understand the internal path differences, while also supporting environments where only one platform is installed.

## Decision

The CLI installer (`install.sh`) will **support both Claude Code and Cursor IDE** as first-class targets with the following behaviour:

1. **Auto-detection**: On invocation, `install.sh` probes for both platforms and installs to all detected paths.
2. **Explicit targeting**: Users may pass `--ide claude` or `--ide cursor` to restrict installation to a single platform.
3. **Installation paths**:
   - Claude Code → `~/.claude/skills/<skill-name>/`
   - Cursor IDE → `~/.cursor/skills/<skill-name>/`

## Consequences

**Positive:**
- Zero-configuration experience for users who have both platforms installed
- Explicit targeting flag provides flexibility for CI or single-platform environments
- Mirrors the proven approach from `rhel-devops-skills-cli`

**Negative:**
- Two installation targets doubles the surface area for path-related bugs
- Future platforms require additions to the detection logic in `install.sh`

## Implementation Plan

1. In `install.sh`, implement `detect_ides()` that checks for `~/.claude/` and `~/.cursor/`
2. Implement `install_skill()` with a loop over detected (or specified) IDE paths
3. Add `--ide` flag parsing to the CLI argument handler
4. Document supported platforms in `README.md`

## Related PRD Sections

- Section 2.1: Supported AI Assistants (ADR-002)
- Section 6 Phase 1: CLI Scaffolding

## References

- Claude Code skill directory convention: `~/.claude/skills/`
- Cursor IDE skill directory convention: `~/.cursor/skills/`
- `tosin2013/rhel-devops-skills-cli` — reference implementation of dual-platform detection
