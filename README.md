# agent-starter-kit (`poteto-starter`)

Self-contained, **on-project only** agentic development starter kit combining **Chief of Staff** (`chief-of-staff`), **`pstack-claude`** (`michael-denyer/pstack-claude`), structured project governance (`AI_HANDOFF.md`), and a per-repo task board (`.context/cos-board.md`).

Designed for **Antigravity (`agy`)**, **Codex**, **Claude Code**, and **Grok (`Grok Build` / `Grok Bot`)** — with **zero `.cursor/` directory** and **zero global plugin installs**.

---

## Repository Structure

```text
agent-starter-kit/
├── FOR_AGENTS.md                    # Exact install & upgrade runbook for AI agents
├── AGENTS.md                        # Entry instructions (Codex / Antigravity / Grok)
├── CLAUDE.md                        # Entry instructions (Claude Code)
├── GEMINI.md                        # Entry instructions (Antigravity / Gemini)
├── AI_HANDOFF.md                    # Architecture, repo invariants, pitfalls, and change log
├── .context/
│   └── cos-board.md                 # Active / Archive Chief of Staff board + latest summary
└── .agents/
    ├── .gitignore                   # Ignores plugins/, .cache/, and .backup/ so synced pstack stays out of git
    ├── starter-kit.json             # Provenance manifest (sourceRepo, commit, pstackVersion)
    ├── assets/
    │   └── logo.png                 # Official cursor/plugins pstack logo applied by sync-pstack
    ├── docs/
    │   └── pstack-guide-th/         # Thai guide preserved outside synced pstack folder
    ├── rules/
    │   ├── chief-of-staff.md        # Always-on Chief of Staff rule (replaces old .cursor/*.mdc)
    │   ├── pstack-antigravity.md    # Antigravity adapter notes referencing agy-tools.md
    │   └── pstack-models.md         # Cross-harness per-role model sheet (default: inherit-parent)
    ├── tools/
    │   ├── install-project.ps1      # On-project installer & idempotent upgrader (Windows)
    │   ├── install-project.sh       # On-project installer & idempotent upgrader (POSIX)
    │   ├── upgrade-starter-kit.bat  # One-command Windows upgrader wrapper
    │   ├── sync-pstack.ps1          # Sparse-clones/updates michael-denyer/pstack-claude
    │   ├── sync-pstack.sh           # POSIX counterpart for sync-pstack
    │   ├── sync-pstack.bat
    │   ├── sync-chief-of-staff.ps1  # Syncs upstream Chief-of-Staff SKILL.md (skips *.mdc)
    │   ├── sync-chief-of-staff.bat
    │   └── sync-all.bat             # Syncs pstack-claude + chief-of-staff
    ├── plugins/
    │   └── pstack/                  # Synced from michael-denyer/pstack-claude (gitignored)
    └── skills/
        ├── chief-of-staff/          # Chief of Staff skill + multi-harness map (harness.md)
        ├── make-bot-ui/             # Grok Bot webhook + Tailscale UI skill
        └── verify-project/          # Customizable project verification skill template
```

---

## สั่ง AI ติดตั้งลงโปรเจกต์แบบ On-Project เท่านั้น (Install via AI)

เปิดโปรเจกต์ปลายทางใน **Antigravity**, **Codex**, **Claude Code**, หรือ **Grok** แล้วส่ง Prompt นี้ให้ AI (ไม่ต้องลง global plugin ใดๆ):

```text
ติดตั้ง agent-starter-kit จาก https://github.com/Jakkrich/poteto-starter.git ลงในโปรเจกต์นี้แบบ on-project เท่านั้น:
1. อ่าน FOR_AGENTS.md ใน repo ต้นทางก่อน
2. ห้ามติดตั้งอะไรลง global (~/.gemini, ~/.claude, ~/.codex, ~/.grok, ~/.agents, ~/.cursor) เด็ดขาด
3. รันสคริปต์ .agents/tools/install-project.ps1 (Windows) หรือ install-project.sh (macOS/Linux/WSL) เพื่อติดตั้งชุด starter kit และ sync pstack-claude ลงที่ .agents/plugins/pstack/
4. วิเคราะห์ codebase จริงของโปรเจกต์นี้แล้ว bootstrap AI_HANDOFF.md, .agents/skills/verify-project/SKILL.md และปิดงาน bootstrap-repo บน .context/cos-board.md พร้อมรัน verify-project 1 รอบ
```

---

## สั่ง AI อัปเกรดตาม `agent-starter-kit` ล่าสุด (Upgrade via AI)

เมื่อมีการอัปเดตใน `agent-starter-kit` หรือ `pstack-claude` เปิดโปรเจกต์เดิมแล้วสั่ง AI ด้วย Prompt นี้:

```text
อัปเกรด agent-starter-kit และ pstack-claude ในโปรเจกต์นี้ตาม repo ล่าสุดแบบ on-project:
1. รัน .\.agents\tools\upgrade-starter-kit.bat -NoPause (Windows) หรือ sh .agents/tools/install-project.sh --upgrade (POSIX)
   (หากโปรเจกต์นี้ยังเป็นเวอร์ชันเก่าที่ไม่มี upgrade-starter-kit.bat ให้ทำตามขั้นตอน Fresh Install ใน FOR_AGENTS.md ของ https://github.com/Jakkrich/poteto-starter.git)
2. ตรวจสอบว่า AI_HANDOFF.md, .context/cos-board.md, .agents/skills/verify-project/SKILL.md, .agents/rules/pstack-models.md และกฎเฉพาะโปรเจกต์ใน AGENTS.md / CLAUDE.md / GEMINI.md ยังอยู่ครบไม่ถูกเขียนทับ
3. สรุปเวอร์ชันใน .agents/starter-kit.json และผลตรวจให้ดู
```

---

## Manual CLI Usage (Optional)

- **Sync only `pstack-claude`:** `.\.agents\tools\sync-pstack.bat` (Windows) or `sh .agents/tools/sync-pstack.sh` (POSIX)
- **Upgrade starter kit + `pstack-claude`:** `.\.agents\tools\upgrade-starter-kit.bat` (Windows) or `sh .agents/tools/install-project.sh --upgrade` (POSIX)
- **Sync `chief-of-staff` + `pstack-claude` inside starter kit:** `.\.agents\tools\sync-all.bat`

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
