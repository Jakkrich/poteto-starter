---
date: 2026-11-23
project: poteto-starter
tags:
  - poteto-starter
  - chief-of-staff
---

# Chief of Staff board

## Latest summary
Nothing waits on you. Updated `README.md` Quick Start to be machine-neutral (`gh repo create --template` for new projects, temp `git clone` + `robocopy` for existing projects) with zero hardcoded local drive paths (`DRIVE_PATH_HITS:0`).

## Active

| ID | Goal | Done-check | Playbook | Owner | Status | Next | Evidence |
|---|---|---|---|---|---|---|---|
| neutral-quickstart-docs | Replace hardcoded local path in `README.md` Quick Start with machine-neutral GitHub template / temp-clone install commands | `README.md` has no personal/hardcoded drive paths (`D:\devtools\...`), excludes `.agents\plugins` when copying, and shows `gh`/GitHub template + neutral copy flow | Refactoring | worker | done | Archive on next chat; ready to commit | `DRIVE_PATH_HITS:0`; reviewed `git diff README.md` |
| sync-cos-script | Add `sync-chief-of-staff` script (Option 1) preserving local `harness.md` and sync updated `SKILL.md` from `Jakkrich/Chief-of-Staff` | `.\.agents\tools\sync-chief-of-staff.bat -NoPause` exits 0, updates `SKILL.md` + `templates/` from `Jakkrich/Chief-of-Staff`, keeps local-first `harness.md` intact, and docs/scripts match | Feature | worker | done | Archive on next chat; ready to commit | `sync-chief-of-staff.bat -NoPause` exit 0 (`ac311bb`); `UTF8_SKILL_MATCH:True`; `TEMP_REMAINING:0` |
| bootstrap-repo | Populate `AI_HANDOFF.md` and customize `verify-project` skill from real codebase inspection | `AI_HANDOFF.md` has accurate build/test commands & invariants; `verify-project` runs cleanly | Investigation | root | queued | Run bootstrap prompt on first chat | — |

## Archive

| ID | Goal | Outcome | Evidence |
|---|---|---|---|
