# FOR_AGENTS — On-Project Install & Upgrade Guide

Follow this guide when the operator points you to `agent-starter-kit` (`https://github.com/Jakkrich/poteto-starter.git` or a local clone) and asks you to **install** or **upgrade** it inside their target project.

## Hard Constraints

1. **On-project ONLY:** NEVER install skills, plugins, hooks, or rules into global home directories (`~/.gemini`, `~/.claude`, `~/.codex`, `~/.grok`, `~/.agents`, `~/.cursor`, or `npx open-pstack` global modes). Everything must stay inside `<target-project>/`.
2. **Preserve project state on upgrade:** Never overwrite `AI_HANDOFF.md`, `.context/cos-board.md`, `.agents/skills/verify-project/SKILL.md`, `.agents/rules/pstack-models.md`, or custom user text outside `<!-- BEGIN AGENT-STARTER-KIT --> ... <!-- END AGENT-STARTER-KIT -->` in `AGENTS.md` / `CLAUDE.md` / `GEMINI.md`.
3. **No `.cursor` folder:** Do not create `.cursor/`. If upgrading a legacy project that still has `.cursor/rules/chief-of-staff.mdc`, let the installer remove it cleanly.

---

## Fresh On-Project Install (Run from `<target-project>`)

### Windows (PowerShell)

```powershell
$tmp = Join-Path $env:TEMP ('starter-kit-' + [guid]::NewGuid().ToString('N').Substring(0,8))
git clone --depth 1 https://github.com/Jakkrich/poteto-starter.git $tmp
powershell -NoProfile -ExecutionPolicy Bypass -File "$tmp\.agents\tools\install-project.ps1" -TargetDir (Get-Location).Path -SourceRepo "https://github.com/Jakkrich/poteto-starter.git" -NoPause
Remove-Item $tmp -Recurse -Force
```

### POSIX (macOS / Linux / WSL / Git Bash)

```sh
tmp=$(mktemp -d "${TMPDIR:-/tmp}/starter-kit.XXXXXX")
git clone --depth 1 https://github.com/Jakkrich/poteto-starter.git "$tmp"
sh "$tmp/.agents/tools/install-project.sh" --target "$(pwd)" --source "https://github.com/Jakkrich/poteto-starter.git"
rm -rf "$tmp"
```

After running the installer on a fresh project, inspect the project's real codebase, configs, build, lint, test, and deploy commands (do not guess), then:
1. Fill `AI_HANDOFF.md` (§1 Current State, Repo Invariants, §3 Architecture & Known Pitfalls).
2. Customize `.agents/skills/verify-project/SKILL.md` with the project's real verification commands and run it once.
3. Update `.context/cos-board.md` to close `bootstrap-repo` with the verification evidence.

---

## Upgrade an Existing Project from `agent-starter-kit` (Run from `<target-project>`)

### Windows

```powershell
.\.agents\tools\upgrade-starter-kit.bat -NoPause
```

### POSIX

```sh
sh .agents/tools/install-project.sh --upgrade
```

If `.agents/tools/upgrade-starter-kit.bat` does not exist yet (upgrading from an older v1 `poteto-starter` repo), run the **Fresh On-Project Install** snippet above — `install-project` detects existing files, updates only managed starter-kit assets + `pstack-claude`, removes legacy `.cursor/rules/chief-of-staff.mdc`, updates the `<!-- BEGIN AGENT-STARTER-KIT -->` block in `AGENTS.md`/`CLAUDE.md`/`GEMINI.md`, and preserves all project-owned files.

---

## What Gets Updated vs Preserved

| Path | Behavior on Install & Upgrade |
|---|---|
| `.agents/skills/chief-of-staff/`, `.agents/skills/make-bot-ui/`, `.agents/docs/pstack-guide-th/` | **Managed:** overwritten from latest `agent-starter-kit` |
| `.agents/tools/*` | **File-by-file managed:** updates only starter-kit scripts; custom user scripts in `.agents/tools/` are preserved |
| `.agents/.gitignore` | **Additive merge:** preserves existing user lines and appends missing `plugins/`, `.cache/`, `.backup/` |
| `.agents/rules/chief-of-staff.md`, `.agents/rules/pstack-antigravity.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` | **Lossless marker/v1 merge:** updates only `<!-- BEGIN AGENT-STARTER-KIT --> ... <!-- END AGENT-STARTER-KIT -->` (or exact untouched v1 stub); custom notes and user-edited v1 files are never overwritten |
| `.cursor/rules/chief-of-staff.mdc` | **Lossless migration:** preserves any user-added notes into `.agents/rules/chief-of-staff.md` below the marker block before removing `.cursor/` |
| `.agents/plugins/pstack/` | **Synced:** updated from `michael-denyer/pstack-claude` (`gitignored`); local edits in legacy v1 `cursor/plugins` checkouts are backed up to `.agents/.backup/` first |
| `AI_HANDOFF.md`, `.context/cos-board.md`, `.agents/skills/verify-project/SKILL.md` | **Project-owned:** created only if missing; never overwritten |
| `.agents/rules/pstack-models.md` | **User-owned (with untouched-v1 auto-upgrade):** upgraded only when missing or identical to the untouched v1 Cursor-slug default; user edits are never overwritten |
| `.agents/starter-kit.json` | **Manifest:** records source repo, starter-kit commit, and `pstack-claude` version |
