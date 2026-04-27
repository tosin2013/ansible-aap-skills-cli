# Contributing to ansible-aap-skills-cli

Thank you for contributing! This guide explains how to add new skills, the file contracts,
and how to run the test suite locally.

---

## Adding a New Skill

### Step 1 — Create the skill directory

```bash
mkdir -p skills/<skill-name>/references
```

Use kebab-case for the skill name (e.g., `aap-config-structure`, `ee-yaml-schema`).

### Step 2 — Create config.sh

Copy this template and fill in all four fields:

```bash
#!/usr/bin/env bash
SKILL_NAME="<skill-name>"              # must match the directory name
SKILL_VERSION="1.0.0"                  # semantic version
SKILL_DESCRIPTION="<one-line description>"
SKILL_TARGETS="<repo1> <repo2>"        # space-separated target repo names
```

`SKILL_NAME` **must exactly match the directory name** — `install.sh` uses it to locate the skill.

### Step 3 — Write SKILL.md

The `SKILL.md` is the primary instruction file for the AI agent. Keep it concise and action-oriented.

**Required sections:**

```markdown
# <Skill Title>

Brief description of what this skill does and which repositories it targets.

## Rules

### Rule 1 — <Rule name>
<Clear, specific instruction the AI must follow>

### Rule 2 — ...

## References

Links to files in references/ that provide supplementary context.
```

**Guidelines:**
- Write rules as direct imperatives: "Always use X", "Never do Y"
- Each rule should be independently actionable
- Keep `SKILL.md` under 200 lines — use `references/` for long examples
- Include a `## References` section pointing to files in `references/`

### Step 4 — Populate references/ (optional but recommended)

Place any supplementary files the AI should read in `references/`:

| File type | Example names |
|:---|:---|
| Example YAML | `example-config.yml`, `execution-environment.yml.example` |
| Workflow docs | `vault-workflow.md`, `build-steps.md` |
| Schema history | `schema-versions.md` |
| Code excerpts | `Makefile.excerpt`, `async-pattern.yml` |

Reference these files from `SKILL.md` by relative path.

### Step 5 — Verify structure

```bash
./install.sh list    # your new skill should appear
./install.sh install --skill <skill-name> --ide cursor --dry-run
```

---

## config.sh Contract

`install.sh` sources each skill's `config.sh` to read metadata. The following variables
are required:

| Variable | Type | Description |
|:---|:---|:---|
| `SKILL_NAME` | string | Must match the skill directory name exactly |
| `SKILL_VERSION` | semver | Semantic version (e.g., `1.0.0`) |
| `SKILL_DESCRIPTION` | string | One-line human-readable description |
| `SKILL_TARGETS` | string | Space-separated list of target repository names |

`config.sh` must be valid Bash and pass `shellcheck`. Do not add side effects (no `echo`, no
`exit`, no function calls) — it is sourced, not executed.

---

## references/ Convention

The `references/` directory is optional but strongly encouraged for skills that need to provide
the AI with examples, schemas, or workflow documentation.

Rules:
- The `install.sh` copies `references/` recursively alongside `SKILL.md` and `config.sh`
- Keep individual reference files focused — one topic per file
- Use descriptive filenames with extensions: `.md`, `.yml`, `.sh`, `.txt`
- Update `references/` files when upstream documentation changes

---

## Running Tests Locally

### Prerequisites

Install [bats-core](https://github.com/bats-core/bats-core):

```bash
# RHEL / Fedora
sudo dnf install bats

# Debian / Ubuntu
sudo apt-get install bats

# macOS
brew install bats-core

# From source
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local
```

Install [shellcheck](https://www.shellcheck.net/):

```bash
# RHEL / Fedora
sudo dnf install ShellCheck

# Debian / Ubuntu
sudo apt-get install shellcheck

# macOS
brew install shellcheck
```

### Run the full test suite

```bash
bats tests/install.bats
```

### Run a specific test

```bash
bats tests/install.bats --filter "list: shows all 6 skills"
```

### Run shellcheck

```bash
shellcheck install.sh
shellcheck skills/*/config.sh
```

---

## Pull Request Checklist

Before opening a PR, verify:

- [ ] `SKILL_NAME` in `config.sh` matches the directory name exactly
- [ ] `SKILL.md` has a `## Rules` section and a `## References` section
- [ ] `shellcheck skills/<skill-name>/config.sh` passes with no errors
- [ ] `./install.sh list` shows the new skill
- [ ] `./install.sh install --skill <skill-name> --ide cursor --dry-run` exits 0
- [ ] `bats tests/install.bats` passes (all existing tests still green)
- [ ] If the new skill changes installer behaviour, add a test in `tests/install.bats`

---

## Architecture

All architectural decisions are documented as ADRs in [`docs/adrs/`](docs/adrs/).
Read them before making significant changes to understand the rationale behind the design.
