# AI_HANDOFF — `<project-name>`

Project governance and handoff hub. Active task board and Chief of Staff status live in [`.context/cos-board.md`](./.context/cos-board.md).

## 0. Start here

1. Read [`.context/cos-board.md`](./.context/cos-board.md) and `AI_HANDOFF.md` §1–§2 plus the top 3 entries of §5.
2. Check §2 (`Active Lock`) and `.context/cos-board.md` so you do not overwrite files owned by another active agent.
3. Read §3–§4 as needed for architecture, pitfalls, and open tech debt.

## 1. Current State (update on every change)

| Field | Value |
|---|---|
| Repository / Owner | `<owner>/<repo>` (branch `main`) |
| Last known commit | `—` |
| Runtime / Stack | `<fill during bootstrap>` |
| Build command | `<fill during bootstrap>` |
| Test / Verify command | `<fill during bootstrap>` |
| Deploy | `<fill during bootstrap>` |

### Repo Invariants (never break)

- `<Add hard rules discovered in this repo, e.g. schema migrations, bundle parity, determinism, never commit secrets>`
- Run the project's verification checks (`.agents/skills/verify-project/SKILL.md`) before reporting any task complete.

## 2. Active Lock (avoid agent conflicts)

| Agent | Since | Task | Files touched |
|---|---|---|---|
| — | — | no active tasks | — |

## 3. Architecture & Known Pitfalls

- **Entry points & load order:** `<fill during bootstrap>`
- **State / Persistence:** `<fill during bootstrap>`
- **Known pitfalls:** `<fill during bootstrap>`

## 4. Tech Debt / Open Gaps

- [ ] `<Add known gaps or follow-ups>`

## 5. Change Log (newest at top)

### 2026-11-23 · Chief of Staff (worker db3299e0) · Make README Quick Start machine-neutral
- **What:** Updated `README.md` section `### 1. Create or copy into a project` to replace `D:\devtools\agent-starter-kit` with GitHub template (`gh repo create --template Jakkrich/poteto-starter --clone`) and a temp `git clone` + `robocopy` flow for existing projects.
- **Why:** Remove machine-specific local drive paths so anyone can install `poteto-starter` on any machine.
- **Verification:** `Select-String -Path README.md -Pattern '[A-Za-z]:\\'` returned `DRIVE_PATH_HITS:0`; `git diff README.md` verified.
- **Pending / Notes for next agent:** Ready to commit with the `sync-chief-of-staff` additions.

### 2026-11-23 · Chief of Staff (worker e15600c5) · Add sync-chief-of-staff scripts & sync upstream ac311bb
- **What:** Added `.agents/tools/sync-chief-of-staff.ps1`, `.agents/tools/sync-chief-of-staff.bat`, and `.agents/tools/sync-all.bat`; updated `.agents/skills/chief-of-staff/SKILL.md`, `.agents/skills/chief-of-staff/templates/AGENTS.md`, `.agents/skills/chief-of-staff/harness.md`, and `README.md`.
- **Why:** Sync `chief-of-staff` skill and templates from `https://github.com/Jakkrich/Chief-of-Staff.git` (`main`) while preserving `poteto-starter`'s local-first `.agents/plugins/pstack/` and Antigravity `harness.md`.
- **Verification:** `.\.agents\tools\sync-chief-of-staff.bat -NoPause` exited `0` (synced `ac311bb`, preserved `harness.md`), `.\.agents\tools\sync-all.bat -NoPause` exited `0`, `UTF8_SKILL_MATCH:True`, `TEMP_REMAINING:0`.
- **Pending / Notes for next agent:** Review and commit changes to `main`; `bootstrap-repo` remains queued for template consumers.

### YYYY-MM-DD · <Agent> · <short title>
- **What:** exact file paths and symbols changed
- **Why:** user request / bug / improvement
- **Verification:** exact commands run and observed results
- **Pending / Notes for next agent:** none
