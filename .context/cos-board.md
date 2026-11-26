---
date: 2026-11-26
project: poteto-starter
tags:
  - poteto-starter
  - chief-of-staff
---

# Chief of Staff board

## Latest summary
Nothing waits on you. Hardened `install-project.{ps1,sh}`, `sync-pstack.{ps1,sh}`, and `sync-chief-of-staff.ps1` against 8 overwrite/edge-case bugs (lossless v1 & `.cursor` migration, file-by-file `.agents/tools/`, additive `.gitignore`, untouched-v1 `pstack-models.md` upgrade, legacy `pstack` backup, shallow-pull fallback, POSIX `$PSTACK_DIR`/JSON/ASCII fixes, dirty starter-kit `-Upgrade` guard). All PowerShell 5.1 and POSIX `sh.exe` adversarial tests passed.

## Active

| ID | Goal | Done-check | Playbook | Owner | Status | Next | Evidence |
|---|---|---|---|---|---|---|---|

## Archive

| ID | Goal | Outcome | Evidence |
|---|---|---|---|
| harden-installer-no-overwrite | Close v1 overwrite holes and POSIX/sync edge cases in installer and sync scripts | Fixed all 8 identified vulnerabilities; PowerShell 5.1 & POSIX `sh.exe` adversarial suites pass | `Check 1-4: PASS`; `non_ascii=0`; live smoke check pending push |
| migrate-pstack-claude-on-project | Switch starter kit to `pstack-claude`, remove `.cursor/` and global `pstack`, and add AI on-project installer & upgrader | Migrated to `pstack-claude`, deleted `.cursor/` & global `pstack`, and added AI installer/upgrader | `sync-pstack` `0.9.158`/`1ab6b82`; `agy_pstack_count=0`; `claude_has_pstack=False`; `has_cursor_dir=False`; `E2E Install & Idempotent Upgrade: PASS` |
| bootstrap-repo | Populate `AI_HANDOFF.md` and customize `verify-project` skill from real codebase inspection | `AI_HANDOFF.md` §1–§5 populated; `.agents/skills/verify-project/SKILL.md` kept generic as downstream template | `AI_HANDOFF.md` + `FOR_AGENTS.md` |
| neutral-quickstart-docs | Replace hardcoded local path in `README.md` Quick Start | Replaced with machine-neutral GitHub template & clone flow | `DRIVE_PATH_HITS:0` |
| sync-cos-script | Add `sync-chief-of-staff` script preserving local `harness.md` | Synced `ac311bb` with local-first `harness.md` | `sync-chief-of-staff.bat -NoPause` exit 0 |
