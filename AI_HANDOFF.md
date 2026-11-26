# AI_HANDOFF — `<project-name>`

Project governance and handoff hub. Active task board and Chief of Staff status live in [`.context/cos-board.md`](./.context/cos-board.md).

## 0. Start here

1. Read [`.context/cos-board.md`](./.context/cos-board.md) and `AI_HANDOFF.md` §1–§2 plus the top 3 entries of §5.
2. Check §2 (`Active Lock`) and `.context/cos-board.md` so you do not overwrite files owned by another active agent.
3. Read §3–§4 as needed for architecture, pitfalls, and open tech debt.

## 1. Current State (update on every change)

| Field | Value |
|---|---|
| Repository / Owner | `Jakkrich/poteto-starter` (branch `main`) |
| Last known commit | `4b5bedc` (preceding official pstack logo commit) |
| Runtime / Stack | PowerShell (`*.ps1`/`*.bat`) + POSIX `sh` (`*.sh`) + Git sparse-checkout + Markdown skills (Antigravity, Codex, Claude Code, Grok) |
| Build command | None (template repo; `.\.agents\tools\sync-pstack.bat -NoPause` syncs `.agents/plugins/pstack/`) |
| Test / Verify command | PowerShell syntax check + `install-project.ps1` temp-dir E2E install/upgrade test + machine-neutrality & zero-`.cursor` checks (see §5) |
| Deploy | Hand repo URL / local path to an AI agent following `FOR_AGENTS.md` (on-project only) |

### Repo Invariants (never break)

- **On-project ONLY:** Never write to global `~/.gemini`, `~/.claude`, `~/.codex`, `~/.grok`, `~/.agents`, or `~/.cursor` directories.
- **No `.cursor/` or `*.mdc`:** Keep `.cursor/` deleted; `sync-chief-of-staff.ps1` must skip `*.mdc` / `cursor-*` templates from upstream.
- **Keep `.agents/skills/verify-project/SKILL.md` generic:** Downstream projects copy it as a starter template.
- **Preserve marker blocks:** Keep `<!-- BEGIN AGENT-STARTER-KIT -->` and `<!-- END AGENT-STARTER-KIT -->` in `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` so upgrades merge without clobbering project rules.
- **Machine-neutral paths:** Keep zero hardcoded local drive paths (`[A-Za-z]:\\`) in tracked docs, rules, and skills.

## 2. Active Lock (avoid agent conflicts)

| Agent | Since | Task | Files touched |
|---|---|---|---|
| — | — | no active tasks | — |

## 3. Architecture & Known Pitfalls

- **Entry points & load order:** `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` + `.agents/rules/chief-of-staff.md` route main-chat sessions to `.agents/skills/chief-of-staff/SKILL.md` and `.agents/skills/chief-of-staff/harness.md`, which resolves `.agents/plugins/pstack/` (`michael-denyer/pstack-claude`) and `.agents/rules/pstack-models.md`.
- **State / Persistence:** `.agents/plugins/` and `.agents/.cache/` are gitignored; `.agents/starter-kit.json` records starter-kit provenance; `.agents/docs/pstack-guide-th/` and `.agents/skills/make-bot-ui/` live outside `.agents/plugins/pstack/` so `sync-pstack` never deletes them.
- **Known pitfalls:** `sync-pstack` mirrors `.agents/.cache/pstack-claude/plugins/pstack` to `.agents/plugins/pstack/` and removes `hooks.json` / `hooks/*-hooks.json` inside the mirrored copy so Windows hosts do not try to run `./hooks/session-start.sh` or duplicate Chief of Staff routing. Antigravity `invoke_subagent` `Model` accepts only `inherit`, `pro`, `flash`, `flash_lite`.

## 4. Tech Debt / Open Gaps

- [ ] `<Add known gaps or follow-ups>`

## 5. Change Log (newest at top)

### 2026-11-27 · Antigravity (Chief of Staff) · Use single official `logo.png` for on-project `pstack`
- **What:** Renamed tracked icon to `.agents/assets/logo.png` (downloaded from `https://raw.githubusercontent.com/cursor/plugins/main/pstack/assets/logo.png`); updated `.agents/tools/sync-pstack.{ps1,sh}` to place only `.agents/plugins/pstack/assets/logo.png`, delete `pstack-icon.png`/`pstack-icon.prompt.txt`/`.claude-plugin/icon.png`, and rewrite `pstack-icon.png` -> `logo.png` in plugin manifests; updated `README.md` and `FOR_AGENTS.md`.
- **Why:** Keep a single `logo.png` file across both starter-kit assets and synced `pstack` plugin manifests.
- **Verification:** `sync-pstack.bat -NoPause` left exactly 1 `.png` (`assets/logo.png`) in `.agents/plugins/pstack/`, Antigravity `GetAllPlugins` resolved `.../assets/logo.png`, and `non_ascii=0` + PowerShell AST + `sh.exe -n` passed.
- **Pending / Notes for next agent:** None.

### 2026-11-26 · Antigravity (Chief of Staff) · Harden on-project installer, upgrader, and sync scripts against all overwrite & POSIX edge cases
- **What:**
  - Added exact v1 legacy snapshots (`templates/legacy-v1-entry.txt`, `legacy-v1-cursor-rule.txt`, `legacy-v1-pstack-antigravity.txt`, `legacy-v1-pstack-models.txt`) from `c6dbec4` and preserved `legacy-v1-*` in `.agents/tools/sync-chief-of-staff.ps1`.
  - Wrapped `.agents/rules/chief-of-staff.md` and `.agents/rules/pstack-antigravity.md` in `<!-- BEGIN AGENT-STARTER-KIT --> ... <!-- END AGENT-STARTER-KIT -->` markers and added YAML frontmatter to `.agents/rules/pstack-models.md`.
  - Hardened `.agents/tools/install-project.{ps1,sh}`: exact-v1-substring & lossless marker merge on `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` and rules; lossless migration of custom notes from `.cursor/rules/chief-of-staff.mdc`; auto-upgrade `pstack-models.md` only when untouched v1; file-by-file `.agents/tools/*` copy; additive `.agents/.gitignore` merge (`plugins/`, `.cache/`, `.backup/`); dirty starter-kit repo `-Upgrade` guard (`-Force`/`--force`); `awk` replacement + JSON escaping in `.sh`.
  - Hardened `.agents/tools/sync-pstack.{ps1,sh}`: fixed `$PstackDir` -> `$PSTACK_DIR` typo in `.sh`, backed up modified/untracked files inside legacy `.agents/plugins/.git` to `.agents/.backup/` before cleanup, and added shallow `git pull --ff-only` re-clone fallback.
  - Updated `FOR_AGENTS.md` upgrade table.
- **Why:** Prevent any data loss when upgrading v1 `poteto-starter` projects or projects with customized rules, tools, `.gitignore`, or `pstack-models.md`, and fix POSIX `sh` edge cases.
- **Verification:** PowerShell AST + `sh.exe -n` + `non_ascii_bytes=0` across all `.ps1`/`.sh` tools (`PASS`); PowerShell 5.1 adversarial v1 upgrade matrix (`PASS`); Git Bash `sh.exe` adversarial matrix (`PASS`); legacy `.agents/plugins/pstack` backup test (`PASS`).
- **Pending / Notes for next agent:** None.

### 2026-11-26 · Antigravity (Chief of Staff) · Migrate to on-project `pstack-claude`, remove `.cursor` & global `pstack`, add AI installer/upgrader
- **What:**
  - Switched `.agents/tools/sync-pstack.ps1` (and added `.agents/tools/sync-pstack.sh`) from `cursor/plugins` to `michael-denyer/pstack-claude` (`plugins/pstack`), storing sparse cache under `.agents/.cache/pstack-claude`, ensuring root `plugin.json`, and removing hook manifests inside the mirrored tree.
  - Preserved Thai guide in `.agents/docs/pstack-guide-th/` and Grok Bot webhook skill in `.agents/skills/make-bot-ui/SKILL.md`.
  - Moved `.cursor/rules/chief-of-staff.mdc` to `.agents/rules/chief-of-staff.md`, deleted `.cursor/` and `templates/cursor-rule.mdc`, and updated `.agents/tools/sync-chief-of-staff.ps1` to skip `*.mdc`/`cursor-*` and preserve `templates/AI_HANDOFF.md`.
  - Updated `.agents/skills/chief-of-staff/harness.md`, `.agents/skills/chief-of-staff/SKILL.md`, `templates/{AGENTS,CLAUDE}.md`, `.agents/rules/pstack-antigravity.md`, `.agents/rules/pstack-models.md`, and marker-wrapped `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` for on-project Antigravity, Codex, Claude Code, and Grok usage.
  - Added `.agents/skills/chief-of-staff/templates/AI_HANDOFF.md`, `.agents/tools/install-project.{ps1,sh}`, `.agents/tools/upgrade-starter-kit.bat`, `.agents/starter-kit.json`, `FOR_AGENTS.md`, and updated `README.md`.
  - Uninstalled/removed global `pstack` across Antigravity (`agy plugin uninstall pstack`), Claude Code (`claude plugin uninstall pstack@cursor-plugins` + `cursor-plugins` marketplace), Codex `~/.codex/skills` (`pstack` + `principle-*` dirs), and Cursor caches.
- **Why:** Standardize on `pstack-claude` (Option A) for Antigravity, Codex, Claude Code, and Grok, eliminate `.cursor/` and global `pstack`, and enable AI-driven on-project install and idempotent upgrades.
- **Verification:** `sync-pstack.bat -Reinstall -NoPause` (`0.9.158`, `1ab6b82`), `agy plugin list --json` (`agy_pstack_count=0`), `claude plugin list` (`claude_has_pstack=False`), global leftover check (`0`), `.cursor` / `*.mdc` / `[A-Za-z]:\\` checks (`False` / `0` / `0`), PowerShell AST parse (`OK`), and E2E `install-project.ps1` install + `-Upgrade` temp-dir test (`PASS`).
- **Pending / Notes for next agent:** Fixed `install-project.ps1` to pure ASCII (`[char]0x2014`) for Windows PowerShell 5.1 UTF-8-without-BOM safety after live clone smoke test caught `â€”` parse error.

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
