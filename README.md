# ansible-aap-skills-cli

A CLI installer that delivers AI agent skills for the **Red Hat Communities of Practice Ansible AAP ecosystem**. Skills use the [`SKILL.md`](https://github.com/tosin2013/rhel-devops-skills-cli) open standard and work with both **Claude Code** and **Cursor IDE**.

---

## Quick Start

```bash
git clone https://github.com/tosin2013/ansible-aap-skills-cli.git
cd ansible-aap-skills-cli
./install.sh install
```

The installer auto-detects Claude Code (`~/.claude/`) and Cursor IDE (`~/.cursor/`) and installs all skills to both.

---

## Requirements

- Bash 4.0+
- Claude Code and/or Cursor IDE installed

---

## Available Skills

| Skill | Target Repositories | Description |
|:---|:---|:---|
| `aap-config-structure` | `aap_configuration_template` | Enforces `config/all/` vs `config/<env>/` directory structure |
| `aap-secrets-management` | `aap_configuration_template` | Requires `ansible-vault encrypt_string`; forbids plaintext secrets |
| `aap-infra-roles` | `infra.aap_configuration` | Async task pattern and variable naming conventions |
| `ee-yaml-schema` | `ansible-execution-environment`, `ee_utilities` | Enforces `version: 3` EE manifest schema |
| `ee-build-workflow` | `ansible-execution-environment` | Makefile targets with `CONTAINER_ENGINE=podman` |
| `ansible-navigator` | `ansible-execution-environment`, `aap_configuration_template` | `ansible-navigator.yml` config + EE smoke test after build |
| `ansible-good-practices` | All repositories | Red Hat CoP Zen of Ansible baseline (always installed) |
| `aap-live-validation` | `aap_configuration_template`, `infra.aap_configuration` | Platform-aware validation sequence for live AAP servers (OpenShift + standalone) |
| `eda-configuration` | `eda_configuration` | Rulebook structure, activation ordering, decision environment selection |
| `aap-utilities` | `aap_utilities`, `aap_configuration_template` | Operational helper roles: ping, export, bulk-tag, token management |
| `ansible-validated-workflows` | `infra.ansible_validated_workflows` | Pre-built workflows for patching, provisioning, compliance, cert rotation |
| `skill-research` *(contributor, opt-in)* | `ansible-aap-skills-cli` | Meta-skill for maintaining reference files and filing upstream issues |

---

## Commands

### `install`

Copy skills to all detected IDEs (or a specific one):

```bash
./install.sh install                                    # all skills, all IDEs
./install.sh install --skill aap-config-structure       # one skill, all IDEs
./install.sh install --ide cursor                       # all skills, Cursor only
./install.sh install --skill ee-yaml-schema --ide claude
./install.sh install --dry-run                          # preview without writing
```

### `update`

Re-copy skills, overwriting existing installations:

```bash
./install.sh update
./install.sh update --skill aap-infra-roles
```

### `verify`

Check that installed skills are present and intact:

```bash
./install.sh verify
./install.sh verify --skill ansible-good-practices --ide cursor
```

Exits `0` if all checks pass, `1` if any skill is missing or invalid.

### `list`

Print all available skills and their installation status:

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
...
```

---

## Installation Paths

| IDE | Skills path |
|:---|:---|
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Cursor IDE | `~/.cursor/skills/<skill-name>/` |

---

## Project Structure

```
ansible-aap-skills-cli/
├── install.sh                     # CLI installer
├── docs/
│   └── adrs/                      # Architecture Decision Records (ADR-001..016)
├── tests/
│   └── install.bats               # bats test suite
└── skills/
    ├── aap-config-structure/
    │   ├── SKILL.md
    │   ├── config.sh
    │   └── references/
    ├── aap-secrets-management/
    ├── aap-infra-roles/
    ├── ee-yaml-schema/
    ├── ee-build-workflow/
    ├── ansible-navigator/
    ├── ansible-good-practices/
    ├── aap-live-validation/
    ├── eda-configuration/
    ├── aap-utilities/
    ├── ansible-validated-workflows/
    └── skill-research/
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidance on adding new skills.

---

## Architecture Decisions

All architectural decisions are documented as ADRs in [`docs/adrs/`](docs/adrs/):

- [ADR-001](docs/adrs/001-skill-format-standard.md) — Skill Format Standard (SKILL.md)
- [ADR-002](docs/adrs/002-target-ai-assistants.md) — Target AI Assistants
- [ADR-003](docs/adrs/003-documentation-embedding-via-references.md) — Documentation via `references/`
- [ADR-004](docs/adrs/004-shell-based-cli-installer.md) — Shell-Based CLI Installer
- [ADR-005](docs/adrs/005-repository-structure.md) — Repository Structure
- [ADR-006](docs/adrs/006-secrets-management.md) — Secrets Management
- [ADR-007](docs/adrs/007-execution-environment-yaml-schema.md) — EE YAML Schema v3
- [ADR-008](docs/adrs/008-ee-build-toolchain.md) — EE Build Toolchain
- [ADR-009](docs/adrs/009-ansible-good-practices.md) — Ansible Good Practices
- [ADR-010](docs/adrs/010-github-pages-documentation.md) — GitHub Pages Documentation
- [ADR-011](docs/adrs/011-research-reference-maintenance.md) — Research and Reference Maintenance
- [ADR-012](docs/adrs/012-aap-live-validation-skill.md) — AAP Live Validation Skill
- [ADR-013](docs/adrs/013-ansible-navigator-skill.md) — ansible-navigator Skill
- [ADR-014](docs/adrs/014-eda-configuration-skill.md) — EDA Configuration Skill
- [ADR-015](docs/adrs/015-aap-utilities-skill.md) — AAP Utilities Skill
- [ADR-016](docs/adrs/016-ansible-validated-workflows-skill.md) — Ansible Validated Workflows Skill

---

## References

- [Red Hat CoP AAP Config as Code](https://redhat-cop.github.io/aap_config_as_code_docs/)
- [Red Hat CoP Automation Good Practices](https://redhat-cop.github.io/automation-good-practices/)
- [ansible-execution-environment](https://github.com/tosin2013/ansible-execution-environment)
- [rhel-devops-skills-cli](https://github.com/tosin2013/rhel-devops-skills-cli) — reference architecture
