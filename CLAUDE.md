<!-- file: CLAUDE.md -->
<!-- version: 0.1.0 -->
<!-- guid: c1a4dec0-0000-4000-8000-000000000001 -->

# CLAUDE.md

Entry point for AI agent instructions in **burndown-runner-image**.

All detailed agent instructions live in `.github/`. This file is a pointer.

## Quick links

- **Coding standards & architecture:** [.github/copilot-instructions.md](.github/copilot-instructions.md)
- **Per-language conventions:** [.github/instructions/](.github/instructions/)
- **Issue / PR templates:** [.github/](./.github/)
- **Full file index:** [AGENTS.md](AGENTS.md)

## Critical rules

1. **Git:** Conventional commits mandatory. Pin all action references to SHAs.
2. **File headers:** All files need versioned headers (file / version / guid).
   Bump the version on every change.
3. **Workflows:** Edit reusable-workflow callers, not the reusables themselves
   (those live in `jdfalk/ghcommon`).
