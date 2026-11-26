---
date: 2026-11-26
project: poteto-starter
tags:
  - poteto-starter
  - chief-of-staff
---

# Chief of Staff board

## Latest summary
Nothing waits on you. Migrated `agent-starter-kit` to on-project `pstack-claude` (`0.9.158`, `1ab6b82`) for Antigravity, Codex, Claude Code, and Grok; moved `chief-of-staff` rule to `.agents/rules/chief-of-staff.md` and removed `.cursor/`; removed all global `pstack` installs; added `install-project.{ps1,sh}`, `upgrade-starter-kit.bat`, and `FOR_AGENTS.md` with E2E upgrade verification passing.

## Active

| ID | Goal | Done-check | Playbook | Owner | Status | Next | Evidence |
|---|---|---|---|---|---|---|---|

## Archive

| ID | Goal | Outcome | Evidence |
|---|---|---|---|
| migrate-pstack-claude-on-project | Switch starter kit to `pstack-claude`, remove `.cursor/` and global `pstack`, and add AI on-project installer & upgrader | Migrated to `pstack-claude`, deleted `.cursor/` & global `pstack`, and added AI installer/upgrader | `sync-pstack` `0.9.158`/`1ab6b82`; `agy_pstack_count=0`; `claude_has_pstack=False`; `has_cursor_dir=False`; `E2E Install & Idempotent Upgrade: PASS` |
| bootstrap-repo | Populate `AI_HANDOFF.md` and customize `verify-project` skill from real codebase inspection | `AI_HANDOFF.md` §1–§5 populated; `.agents/skills/verify-project/SKILL.md` kept generic as downstream template | `AI_HANDOFF.md` + `FOR_AGENTS.md` |
| neutral-quickstart-docs | Replace hardcoded local path in `README.md` Quick Start | Replaced with machine-neutral GitHub template & clone flow | `DRIVE_PATH_HITS:0` |
| sync-cos-script | Add `sync-chief-of-staff` script preserving local `harness.md` | Synced `ac311bb` with local-first `harness.md` | `sync-chief-of-staff.bat -NoPause` exit 0 |
