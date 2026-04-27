# AAP Live Validation Checklist

<!-- Last updated: 2026-04-27 -->

This is the complete ordered validation sequence to follow before and after pushing
configuration to a live AAP server. Work through each step in order — do not skip ahead.

---

## Step 1 — Identify deployment type

| Question | OpenShift | Standalone |
|:---------|:----------|:-----------|
| How was AAP installed? | AAP Operator on OpenShift | `aap-setup` installer on VM/bare metal |
| How do I find the URL? | `oc get route -n <ns> automationcontroller` | FQDN set during installation |
| How do I get the admin password? | `oc get secret <name>-admin-password` | Set during install; check `/etc/tower/tower.cfg` |
| Auth reference | `references/openshift-auth.md` | `references/standalone-auth.md` |

---

## Step 2 — Authenticate

Follow the appropriate reference file (Step 1 above). End result must be:

- [ ] `CONTROLLER_HOST` / `controller_hostname` set to the full HTTPS URL
- [ ] `CONTROLLER_OAUTH_TOKEN` / `controller_oauth_token` available (vault-encrypted for commits)
- [ ] `controller_validate_certs` set to `true` (or `false` only for self-signed lab certs — document why)

---

## Step 3 — Connectivity check

```bash
curl -sk \
  -H "Authorization: Bearer ${CONTROLLER_OAUTH_TOKEN}" \
  "${CONTROLLER_HOST}/api/v2/ping/" | python3 -m json.tool
```

- [ ] Response HTTP status is 200
- [ ] Response JSON contains `"version"` key
- [ ] Response JSON `"active_node"` matches expected hostname

**Stop here if connectivity fails.** Resolve auth/network issues before proceeding.

---

## Step 4 — Config syntax check (no server connection required)

```bash
# Lint all YAML files in config/
find config/ -name '*.yml' | xargs yamllint -d relaxed

# Ansible syntax check (parses playbook and roles, no inventory connection)
ansible-playbook configure_aap.yml --syntax-check
```

- [ ] `yamllint` exits 0 with no errors
- [ ] `--syntax-check` exits 0 with no errors

**Stop here if syntax errors are found.** Fix YAML before running against the live server.

---

## Step 5 — Dry run (check mode)

```bash
# Preferred: ansible-navigator with an Execution Environment
ansible-navigator run configure_aap.yml \
  --mode stdout \
  --check \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml \
  --vault-password-file ~/.vault_pass

# Alternative: ansible-playbook directly
ansible-playbook configure_aap.yml \
  --check \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml \
  --vault-password-file ~/.vault_pass
```

Review output:

| Task result | Meaning | Action |
|:-----------|:--------|:-------|
| `ok` | Resource exists and matches desired state | No change needed |
| `changed` | Resource will be created or updated | Review the diff — expected? |
| `failed` | Error that would prevent apply | Fix before proceeding |
| `skipped` | Conditional not met | Verify condition logic |

- [ ] No `failed` tasks in check mode
- [ ] `changed` tasks have been reviewed and are expected

---

## Step 6 — Apply

```bash
# Remove --check to perform the actual apply
ansible-navigator run configure_aap.yml \
  --mode stdout \
  -e @config/all/credentials.yml \
  -e @config/<env>/secrets.yml \
  --vault-password-file ~/.vault_pass
```

- [ ] All tasks complete without `failed` status
- [ ] Task summary shows expected number of `changed` and `ok` results

---

## Step 7 — Post-apply verification

Query a representative sample of resources to confirm they exist:

```bash
# Organizations
curl -sk -H "Authorization: Bearer ${CONTROLLER_OAUTH_TOKEN}" \
  "${CONTROLLER_HOST}/api/v2/organizations/?page_size=200" \
  | python3 -c "import sys,json; [print(o['name']) for o in json.load(sys.stdin)['results']]"

# Inventories
curl -sk -H "Authorization: Bearer ${CONTROLLER_OAUTH_TOKEN}" \
  "${CONTROLLER_HOST}/api/v2/inventories/?page_size=200" \
  | python3 -c "import sys,json; [print(i['name']) for i in json.load(sys.stdin)['results']]"

# Credentials
curl -sk -H "Authorization: Bearer ${CONTROLLER_OAUTH_TOKEN}" \
  "${CONTROLLER_HOST}/api/v2/credentials/?page_size=200" \
  | python3 -c "import sys,json; [print(c['name']) for c in json.load(sys.stdin)['results']]"
```

- [ ] All organizations in `config/all/organizations.yml` appear in the API response
- [ ] All inventories in `config/<env>/inventories.yml` appear in the API response
- [ ] All credentials in `config/all/credentials.yml` appear in the API response

---

## Common failure patterns

| Symptom | Likely cause | Fix |
|:--------|:-------------|:----|
| `401 Unauthorized` on ping | Token expired or wrong | Create a new token |
| `SSL certificate verify failed` | Self-signed cert | Set `controller_validate_certs: false` for lab only |
| `changed` on every apply run | Non-idempotent task or diff in encrypted value | Check var decryption; compare API state |
| `Permission denied` creating resource | Token lacks Write scope | Re-create token with `scope: write` |
| Resource not found after apply | Wrong env vars file loaded | Check `-e @config/<env>/` path |
