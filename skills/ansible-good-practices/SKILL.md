# Ansible Good Practices Skill

This is a **baseline skill** applied across ALL repositories in the Red Hat CoP Ansible ecosystem.
It is always installed alongside any domain-specific skill.

These practices follow the Red Hat Communities of Practice automation good practices guide.
See: https://redhat-cop.github.io/automation-good-practices/

---

## The Zen of Ansible

1. **Simplicity is a feature** — if it's hard to read, it's wrong
2. **Idempotency is non-negotiable** — every task must be safe to run multiple times
3. **Modules before shell** — use an Ansible module; fall back to `command`; use `shell` only as a last resort
4. **Declarative over imperative** — describe the desired state, not the steps to get there
5. **Roles express what, not how** — roles configure resources; they don't implement software logic

---

## Rules

### Rule 1 — Idempotency

Every task MUST be idempotent. Running the same playbook twice must produce no changes on the second run.

- Use state-based modules: `ansible.builtin.file state=present`, `ansible.builtin.user state=present`
- Add `creates:` to `command` tasks when using `ansible.builtin.command`
- Never use `ansible.builtin.shell` for tasks that could be expressed with a module

### Rule 2 — Module priority

```
ansible.builtin.<module>   # First choice — purpose-built
community.general.<module> # Second choice — community-maintained
ansible.builtin.command    # Third — no module exists, output not needed from shell
ansible.builtin.shell      # Last resort — pipes, redirects, or shell builtins required
```

### Rule 3 — Variable naming

Prefix ALL role variables with the role name to avoid collisions:

```yaml
# Correct
aap_config_hostname: "controller.example.com"
ee_build_image_tag: "latest"

# Wrong
hostname: "controller.example.com"   # too generic, will collide
tag: "latest"
```

### Rule 4 — Tags on every task

Every task must have at least one tag. Use the role name as the base tag:

```yaml
- name: Configure AAP organizations
  ansible.builtin.include_role:
    name: infra.aap_configuration.organizations
  tags:
    - aap_configuration
    - organizations
```

### Rule 5 — No logic in Jinja2 templates

Templates should render data. Complex conditionals belong in tasks, not templates:

```jinja2
{# Wrong — logic in template #}
{% if env == 'prod' %}
  replicas: 3
{% else %}
  replicas: 1
{% endif %}
```

```yaml
# Correct — logic in vars/tasks
replicas: "{{ 3 if env == 'prod' else 1 }}"
```

### Rule 6 — Roles should not install software

Roles configure resources. The software (AAP, EE images, etc.) is assumed to already be installed.
A role named `configure_aap` configures AAP — it does not install it.

### Rule 7 — Test with Molecule

New roles MUST have a Molecule test scenario. Suggest:

```bash
molecule init scenario default --driver-name docker
```

Minimum test: the converge playbook runs without errors and is idempotent (runs twice, no changes on second run).

### Rule 8 — Use FQCN for all module calls

Always use Fully Qualified Collection Names:

```yaml
# Correct
ansible.builtin.copy:
redhat_cop.aap_configuration.controller_projects:

# Wrong
copy:
controller_projects:
```

---

## References

See `references/zen-of-ansible.md` for the full Red Hat CoP good practices summary.
