# 1. Skill Format Standard

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: AI Agent Integration

## Context

The `ansible-aap-skills-cli` repository delivers domain-specific context to AI coding assistants (Claude Code and Cursor IDE). A portable, human-readable, and tooling-agnostic format is needed so that skills can be read, maintained, and extended without coupling to any single AI platform's proprietary format.

The `rhel-devops-skills-cli` reference architecture established the `SKILL.md` open standard as its skill format, demonstrating viability across Claude Code and Cursor IDE environments.

## Decision

All skills in this repository will use the **`SKILL.md` open standard** as the canonical format for expressing agent skill instructions.

Each skill is expressed as a single Markdown file named `SKILL.md`, containing:
- A brief description of the skill's purpose
- Specific instructions the AI agent must follow
- Context about the target repository/ecosystem

## Consequences

**Positive:**
- Skills are human-readable and version-controllable in plain text
- Compatible with both Claude Code and Cursor IDE without format translation
- Low barrier to contribution — any editor can modify a Markdown file
- Future AI platforms can adopt the same standard without restructuring

**Negative:**
- The standard is informal; there is no schema validation or linting toolchain
- Large skills may become verbose; contributors must self-discipline on scope

## Implementation Plan

1. Create a `SKILL.md` at the root of each skill directory (e.g., `skills/aap-config-structure/SKILL.md`)
2. Use a consistent heading structure: purpose, key rules, examples
3. Enforce this format in code review; the `install.sh verify` command will check for `SKILL.md` presence

## Related PRD Sections

- Section 2.2: Skill Format (ADR-001)
- Section 5: File Structure

## References

- `tosin2013/rhel-devops-skills-cli` — reference implementation
- SKILL.md open standard conventions
