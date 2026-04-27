# ansible-navigator Skill

You are assisting engineers who use `ansible-navigator` to run playbooks and to
smoke-test Execution Environment (EE) images after a build.

This skill covers **two distinct use cases**:

1. **Configuration** — setting up `ansible-navigator.yml` correctly so that the right
   EE image, execution mode, and logging settings are applied across the project.
2. **EE smoke testing** — after `ee-build-workflow` produces a new image, using
   `ansible-navigator` to verify the image works before it is pushed to a registry.

For building EE images, see the `ee-build-workflow` skill.
For EE manifest schema, see the `ee-yaml-schema` skill.
For running against a live AAP server, see the `aap-live-validation` skill.

---

## Rules

### Rule 1 — Always configure via ansible-navigator.yml, not CLI flags alone

Project-level settings belong in `ansible-navigator.yml` (or `.ansible-navigator.yml`)
at the repository root. Do not recommend one-off CLI flags as a substitute for a
missing config file — they are not reproducible across team members or CI.

Minimum required config:

```yaml
ansible-navigator:
  execution-environment:
    enabled: true
    image: <image-name>:<tag>
    pull:
      policy: missing       # pull only if not present locally
  mode: stdout              # stdout for CI; interactive for local exploration
  playbook-artifact:
    enable: false           # disable .json artifact for CI runs
```

See `references/navigator-config.example.yml` for a fully annotated example.

### Rule 2 — Select the correct execution mode

| Mode | When to use | Command |
|:-----|:------------|:--------|
| `stdout` | CI pipelines, scripted runs, check mode | `ansible-navigator run playbook.yml --mode stdout` |
| `interactive` | Local development, exploring task output, debugging | `ansible-navigator run playbook.yml` |

Always use `--mode stdout` in CI and in the `aap-live-validation` dry-run step.
Never hard-code `mode: interactive` in `ansible-navigator.yml` — it breaks CI.

### Rule 3 — Reference the locally built EE image

After `CONTAINER_ENGINE=podman make build` (from the `ee-build-workflow` skill), the
image exists locally. Reference it in `ansible-navigator.yml`:

```yaml
ansible-navigator:
  execution-environment:
    enabled: true
    image: localhost/<image-name>:<tag>   # prefix with localhost/ for local podman images
    pull:
      policy: never                       # prevent navigator from trying to pull a local-only image
```

Use `pull.policy: never` for local images. Use `pull.policy: missing` for registry images.
Use `pull.policy: always` only in CI when you want to ensure the latest registry image is used.

### Rule 4 — Pass vault secrets without exposing them

When the playbook requires vault-encrypted variables, pass the vault password via
`--vault-password-file` — never inline it:

```bash
ansible-navigator run configure_aap.yml \
  --mode stdout \
  --vault-password-file ~/.vault_pass \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml
```

Or configure it in `ansible-navigator.yml`:

```yaml
ansible-navigator:
  ansible:
    cmdline: "--vault-password-file ~/.vault_pass"
```

Never add `--ask-vault-pass` to CI pipelines — it blocks execution.

### Rule 5 — Smoke test a freshly built EE image before pushing

After every EE image build, run a minimal smoke test to confirm the image is functional.
Do this **before** `CONTAINER_ENGINE=podman make push`.

The smoke test must verify:
1. The image launches successfully
2. Required Ansible collections are present
3. Required Python packages are importable

```bash
# Step 1 — list collections inside the image
ansible-navigator collections \
  --execution-environment-image localhost/<image-name>:<tag> \
  --pull-policy never \
  --mode stdout

# Step 2 — run a minimal connectivity playbook
ansible-navigator run smoke-test.yml \
  --execution-environment-image localhost/<image-name>:<tag> \
  --pull-policy never \
  --mode stdout
```

If either command fails, do not push the image. Fix the `execution-environment.yml`
(see the `ee-yaml-schema` skill) and rebuild.

See `references/ee-smoke-test.md` for a complete smoke test playbook and checklist.

### Rule 6 — Log artifacts in CI, disable them locally

Navigator writes `.json` playbook artifacts by default. Configure this deliberately:

```yaml
ansible-navigator:
  playbook-artifact:
    enable: true                    # in CI — useful for post-run inspection
    save-as: /tmp/artifact-{ts}.json
```

```yaml
ansible-navigator:
  playbook-artifact:
    enable: false                   # locally — avoids cluttering the repo root
```

Do not commit `.json` artifact files. Add `*.json` to `.gitignore` if not already present.

## References

See `references/navigator-config.example.yml` for a fully annotated `ansible-navigator.yml`.
See `references/ee-smoke-test.md` for the EE smoke test playbook and pass/fail checklist.
