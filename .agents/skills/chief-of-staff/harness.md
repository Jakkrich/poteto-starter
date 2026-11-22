# Harness map

Read this once per chat after you know which tools this session actually has. Map every Cursor name in the skill with the matching row. Never pass a field or value the tool schema rejects.

If `<pstack>/docs/harness/claude-code.md` exists and this session is Claude Code, that file wins over this one.
If `<pstack>/skills/poteto-mode/references/agy-tools.md` exists and this session is Antigravity, read it alongside this file.

## Detect

| Session has | Harness |
|---|---|
| `invoke_subagent` tool, or paths under `~/.gemini/` | Antigravity |
| `Task` tool and `subagent_type: poteto-agent` | Cursor |
| `Agent` tool and `subagent_type: pstack:poteto-agent`, or paths under `~/.claude/` | Claude Code |
| Neither, but a `Task`/`Agent`/`spawn` tool exists | Other. Spawn the closest general worker. First line of the kickoff is still `Read <poteto>/worker.md before anything else.` |

## Resolve pstack

`<pstack>` is the folder that holds `skills/` and `docs/`. `<poteto>` is `<pstack>/skills/poteto-mode`. Search in order and take the first hit that contains `skills/poteto-mode/SKILL.md`:

1. Workspace local copy: `.agents/plugins/pstack/` (preferred, self-contained in this starter kit).
2. `$PSTACK_ROOT` if set.
3. When running on Antigravity: `~/.gemini/config/plugins/pstack/`.
4. Newest `~/.cursor/plugins/cache/cursor-public/pstack/*/`.
5. A path under `~/.claude/plugins/` ending in `skills/poteto-mode/SKILL.md`. Walk up to the folder that holds `skills/` and `docs/`.
6. Newest `~/.cursor/plugins/` or `~/.claude/plugins/` copy whose plugin manifest has the highest `version`.

If several match at one step, take the highest `version` in `plugin.json`, `.antigravity-plugin/plugin.json`, `.cursor-plugin/plugin.json`, or `.claude-plugin/plugin.json`.

## Paths

| Role | Antigravity | Cursor | Claude Code | Other |
|---|---|---|---|---|
| This skill (local-first) | `.agents/skills/chief-of-staff/` | `.agents/skills/chief-of-staff/` | `.agents/skills/chief-of-staff/` | `.agents/skills/chief-of-staff/` |
| Project enable file | `AGENTS.md` or `GEMINI.md` | `.cursor/rules/chief-of-staff.mdc` | `CLAUDE.md` (or `AGENTS.md` if no `CLAUDE.md`) | `AGENTS.md` |
| Model roles | `.agents/rules/pstack-models.md` | `.agents/rules/pstack-models.md` | `.agents/rules/pstack-models.md` | `.agents/rules/pstack-models.md` |
| Slash command | `/chief-of-staff`, `/poteto-mode` | `/chief-of-staff`, `/poteto-mode` | `/chief-of-staff`, `/pstack:poteto-mode` | The harness's skill name. Prefix `pstack:` when that harness prefixes plugin skills |

## Spawn a worker

| Field | Antigravity | Cursor | Claude Code | Other |
|---|---|---|---|---|
| Tool | `invoke_subagent` | `Task` | `Agent` | The session's subagent tool |
| Type | `TypeName: "self"` for workers that write files, run commands, or use MCP; `"poteto-agent"` or `"research"` only for read-only work | `subagent_type: "poteto-agent"` | `subagent_type: "pstack:poteto-agent"` | The pstack poteto-agent type if listed, else a general worker with the kickoff below |
| Background | Omit (runs asynchronously by default) | `run_in_background: true` | Omit (default background) | Background if the schema has it |
| Model | Role line from `~/.gemini/config/pstack-models.md` (`inherit`, `flash_lite`, `flash`, `pro`; omit for `inherit-parent`/`auto`) | Role line from `pstack-models.mdc` | Map the Cursor slug with `<pstack>/docs/harness/claude-code.md` (`opus`/`sonnet`/`haiku`/`fable` + `effort`). Non-Claude slugs: omit `model` | Pass only values the schema lists |
| Cloud | `Workspace: "share"` or `"branch"` (isolated worktree); skip cloud-agent steps with one line | `environment: "cloud"` | `isolation: "worktree"` | Isolated worktree. Skip dashboard/cloud-agent steps with one line |
| Question tool | `ask_question` | `AskQuestion` | `AskUserQuestion` | Ask in the reply |
| Run another pstack skill | `read_file` on `<pstack>/skills/<name>/SKILL.md` and follow it | `Read <pstack>/skills/<name>/SKILL.md` and follow it | Same. The `Skill` tool refuses most pstack skills. Tell the operator `/pstack:<name>` | Same read-and-follow |

Kickoff, every harness:

```
Read <poteto>/worker.md before anything else.
```

Then the goal, the done-check, file pointers, the branch, and the path `<poteto>/SKILL.md`.

## Cursor-only steps

When a step needs Cursor Automations, Bugbot, Cursor cloud agents, or a built-in PR tool the harness lacks: write `Skipped in <harness>: <step>. <reason>.` and continue. Do not stop, ask, or retry. For a PR, use the forge CLI (`gh`, `glab`) instead of skipping.
