# Skill Research and Reference Maintenance

This is a **contributor meta-skill** for the `ansible-aap-skills-cli` repository.
It is NOT for helping engineers with AAP configuration — it is for contributors
who are building or maintaining the skills in this repository.

---

## Purpose

1. Populate `references/` directories with accurate, vendored upstream documentation
2. Detect and fix stale reference files
3. File GitHub issues in upstream repositories when problems are discovered

---

## Rule 1 — Always consult sources-catalog.md before fetching

Before fetching any upstream content, look up the canonical source in
`references/sources-catalog.md`. Never guess a URL.

```
Correct workflow:
  1. Open references/sources-catalog.md
  2. Find the skill row
  3. Use the listed upstream URL — not a search result, not a cached page
```

---

## Rule 2 — Fetch and format upstream content correctly

When updating a `references/` file:

1. Fetch ONLY the section relevant to the skill — not the entire upstream file
2. Add a `<!-- Last updated: YYYY-MM-DD from <upstream-url> -->` comment at the top
3. Trim to the minimum needed; link to the full upstream source at the bottom
4. Save as Markdown (`.md`) or YAML (`.yml`) matching the existing conventions in the skill

```markdown
<!-- Last updated: 2026-04-27 from https://github.com/redhat-cop/infra.aap_configuration -->

# Excerpt: Async Task Pattern
...content...

Source: https://github.com/redhat-cop/infra.aap_configuration/blob/main/README.md
```

---

## Rule 3 — Detect staleness

When auditing a skill's `references/` directory:

1. Read the `<!-- Last updated: ... -->` comment from each file
2. Compare to today's date — flag files older than **90 days**
3. Check the upstream source's commit history or changelog for changes since that date
4. Report: `[STALE]` if older than 90 days and upstream has changed, `[OK]` otherwise

---

## Rule 4 — Update workflow (four steps)

When a reference file needs updating:

```
Step 1: CHECK    — read current file, note last-updated date, check upstream for changes
Step 2: FETCH    — retrieve only the changed/relevant section from upstream
Step 3: UPDATE   — replace stale content, update <!-- Last updated --> comment
Step 4: CONFIRM  — show the diff to the user and ask for approval before saving
```

Never silently overwrite a reference file. Always show the diff first.

---

## Rule 5 — Never embed entire repositories

Only vendor the minimum content needed. Rules:
- Maximum 150 lines per reference file
- Always include a `Source:` link at the bottom pointing to the full upstream document
- If content exceeds 150 lines, split into multiple focused files

---

## Rule 6 — Classify upstream problems before filing an issue

When a problem is found in an upstream repository, classify it before drafting an issue:

| Type | Description | Example |
|:---|:---|:---|
| **Documentation bug** | Upstream docs are incorrect or misleading | Wrong variable name in README |
| **Schema/API change** | Upstream changed something that breaks a vendored reference | EE manifest field renamed |
| **Missing documentation** | Upstream has no docs for a feature the skill needs to explain | No docs for new Makefile target |

Look up the correct target repository in `references/sources-catalog.md` under the
"Upstream Repo for Issues" column.

---

## Rule 7 — Draft the issue with the user before filing

When an upstream problem is found:

1. Tell the user what you found and which upstream repo is affected
2. Classify the issue type (Rule 6)
3. Check for existing issues: `gh issue list --repo <owner/repo> --search "<keywords>"`
4. Draft the issue using `references/issue-template.md`
5. Show the complete draft (title + body + target repo + labels) to the user
6. **Wait for explicit confirmation** — say "Shall I file this issue?" and only proceed on yes
7. Run `gh issue create` with the confirmed content
8. Share the issue URL with the user

---

## Rule 8 — Never file an issue automatically

You MUST NOT run `gh issue create` without the user explicitly confirming the draft.
If the user does not respond or is ambiguous, do not file. Ask again.

---

## References

See `references/sources-catalog.md` for the canonical upstream URL for each skill.
See `references/staleness-checklist.md` for the complete staleness audit procedure.
See `references/issue-template.md` for the GitHub issue template and filing workflow.
