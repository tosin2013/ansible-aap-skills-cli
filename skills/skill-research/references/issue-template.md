<!-- Last updated: 2026-04-27 from tosin2013/ansible-aap-skills-cli -->

# Upstream Issue Filing Template

Use this when a problem is found in an upstream repository during a staleness audit
or while populating a `references/` file.

---

## Pre-Flight Checklist (complete before drafting)

- [ ] Identify the correct upstream repo from `sources-catalog.md` ("Upstream Repo for Issues" column)
- [ ] Classify the issue type: Documentation bug | Schema/API change | Missing documentation
- [ ] Check for existing issues:
  ```bash
  gh issue list --repo <owner/repo> --state open --search "<keywords>"
  ```
- [ ] If a duplicate exists, link to it rather than filing a new issue
- [ ] Confirm the user wants to proceed with filing

---

## Issue Title Format

```
[<skill-name>] <concise problem summary>
```

Examples:
- `[ee-yaml-schema] version: 3 schema docs missing additional_build_steps.prepend_galaxy`
- `[aap-infra-roles] collect_async_status role variable name changed in v2.5.0`
- `[ansible-good-practices] Zen of Ansible page returns 404`

---

## Issue Body Template

```markdown
## Problem Description

<What is wrong? Be specific. Include the skill name and which reference file led to discovering this.>

## Expected Behaviour

<What should the upstream docs/code say or do?>

## Actual Behaviour

<What do the upstream docs/code currently say or do?>

## Affected Skill / Reference File

- Skill: `<skill-name>`
- Reference file: `skills/<skill-name>/references/<filename>`
- Upstream source: <URL>

## Suggested Fix

<Optional: what change in the upstream repo would resolve this?>

## Context

Discovered while maintaining the [ansible-aap-skills-cli](https://github.com/tosin2013/ansible-aap-skills-cli)
AI agent skills repository, which vendors excerpts from this repository to provide
domain-specific context to Claude Code and Cursor IDE.
```

---

## Label Mapping

| Issue Type | Label to use |
|:---|:---|
| Documentation bug | `documentation`, `bug` |
| Schema/API change | `breaking-change`, `documentation` |
| Missing documentation | `documentation`, `enhancement` |

Note: not all upstream repos use the same label names. Check available labels first:
```bash
gh label list --repo <owner/repo>
```

Use only labels that exist in the target repo. If none match, omit `--label`.

---

## Filing the Issue

After the user confirms the draft, run:

```bash
gh issue create \
  --repo <owner/repo> \
  --title "[<skill-name>] <problem summary>" \
  --body "$(cat <<'EOF'
## Problem Description
...

## Expected Behaviour
...

## Actual Behaviour
...

## Affected Skill / Reference File
- Skill: `<skill-name>`
- Reference file: `skills/<skill-name>/references/<filename>`
- Upstream source: <URL>

## Suggested Fix
...

## Context
Discovered while maintaining ansible-aap-skills-cli AI agent skills.
EOF
)" \
  --label "documentation"
```

Share the returned issue URL with the user.

---

## Post-Filing Actions

After the issue is filed:

1. Note the issue URL in the affected reference file as a comment:
   ```
   <!-- Upstream issue: https://github.com/<owner>/<repo>/issues/<number> -->
   ```
2. If the reference file contains incorrect content, mark it with a warning comment
   at the top until the upstream issue is resolved:
   ```
   <!-- WARNING: upstream issue filed — content may be inaccurate: <issue-url> -->
   ```

Source: tosin2013/ansible-aap-skills-cli
