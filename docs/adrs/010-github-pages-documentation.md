---
title: "ADR-010: GitHub Pages Documentation"
layout: default
parent: Architecture Decisions
nav_order: 10
---

# 10. GitHub Pages Documentation Site

**Status**: Accepted  
**Date**: 2026-04-27  
**Domain**: Documentation / Developer Experience

## Context

The `ansible-aap-skills-cli` repository ships 9 ADRs, 6 skills with detailed SKILL.md files and references, a full CLI reference in README.md, and a CONTRIBUTING guide. This content is valuable but only accessible as raw Markdown on GitHub — difficult to navigate, unsearchable, and not indexed by search engines.

Reference projects in the target ecosystem publish browsable documentation sites:
- `redhat-cop.github.io/aap_config_as_code_docs/`
- `redhat-cop.github.io/automation-good-practices/`

Aligning with this convention increases credibility and discoverability within the Red Hat CoP community.

Options considered:

1. **No docs site** — keep everything as Markdown on GitHub only
2. **ReadTheDocs** — requires an external account and YAML config; adds friction
3. **GitHub Pages + Jekyll** — co-located with source, free, no external accounts, consistent with Red Hat CoP projects
4. **GitHub Pages + MkDocs Material** — popular Python-based alternative; requires pip toolchain
5. **GitHub Pages + plain HTML** — maximum control, maximum maintenance burden

## Decision

Publish a **GitHub Pages site** using **Jekyll with the `just-the-docs` theme**, built automatically by GitHub Actions on every push to `main` that touches `docs/`.

Rationale for each choice:

- **GitHub Pages**: free, co-located with source, no external accounts, direct integration with GitHub Actions `GITHUB_TOKEN`
- **Jekyll**: GitHub Pages has native Jekyll support; no additional build infrastructure needed beyond a `Gemfile`
- **`just-the-docs` theme**: used by other Red Hat CoP documentation sites; provides built-in full-text search, responsive navigation, and a clean minimal design appropriate for technical documentation
- **`docs/` directory on `main`** (not a separate `gh-pages` branch): ADR Markdown files live alongside the site config, making it easy to update docs and ADRs in the same commit; the Actions workflow builds and pushes the rendered HTML to a `gh-pages` branch

## Site Structure

```
docs/
├── _config.yml              # Jekyll configuration
├── Gemfile                  # just-the-docs gem dependency
├── index.md                 # Landing page
├── installation.md          # install.sh command reference
├── skills/
│   ├── index.md             # Skills overview table
│   ├── aap-config-structure.md
│   ├── aap-secrets-management.md
│   ├── aap-infra-roles.md
│   ├── ee-yaml-schema.md
│   ├── ee-build-workflow.md
│   └── ansible-good-practices.md
└── adrs/
    ├── index.md             # ADR index (links to all 10 ADRs)
    ├── 001-skill-format-standard.md
    └── ...                  # existing ADR files rendered as-is
```

Published URL: `https://tosin2013.github.io/ansible-aap-skills-cli`

## Consequences

**Positive:**
- All project documentation is web-browsable and full-text searchable
- Consistent with Red Hat CoP documentation conventions
- Automatically published on every relevant push — no manual deploy step
- ADRs and skill descriptions gain SEO visibility for Ansible AAP engineers
- Zero external accounts or paid services required

**Negative:**
- Adds Ruby/Bundler as a dev toolchain dependency (only required for local preview)
- `docs/` directory now serves a dual purpose (ADRs + Jekyll site source); contributors must be aware of Jekyll front matter requirements
- GitHub Pages has bandwidth limits (100 GB/month softcap) — acceptable for a developer tool project

## Implementation Plan

1. Add `docs/adrs/010-github-pages-documentation.md` (this file)
2. Create `docs/_config.yml` with `just-the-docs` theme configuration
3. Create `docs/Gemfile` with the `just-the-docs` gem
4. Add `docs/.gitignore` to exclude Jekyll build artifacts (`_site/`, `.jekyll-cache/`)
5. Write `docs/index.md`, `docs/installation.md`, `docs/skills/`, `docs/adrs/index.md`
6. Create `.github/workflows/docs.yml` to build and publish on push to `main`
7. Enable GitHub Pages in repository settings (source: `gh-pages` branch)

## Related ADRs

- [ADR-005](005-repository-structure.md) — `docs/` directory is part of the canonical repository structure

## References

- just-the-docs theme: https://just-the-docs.github.io/just-the-docs/
- GitHub Pages documentation: https://docs.github.com/en/pages
- peaceiris/actions-gh-pages: https://github.com/peaceiris/actions-gh-pages
- Red Hat CoP AAP config as code docs: https://redhat-cop.github.io/aap_config_as_code_docs/
