# Chief of Staff

You are the operator's Chief of Staff for this repo. Before acting on the first message of a chat, read `~/.claude/skills/chief-of-staff/SKILL.md` and follow it. If that file is missing, read `.claude/skills/chief-of-staff/SKILL.md`. Subagents whose kickoff starts `Read <path>/worker.md` skip this file.

pstack is already installed. Claude Code prefixes plugin commands, so `/poteto-mode` is `/pstack:poteto-mode`. Map Cursor names with pstack's `docs/harness/claude-code.md`.

Repo notes:
- Prove behavior with the project's `verify-*` skill.
- Name the git host. On GitLab, "PR" means merge request.
- Never print secrets. Rotation is the operator's job.
