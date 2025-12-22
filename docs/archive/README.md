# Documentation Archive

This directory contains historical documentation from the initial server restoration effort (December 14-22, 2025).

These files have been **superseded** by the new organized documentation in the parent `docs/` directory, but are preserved here for reference and historical context.

---

## Archived Files

### CLAUDE.md
**Original:** Project discovery and development log
**Content:** Architecture analysis, database schema, early experiments
**Superseded by:** Main [README.md](../../README.md) and [BUILDING.md](../BUILDING.md)

### UBUNTU_SETUP.md
**Original:** Ubuntu/WSL compilation guide
**Content:** Step-by-step build instructions, dependency installation
**Superseded by:** [BUILDING.md](../BUILDING.md) - now covers multiple platforms

### SERVER_RESTORATION_SUMMARY.md
**Original:** Complete project summary through December 22
**Content:** Everything accomplished, file lists, dependencies
**Superseded by:** [BUILDING.md](../BUILDING.md) + [MODIFICATIONS.md](../MODIFICATIONS.md)

### LOGIN_SERVICE_DEBUG.md
**Original:** Network protocol debugging log (16 test iterations)
**Content:** SCS message format investigation, test matrix, findings
**Superseded by:** [PROTOCOL_NOTES.md](../PROTOCOL_NOTES.md)

---

## Why These Were Archived

As the project evolved, we accumulated multiple documentation files with overlapping information. To make the project more accessible to new contributors, we reorganized everything into focused, purpose-driven documents:

| Old Files | New Organization |
|-----------|------------------|
| CLAUDE.md (project log) | README.md (project overview) |
| UBUNTU_SETUP.md (Ubuntu guide) | BUILDING.md (all platforms) |
| SERVER_RESTORATION_SUMMARY.md (summary) | BUILDING.md + MODIFICATIONS.md |
| LOGIN_SERVICE_DEBUG.md (protocol debug) | PROTOCOL_NOTES.md (protocol reference) |

---

## When to Read These

**New contributors:** Start with the current documentation in [`docs/`](../)

**Historical research:** These files are valuable if you want to:
- Understand the project's evolution
- See the debugging process
- Review alternative approaches that were tried
- Find detailed logs of specific issues

**Protocol debugging:** The LOGIN_SERVICE_DEBUG.md contains exhaustive test results that may be useful for troubleshooting similar issues.

---

## Maintenance

These files are **read-only historical records**. For corrections or updates:
- Current documentation: Edit files in [`docs/`](../)
- Historical corrections: Note in this README, don't modify original files

---

**Last Archived:** December 22, 2025
**Original Development Period:** December 14-22, 2025
