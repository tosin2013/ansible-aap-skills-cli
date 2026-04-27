# AAP Configuration Template — Annotated Directory Layout

```
aap_configuration_template/
├── config/
│   ├── all/                          # GLOBAL — same in every environment
│   │   ├── organizations.yml         # AAP Organizations
│   │   ├── teams.yml                 # Teams within organizations
│   │   ├── users.yml                 # User accounts
│   │   ├── credential_types.yml      # Custom credential type definitions
│   │   ├── credentials.yml           # Credentials (vault-encrypted values)
│   │   ├── execution_environments.yml# EE image references
│   │   ├── projects.yml              # SCM-backed projects
│   │   ├── job_templates.yml         # Job template definitions
│   │   ├── workflow_job_templates.yml# Workflow templates
│   │   └── notification_templates.yml# Notification configs
│   ├── dev/                          # DEVELOPMENT overrides
│   │   ├── inventories.yml           # Dev inventory definitions
│   │   ├── inventory_sources.yml     # Dev inventory source configs
│   │   └── secrets.yml               # Vault-encrypted dev secrets
│   ├── qa/                           # QA overrides
│   │   ├── inventories.yml
│   │   ├── inventory_sources.yml
│   │   └── secrets.yml
│   └── prod/                         # PRODUCTION overrides
│       ├── inventories.yml
│       ├── inventory_sources.yml
│       └── secrets.yml
├── group_vars/
│   └── all.yml                       # Ansible vars shared by all playbooks
└── playbooks/
    └── configure_aap.yml             # Entry-point playbook
```

## Key Decisions

| What | Where | Why |
|:---|:---|:---|
| Organizations, teams, users | `config/all/` | Same in all envs |
| Credential types | `config/all/` | Schema is global |
| Credential values | `config/all/credentials.yml` with vault strings | Values are encrypted |
| Inventories | `config/<env>/inventories.yml` | Hosts differ per env |
| Secrets | `config/<env>/secrets.yml` | Values differ per env |
