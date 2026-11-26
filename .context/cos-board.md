---
date: 2026-11-27
project: poteto-starter
tags:
  - poteto-starter
  - chief-of-staff
---

# Chief of Staff board

## Latest summary
Nothing waits on you. Downloaded official `cursor/plugins` `pstack/assets/logo.png` into `.agents/assets/pstack-logo.png`, wired `sync-pstack.{ps1,sh}` and `install-project.{ps1,sh}` to distribute and apply it across on-project `pstack-claude` manifests, verified SHA-256 parity and script checks, and pushed to `origin/main`.

## Active

| ID | Goal | Done-check | Playbook | Owner | Status | Next | Evidence |
|---|---|---|---|---|---|---|---|

## Archive

| ID | Goal | Outcome | Evidence |
|---|---|---|---|
| official-pstack-logo | Replace `pstack-claude` icon with official `cursor/plugins` `logo.png` | Vendored `.agents/assets/pstack-logo.png`; wired `sync-pstack` & `install-project` | SHA-256 match + `sync-pstack.bat -NoPause` + `install-project` temp check |
| harden-installer-no-overwrite | Close v1 overwrite holes and POSIX/sync edge cases in installer and sync scripts | Fixed all 8 identified vulnerabilities; PowerShell 5.1 & POSIX `sh.exe` adversarial suites pass | `Check 1-4: PASS`; `non_ascii=0`; live smoke check `4b5bedc` |
| migrate-pstack-claude-on-project | Switch starter kit to `pstack-claude`, remove `.cursor/` and global `pstack`, and add AI on-project installer & upgrader | Migrated to `pstack-claude`, deleted `.cursor/` & global `pstack`, and added AI installer/upgrader | `sync-pstack` `0.9.158`/`1ab6b82`; `agy_pstack_count=0`; `claude_has_pstack=False`; `has_cursor_dir=False`; `E2E Install & Idempotent Upgrade: PASS` |
| bootstrap-repo | Populate `AI_HANDOFF.md` and customize `verify-project` skill from real codebase inspection | `AI_HANDOFF.md` §1–§5 populated; `.agents/skills/verify-project/SKILL.md` kept generic as downstream template | `AI_HANDOFF.md` + `FOR_AGENTS.md` |
| neutral-quickstart-docs | Replace hardcoded local path in `README.md` Quick Start | Replaced with machine-neutral GitHub template & clone flow | `DRIVE_PATH_HITS:0` |
| sync-cos-script | Add `sync-chief-of-staff` script preserving local `harness.md` | Synced `ac311bb` with local-first `harness.md` | `sync-chief-of-staff.bat -NoPause` exit 0 |
