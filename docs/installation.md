---
title: Installation
layout: default
nav_order: 2
---

# Installation & CLI Reference

## Prerequisites

- Bash 4.0+
- Claude Code and/or Cursor IDE installed on your machine

## Clone the Repository

```bash
git clone https://github.com/tosin2013/ansible-aap-skills-cli.git
cd ansible-aap-skills-cli
```

---

## Commands

### `install`

Copy skills to all detected IDEs, or target a specific skill or IDE.

```bash
# Install all skills to all detected IDEs
./install.sh install

# Install a specific skill
./install.sh install --skill aap-config-structure

# Install to a specific IDE only
./install.sh install --ide cursor
./install.sh install --ide claude

# Combine — one skill, one IDE
./install.sh install --skill ee-yaml-schema --ide cursor

# Preview without writing any files
./install.sh install --dry-run
./install.sh install --skill aap-infra-roles --ide claude --dry-run
```

The `ansible-good-practices` baseline skill is **always installed** alongside any other skill.

---

### `update`

Re-copy skills, overwriting existing installations to pick up upstream changes.

```bash
# Update all skills
./install.sh update

# Update a specific skill
./install.sh update --skill ee-build-workflow

# Update for a specific IDE
./install.sh update --ide cursor
```

---

### `verify`

Check that installed skills are present and intact (SKILL.md exists in the target path).

```bash
# Verify all skills across all detected IDEs
./install.sh verify

# Verify a specific skill
./install.sh verify --skill aap-config-structure --ide cursor
```

Exits `0` if all checks pass, `1` if any skill is missing or invalid.

---

### `list`

Print all available skills and their current installation status.

```bash
./install.sh list
```

Example output:

```
SKILL                          VERSION    IDE        STATUS
-----                          -------    ---        ------
aap-config-structure           1.0.0      claude     installed
aap-config-structure           1.0.0      cursor     not installed
aap-secrets-management         1.0.0      claude     installed
aap-secrets-management         1.0.0      cursor     not installed
...
```

---

## Installation Paths

| IDE | Skills installed to |
|:---|:---|
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Cursor IDE | `~/.cursor/skills/<skill-name>/` |

---

## Flags Reference

| Flag | Values | Default | Description |
|:---|:---|:---|:---|
| `--skill` | skill name | `all` | Target a specific skill |
| `--ide` | `claude`, `cursor`, `all` | `all` | Target a specific IDE |
| `--dry-run` | — | off | Preview actions without writing files |
| `--help` | — | — | Print usage |

---

## Local Preview (optional)

To preview the documentation site locally:

```bash
cd docs
gem install bundler
bundle install
bundle exec jekyll serve
```

Then open `http://localhost:4000/ansible-aap-skills-cli`.
