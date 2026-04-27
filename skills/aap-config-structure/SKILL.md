# AAP Configuration Structure Skill

You are assisting engineers working in the `redhat-cop/aap_configuration_template` repository.
This repository implements **Ansible Automation Platform configuration as code**.

## Directory Structure Rules

The repository MUST follow this two-tier directory convention:

```
config/
├── all/           # Global settings applied to every environment
│   ├── credentials.yml
│   ├── organizations.yml
│   ├── teams.yml
│   └── ...
├── dev/           # Dev-environment overrides
│   ├── inventories.yml
│   └── secrets.yml
├── qa/            # QA-environment overrides
│   ├── inventories.yml
│   └── secrets.yml
└── prod/          # Production-environment overrides
    ├── inventories.yml
    └── secrets.yml
```

### Rule 1 — Global settings go in `config/all/`

Any resource that is the same across all environments (organizations, teams, credential types,
notification templates, execution environments) MUST be defined in `config/all/`.

Do NOT duplicate these definitions in per-environment directories.

### Rule 2 — Environment-specific overrides go in `config/<env>/`

Inventories, inventory sources, hosts, and any resource whose values differ between
dev/qa/prod MUST be in the appropriate `config/<env>/` subdirectory.

### Rule 3 — Never mix scopes

Do NOT place environment-specific values in `config/all/` files.
Do NOT place globally constant resources in `config/<env>/` files.

### Rule 4 — File naming

Each resource type has its own file. Use the plural resource name as the filename:
- `credentials.yml`, `organizations.yml`, `job_templates.yml`, `projects.yml`
- Never pack multiple resource types into a single file.

### Rule 5 — Variable loading order

The `aap_configuration_template` loader reads `config/all/` first, then overlays
`config/<env>/` on top. Environment files WIN over global files when keys collide.

## References

See `references/directory-layout.md` for a fully annotated example tree.
See `references/example-vars.yml` for a sample of correct global vs env-scoped variable structure.
