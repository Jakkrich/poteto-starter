# poteto-starter

Self-contained agentic development starter kit combining **Chief of Staff** (`chief-of-staff`), **pstack** (`poteto-mode`), structured project governance (`AI_HANDOFF.md`), and a per-repo task board (`.context/cos-board.md`).

Works across **Antigravity**, **Claude Code**, **Cursor**, **Codex**, and **Gemini CLI** using repo-local configuration with no global plugin install required.

---

## Repository Structure

```text
poteto-starter/
├── AGENTS.md                        # Bootstrap instructions (Codex / Cursor / Antigravity)
├── CLAUDE.md                        # Bootstrap instructions (Claude Code)
├── GEMINI.md                        # Bootstrap instructions (Gemini / Antigravity)
├── AI_HANDOFF.md                    # Architecture, repo invariants, pitfalls, and change log
├── .context/
│   └── cos-board.md                 # Active / Archive Chief of Staff board + latest summary
├── .cursor/
│   └── rules/
│       └── chief-of-staff.mdc       # Cursor rule (alwaysApply: true)
└── .agents/
    ├── .gitignore                   # Ignores plugins/ so upstream pstack stays out of host commits
    ├── rules/
    │   ├── pstack-antigravity.md    # Maps Cursor-specific pstack names to Antigravity tools
    │   └── pstack-models.md         # Per-role model selection (adjust via /setup-pstack)
    ├── tools/
    │   ├── sync-all.bat             # Runs sync-pstack and sync-chief-of-staff
    │   ├── sync-chief-of-staff.bat  # Syncs upstream Chief-of-Staff SKILL.md & templates
    │   ├── sync-chief-of-staff.ps1
    │   ├── sync-pstack.bat          # Clones/updates upstream pstack via sparse-checkout
    │   └── sync-pstack.ps1
    ├── plugins/
    │   └── pstack/                  # Installed by sync-pstack (gitignored)
    └── skills/
        ├── chief-of-staff/          # Chief of Staff skill (local-first harness.md)
        └── verify-project/          # Customizable project verification skill template
```

---

## Quick Start

### 1. Create or copy into a project
**New project:** Click **Use this template** on [`Jakkrich/poteto-starter`](https://github.com/Jakkrich/poteto-starter), or create and clone with GitHub CLI:

```powershell
gh repo create <your-project> --template Jakkrich/poteto-starter --clone
```

**Existing project:** Run from your project root (`.`) to clone into a temp folder, copy the starter files while excluding `.git`, `.agents\plugins`, and `README.md`, then clean up:

```powershell
$tmp = Join-Path $env:TEMP 'poteto-starter'
git clone --depth 1 https://github.com/Jakkrich/poteto-starter.git $tmp
robocopy $tmp . /E /XD .git "$tmp\.agents\plugins" /XF README.md
Remove-Item $tmp -Recurse -Force
```

### 2. Install `pstack` locally
Run the sparse-checkout installer script to pull `pstack` from `cursor/plugins` into `.agents/plugins/pstack/` (double-click in Windows Explorer or run in PowerShell/CMD):

```powershell
.\.agents\tools\sync-pstack.bat
```

Re-run the same script anytime to update `pstack` via `git pull --ff-only`. Pass `-Reinstall` for a clean sparse clone, or `-NoPause` for non-interactive runs.

### 3. Update `chief-of-staff` (or sync all)
To pull the latest `SKILL.md` and `templates/` from [`Jakkrich/Chief-of-Staff`](https://github.com/Jakkrich/Chief-of-Staff) (`main`) while preserving `poteto-starter`'s local-first `harness.md`:

```powershell
.\.agents\tools\sync-chief-of-staff.bat
```

By default, `sync-chief-of-staff` preserves `.agents/skills/chief-of-staff/harness.md` and reports whether upstream `harness.md` differs. Pass `-IncludeHarness` to overwrite `harness.md` from upstream, or `-NoPause` for non-interactive runs.

To update both `pstack` and `chief-of-staff` in one step:

```powershell
.\.agents\tools\sync-all.bat
```

### 4. Bootstrap the project with AI
Open the project in your AI coding agent and send this prompt once:

```text
/chief-of-staff Bootstrap the development platform for this project from the starter kit:
1. Inspect the real codebase, configs, build, test, lint, and deploy commands (do not guess).
2. Populate `AI_HANDOFF.md` with real Current State, Repo Invariants, Architecture, and Known Pitfalls.
3. Update `.context/cos-board.md` with the project name, date, and close `bootstrap-repo`.
4. Customize `.agents/skills/verify-project/SKILL.md` with this project's real checks and run it once.
Report the summary and verification outputs when done.
```

Optional: run `/setup-pstack` to customize model roles in `.agents/rules/pstack-models.md` for your environment.

---

## Daily Usage Prompts

- **Check status in a new chat:**
  ```text
  /chief-of-staff status
  ```
- **Implement a feature or bug fix:**
  ```text
  /chief-of-staff <goal> | Done-check: <verifiable pass/fail condition>
  ```
- **Investigate read-only:**
  ```text
  /chief-of-staff explain how <subsystem> works (don't change any code yet)
  ```
- **Run autonomously:**
  ```text
  /chief-of-staff keep going: <scope> | Done-check: <predicate>
  ```
