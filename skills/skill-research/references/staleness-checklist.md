<!-- Last updated: 2026-04-27 from tosin2013/ansible-aap-skills-cli -->

# Staleness Audit Checklist

Follow this checklist when asked to audit or refresh `references/` content across
one or all skills in `ansible-aap-skills-cli`.

---

## Step 1 — Discover all reference files

```bash
find skills/ -path "*/references/*" -type f | sort
```

For each file found, proceed through the steps below.

---

## Step 2 — Read the last-updated comment

Open each reference file and look for a comment in the form:

```
<!-- Last updated: YYYY-MM-DD from <upstream-url> -->
```

If the comment is **missing**, the file must be treated as stale (unknown age).
Add the comment after updating.

---

## Step 3 — Calculate age

Compare the `Last updated` date to today's date:

- **< 30 days**: Fresh — no action needed
- **30–90 days**: Monitor — check upstream for significant changes
- **> 90 days**: Stale — must verify against upstream and update if changed
- **Missing date**: Unknown — treat as stale

---

## Step 4 — Check upstream for changes

For each file flagged as stale or unknown:

1. Look up the upstream URL in `sources-catalog.md`
2. Check the upstream repository's commit history since the `Last updated` date:
   ```bash
   gh api repos/<owner>/<repo>/commits \
     --jq '.[].commit.message' \
     -F since=<YYYY-MM-DDT00:00:00Z>
   ```
3. Scan commit messages for keywords: `schema`, `breaking`, `rename`, `remove`, `deprecat`
4. If relevant commits exist → mark as **NEEDS UPDATE**
5. If no relevant commits → mark as **OK** (update the date comment to today)

---

## Step 5 — Report findings

Present findings in this format before taking any action:

```
STALENESS AUDIT REPORT — <date>

SKILL                    FILE                              AGE    STATUS
----                     ----                              ---    ------
aap-config-structure     references/directory-layout.md   45d    OK
aap-infra-roles          references/async-pattern.yml     90d    NEEDS UPDATE
ee-yaml-schema           references/schema-versions.md    Missing UNKNOWN
```

Ask the user: "Which files would you like me to update?"
Do not update anything without explicit instruction.

---

## Step 6 — Update stale files

For each file the user approves for update:

1. Fetch the relevant upstream section (see Rule 2 in SKILL.md)
2. Show the diff between old and new content
3. Wait for user approval
4. Write the updated content with a new `<!-- Last updated: ... -->` comment
5. Update the skill's `SKILL.md` `## References` section if the filename changed

---

## Step 7 — Flag upstream problems

If during the audit you discover that the upstream content itself is wrong
(not just changed), switch to the issue-filing workflow in `issue-template.md`.

Examples that trigger issue filing rather than a simple update:
- The upstream README describes a variable name that no longer works
- The upstream schema docs are missing a required field
- An upstream example produces an error when followed literally

Source: tosin2013/ansible-aap-skills-cli
