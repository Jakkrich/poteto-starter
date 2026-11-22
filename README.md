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
Use this repository as a GitHub template (or copy its files into your project root, excluding `.git` if copying manually):

```powershell
robocopy D:\devtools\agent-starter-kit D:\path\to\your-project /E /XD .git /XF README.md
```

### 2. Install `pstack` locally
Run the sparse-checkout installer script to pull `pstack` from `cursor/plugins` into `.agents/plugins/pstack/` (double-click in Windows Explorer or run in PowerShell/CMD):

```powershell
.\.agents\tools\sync-pstack.bat
```

Re-run the same script anytime to update `pstack` via `git pull --ff-only`. Pass `-Reinstall` for a clean sparse clone.

### 3. Bootstrap the project with AI
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
