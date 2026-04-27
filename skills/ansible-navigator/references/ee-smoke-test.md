# EE Image Smoke Test

<!-- Last updated: 2026-04-27 -->

Run these checks after every `CONTAINER_ENGINE=podman make build` and **before**
`CONTAINER_ENGINE=podman make push`. A smoke test confirms the image is functional
without requiring a live AAP server.

---

## Prerequisites

- The EE image has been built locally (`CONTAINER_ENGINE=podman make build`)
- `ansible-navigator` is installed on the host (`pip install ansible-navigator`)
- Podman is available (the image was built with podman)

---

## Step 1 — Verify the image exists

```bash
IMAGE_NAME="localhost/ansible-execution-environment:latest"

podman image inspect "${IMAGE_NAME}" > /dev/null 2>&1 \
  && echo "Image found: ${IMAGE_NAME}" \
  || { echo "Image not found — run: CONTAINER_ENGINE=podman make build"; exit 1; }
```

---

## Step 2 — List installed collections

Confirms all collections from `files/requirements.yml` were installed correctly:

```bash
ansible-navigator collections \
  --execution-environment-image "${IMAGE_NAME}" \
  --pull-policy never \
  --mode stdout 2>&1
```

Expected: table listing all collections with their versions.  
Failure: `No collections found` or a container launch error → rebuild with `make clean && make build`.

---

## Step 3 — Verify Python packages

Check that required Python packages are importable inside the EE:

```bash
ansible-navigator exec \
  --execution-environment-image "${IMAGE_NAME}" \
  --pull-policy never \
  --mode stdout \
  -- python3 -c "import ansible; print('ansible', ansible.__version__)"
```

Add additional checks for any packages in `files/requirements.txt`:

```bash
# Example for boto3
ansible-navigator exec \
  --execution-environment-image "${IMAGE_NAME}" \
  --pull-policy never \
  --mode stdout \
  -- python3 -c "import boto3; print('boto3 ok')"
```

---

## Step 4 — Run the smoke test playbook

Create a minimal `smoke-test.yml` in the repository root (or `tests/`):

```yaml
---
# smoke-test.yml — minimal EE sanity check
- name: EE smoke test
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:

    - name: Confirm ansible version
      ansible.builtin.command: ansible --version
      register: ansible_ver
      changed_when: false

    - name: Print ansible version
      ansible.builtin.debug:
        msg: "{{ ansible_ver.stdout_lines[0] }}"

    - name: Confirm required collections are loadable
      ansible.builtin.command: ansible-galaxy collection list
      register: collection_list
      changed_when: false

    - name: Assert awx.awx is present
      ansible.builtin.assert:
        that: "'awx.awx' in collection_list.stdout"
        fail_msg: "awx.awx collection not found in EE image"
```

Run the playbook inside the EE:

```bash
ansible-navigator run smoke-test.yml \
  --execution-environment-image "${IMAGE_NAME}" \
  --pull-policy never \
  --mode stdout
```

---

## Step 5 — Interpret results

| Output | Meaning | Action |
|:-------|:--------|:-------|
| All tasks `ok` | Image is functional | Proceed to `make push` |
| `failed` on collection assert | Collection missing from `files/requirements.yml` | Add collection, rebuild |
| `failed` on python import | Package missing from `files/requirements.txt` | Add package, rebuild |
| Container launch error | Image corrupt or wrong architecture | `make clean && make build` |
| `UNREACHABLE` on localhost | `connection: local` not set | Check play `connection:` setting |

---

## Automating in the Makefile

Add a `test` target to the Makefile that wraps these steps:

```makefile
.PHONY: test
test:
	ansible-navigator run smoke-test.yml \
	  --execution-environment-image localhost/$(IMAGE_NAME):$(IMAGE_TAG) \
	  --pull-policy never \
	  --mode stdout
```

This aligns with `CONTAINER_ENGINE=podman make test` from the `ee-build-workflow` skill.

---

## Upstream references

- ansible-navigator documentation: https://ansible.readthedocs.io/projects/navigator/
- ansible-navigator collections subcommand: https://ansible.readthedocs.io/projects/navigator/subcommands/collections/
- ansible-navigator exec subcommand: https://ansible.readthedocs.io/projects/navigator/subcommands/exec/
