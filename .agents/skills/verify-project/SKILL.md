---
name: verify-project
description: >-
  Project-specific verification workflow. Run after code or config changes and before
  claiming a task is done. Customize the commands below for this repository during bootstrap.
---

# Verify Project

Prove behavior against the real artifact, not just "it compiles".

## Checklist

1. **Syntax / Typecheck / Lint:**
   - Run the repo's static checks (e.g., `npm run lint`, `tsc --noEmit`, `python -m py_compile`, `node --check`).
2. **Automated Tests:**
   - Run the unit/integration test suite and confirm 0 failures and 0 skipped critical assertions.
3. **Runtime / End-to-End Smoke Check:**
   - Start or exercise the real app/CLI/API and inspect actual output (logs, HTTP status, UI/DOM, or screenshot).
4. **Clean Tree Check:**
   - Run `git status` and `git diff --stat` to confirm no unintended edits or temporary artifacts remain.

## Evidence Format

Record in `.context/cos-board.md` and `AI_HANDOFF.md`:
- Exact commands executed
- Key observed counts/results (never extrapolate)
