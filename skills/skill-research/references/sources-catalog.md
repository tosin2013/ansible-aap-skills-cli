<!-- Last updated: 2026-04-27 from tosin2013/ansible-aap-skills-cli -->

# Sources Catalog

This file is the single source of truth for upstream URLs used when populating
or updating `references/` directories. Always consult this file before fetching
any upstream content.

---

## Skill → Upstream Source Mapping

| Skill | Upstream Source URL | Key Files / Sections | Upstream Repo for Issues |
|:---|:---|:---|:---|
| `aap-config-structure` | https://github.com/redhat-cop/aap_configuration_template | `README.md`, `config/` directory tree | `redhat-cop/aap_configuration_template` |
| `aap-secrets-management` | https://github.com/redhat-cop/aap_configuration_template | `README.md` secrets section | `redhat-cop/aap_configuration_template` |
| `aap-secrets-management` (vault) | https://docs.ansible.com/ansible/latest/vault_guide/ | Vault guide, `encrypt_string` section | N/A (official Ansible docs) |
| `aap-infra-roles` | https://github.com/redhat-cop/infra.aap_configuration | `README.md`, role task structure, `collect_async_status` | `redhat-cop/infra.aap_configuration` |
| `ee-yaml-schema` | https://ansible.readthedocs.io/projects/builder/en/latest/definition/ | EE definition reference, v3 schema | `ansible/ansible-builder` |
| `ee-build-workflow` | https://github.com/tosin2013/ansible-execution-environment | `Makefile`, `README.md` | `tosin2013/ansible-execution-environment` |
| `ansible-good-practices` | https://redhat-cop.github.io/automation-good-practices/ | Full guide | `redhat-cop/automation-good-practices` |
| `ansible-navigator` | https://ansible.readthedocs.io/projects/navigator/ | Settings reference, subcommands (run, collections, exec) | `ansible/ansible-navigator` |
| `ansible-navigator` (settings) | https://ansible.readthedocs.io/projects/navigator/settings/ | Full `ansible-navigator.yml` key reference | `ansible/ansible-navigator` |
| `aap-live-validation` | https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html | REST API reference, `/api/v2/ping/`, token endpoints | N/A (official docs) |
| `aap-live-validation` (navigator) | https://ansible.readthedocs.io/projects/navigator/ | `ansible-navigator run` flags, `--check`, `--mode stdout` | `ansible/ansible-navigator` |
| `aap-live-validation` (awx collection) | https://github.com/ansible/awx/tree/devel/awx_collection | `awx.awx.controller_meta`, `awx.awx.token` modules | `ansible/awx` |
| `aap-live-validation` (OCP operator) | https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform | AAP Operator on OpenShift, route/secret layout | N/A (Red Hat docs) |
| `skill-research` (this repo) | https://github.com/tosin2013/ansible-aap-skills-cli | `skills/`, `docs/adrs/` | `tosin2013/ansible-aap-skills-cli` |

---

## Secondary / Supporting Sources

These are referenced by multiple skills or provide supporting context:

| Source | URL | Used By |
|:---|:---|:---|
| Red Hat CoP AAP Config as Code docs | https://redhat-cop.github.io/aap_config_as_code_docs/ | `aap-config-structure`, `aap-infra-roles` |
| Ansible Automation Platform docs | https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/ | All AAP skills |
| ansible-builder changelog | https://github.com/ansible/ansible-builder/blob/devel/CHANGELOG.rst | `ee-yaml-schema` |
| ee_utilities collection | https://github.com/redhat-cop/ee_utilities | `ee-yaml-schema` |
| infra.ansible_validated_workflows | https://github.com/redhat-cop/infra.ansible_validated_workflows | `ansible-good-practices` |

---

## How to Use This Catalog

1. Identify which skill's `references/` you are updating
2. Find the skill row above
3. Use the **Upstream Source URL** to fetch content — not a web search result
4. Use the **Upstream Repo for Issues** column when filing a GitHub issue
5. After updating a reference file, add/update the `<!-- Last updated: YYYY-MM-DD from <url> -->` comment

Source: tosin2013/ansible-aap-skills-cli
