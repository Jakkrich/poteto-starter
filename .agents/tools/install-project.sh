#!/usr/bin/env sh
set -eu

DEFAULT_SOURCE_REPO="https://github.com/Jakkrich/poteto-starter.git"
TARGET_DIR=""
SOURCE_REPO=""
BRANCH="main"
UPGRADE=0
SKIP_PSTACK_SYNC=0
HAS_SOURCE_ARG=0
HAS_BRANCH_ARG=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET_DIR="$2"; shift 2 ;;
    --source)
      SOURCE_REPO="$2"; HAS_SOURCE_ARG=1; shift 2 ;;
    --branch)
      BRANCH="$2"; HAS_BRANCH_ARG=1; shift 2 ;;
    --upgrade)
      UPGRADE=1; shift ;;
    --skip-pstack-sync)
      SKIP_PSTACK_SYNC=1; shift ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2 ;;
  esac
done

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
STARTER_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/../.." && pwd)

if [ "$UPGRADE" -eq 1 ] && [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$STARTER_ROOT"
fi
if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR=$(pwd)
fi

mkdir -p "$TARGET_DIR"
TARGET_FULL=$(CDPATH='' cd -- "$TARGET_DIR" && pwd)
HOME_FULL=$(CDPATH='' cd -- "$HOME" && pwd)
if [ "$TARGET_FULL" = "$HOME_FULL" ] || [ "$TARGET_FULL" = "/" ]; then
  echo "[ERROR] Refusing unsafe target dir: $TARGET_FULL (on-project installs only)" >&2
  exit 1
fi

MANIFEST_PATH="$TARGET_FULL/.agents/starter-kit.json"
if [ "$HAS_SOURCE_ARG" -eq 0 ] || [ -z "$SOURCE_REPO" ]; then
  if [ -f "$MANIFEST_PATH" ]; then
    parsed_src=$(sed -n 's/.*"sourceRepo"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MANIFEST_PATH" | head -n 1)
    [ -n "$parsed_src" ] && SOURCE_REPO="$parsed_src"
    if [ "$HAS_BRANCH_ARG" -eq 0 ]; then
      parsed_br=$(sed -n 's/.*"branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MANIFEST_PATH" | head -n 1)
      [ -n "$parsed_br" ] && BRANCH="$parsed_br"
    fi
  fi
  [ -z "$SOURCE_REPO" ] && SOURCE_REPO="$DEFAULT_SOURCE_REPO"
fi

if [ "$UPGRADE" -eq 1 ]; then
  if [ -d "$SOURCE_REPO" ]; then
    SRC_FULL=$(CDPATH='' cd -- "$SOURCE_REPO" && pwd)
    if [ "$SRC_FULL" = "$TARGET_FULL" ]; then
      echo "[ERROR] Upgrade source ($SRC_FULL) cannot equal target ($TARGET_FULL)." >&2
      exit 1
    fi
    if [ "$SKIP_PSTACK_SYNC" -eq 1 ]; then
      exec sh "$SRC_FULL/.agents/tools/install-project.sh" --target "$TARGET_FULL" --source "$SRC_FULL" --branch "$BRANCH" --skip-pstack-sync
    else
      exec sh "$SRC_FULL/.agents/tools/install-project.sh" --target "$TARGET_FULL" --source "$SRC_FULL" --branch "$BRANCH"
    fi
  fi

  TMP_CLONE=$(mktemp -d "${TMPDIR:-/tmp}/starter-kit-upgrade.XXXXXX")
  trap 'rm -rf "$TMP_CLONE"' EXIT INT TERM
  echo "Fetching latest agent-starter-kit from $SOURCE_REPO ($BRANCH) ..."
  git clone --depth 1 --branch "$BRANCH" "$SOURCE_REPO" "$TMP_CLONE"
  if [ "$SKIP_PSTACK_SYNC" -eq 1 ]; then
    sh "$TMP_CLONE/.agents/tools/install-project.sh" --target "$TARGET_FULL" --source "$SOURCE_REPO" --branch "$BRANCH" --skip-pstack-sync
  else
    sh "$TMP_CLONE/.agents/tools/install-project.sh" --target "$TARGET_FULL" --source "$SOURCE_REPO" --branch "$BRANCH"
  fi
  exit 0
fi

PROJECT_NAME=$(basename "$TARGET_FULL")

copy_dir_clean() {
  src="$1"
  dst="$2"
  if [ -d "$src" ]; then
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
  fi
}

merge_entry_file() {
  entry="$1"
  src="$STARTER_ROOT/$entry"
  dst="$TARGET_FULL/$entry"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    return
  fi

  tmp_out=$(mktemp "${TMPDIR:-/tmp}/entry-merge.XXXXXX")
  if grep -q '<!-- BEGIN AGENT-STARTER-KIT -->' "$dst" && grep -q '<!-- END AGENT-STARTER-KIT -->' "$dst"; then
    awk -v src_file="$src" '
      BEGIN {
        in_src = 0
        while ((getline line < src_file) > 0) {
          if (line ~ /<!-- BEGIN AGENT-STARTER-KIT -->/) in_src = 1
          if (in_src) block = (block == "" ? line : block "\n" line)
          if (line ~ /<!-- END AGENT-STARTER-KIT -->/) break
        }
        close(src_file)
        skip = 0
      }
      /<!-- BEGIN AGENT-STARTER-KIT -->/ {
        print block
        skip = 1
        next
      }
      /<!-- END AGENT-STARTER-KIT -->/ {
        skip = 0
        next
      }
      !skip { print }
    ' "$dst" > "$tmp_out"
    mv "$tmp_out" "$dst"
  elif grep -q '# AI Agent Instructions & Chief of Staff' "$dst"; then
    rm -f "$tmp_out"
    cp "$src" "$dst"
  else
    awk -v src_file="$src" '
      BEGIN {
        in_src = 0
        while ((getline line < src_file) > 0) {
          if (line ~ /<!-- BEGIN AGENT-STARTER-KIT -->/) in_src = 1
          if (in_src) print line
          if (line ~ /<!-- END AGENT-STARTER-KIT -->/) break
        }
        close(src_file)
        print ""
      }
      { print }
    ' "$dst" > "$tmp_out"
    mv "$tmp_out" "$dst"
  fi
}

if [ "$TARGET_FULL" != "$STARTER_ROOT" ]; then
  echo "Installing/updating starter-kit files into $TARGET_FULL ..."
  mkdir -p "$TARGET_FULL/.agents/rules"
  cp "$STARTER_ROOT/.agents/.gitignore" "$TARGET_FULL/.agents/.gitignore"
  cp "$STARTER_ROOT/.agents/rules/chief-of-staff.md" "$TARGET_FULL/.agents/rules/chief-of-staff.md"
  cp "$STARTER_ROOT/.agents/rules/pstack-antigravity.md" "$TARGET_FULL/.agents/rules/pstack-antigravity.md"

  copy_dir_clean "$STARTER_ROOT/.agents/skills/chief-of-staff" "$TARGET_FULL/.agents/skills/chief-of-staff"
  copy_dir_clean "$STARTER_ROOT/.agents/skills/make-bot-ui" "$TARGET_FULL/.agents/skills/make-bot-ui"
  copy_dir_clean "$STARTER_ROOT/.agents/docs/pstack-guide-th" "$TARGET_FULL/.agents/docs/pstack-guide-th"
  copy_dir_clean "$STARTER_ROOT/.agents/tools" "$TARGET_FULL/.agents/tools"

  if [ -f "$TARGET_FULL/.cursor/rules/chief-of-staff.mdc" ]; then
    rm -f "$TARGET_FULL/.cursor/rules/chief-of-staff.mdc"
    rmdir "$TARGET_FULL/.cursor/rules" 2>/dev/null || true
    rmdir "$TARGET_FULL/.cursor" 2>/dev/null || true
  fi

  if [ ! -f "$TARGET_FULL/AI_HANDOFF.md" ]; then
    sed "s|<project-name>|$PROJECT_NAME|g" "$STARTER_ROOT/.agents/skills/chief-of-staff/templates/AI_HANDOFF.md" > "$TARGET_FULL/AI_HANDOFF.md"
  fi

  if [ ! -f "$TARGET_FULL/.context/cos-board.md" ]; then
    mkdir -p "$TARGET_FULL/.context"
    TODAY=$(date +%Y-%m-%d)
    awk -v d="$TODAY" -v p="$PROJECT_NAME" '
      {
        gsub(/YYYY-MM-DD/, d)
        gsub(/<repo>/, p)
        print
      }
      /^## Latest summary$/ {
        print "Starter kit installed on-project. Waiting for project bootstrap (fill `AI_HANDOFF.md` and customize `.agents/skills/verify-project/SKILL.md`)."
      }
      /^\|---\|---\|---\|---\|---\|---\|---\|---\|$/ {
        print "| bootstrap-repo | Populate `AI_HANDOFF.md` and customize `verify-project` skill from real codebase inspection | `AI_HANDOFF.md` has accurate build/test commands & invariants; `verify-project` runs cleanly | Investigation | root | queued | Inspect codebase and bootstrap | — |"
      }
    ' "$STARTER_ROOT/.agents/skills/chief-of-staff/templates/cos-board.md" > "$TARGET_FULL/.context/cos-board.md"
  fi

  if [ ! -f "$TARGET_FULL/.agents/skills/verify-project/SKILL.md" ]; then
    mkdir -p "$TARGET_FULL/.agents/skills/verify-project"
    cp "$STARTER_ROOT/.agents/skills/verify-project/SKILL.md" "$TARGET_FULL/.agents/skills/verify-project/SKILL.md"
  fi

  if [ ! -f "$TARGET_FULL/.agents/rules/pstack-models.md" ]; then
    cp "$STARTER_ROOT/.agents/rules/pstack-models.md" "$TARGET_FULL/.agents/rules/pstack-models.md"
  fi

  merge_entry_file "AGENTS.md"
  merge_entry_file "CLAUDE.md"
  merge_entry_file "GEMINI.md"
fi

if [ "$SKIP_PSTACK_SYNC" -eq 0 ]; then
  sh "$TARGET_FULL/.agents/tools/sync-pstack.sh"
fi

STARTER_COMMIT="local"
if [ -d "$STARTER_ROOT/.git" ]; then
  STARTER_COMMIT=$(git -C "$STARTER_ROOT" rev-parse --short HEAD 2>/dev/null || echo "local")
fi

PSTACK_VER="pending-sync"
if [ -f "$TARGET_FULL/.agents/plugins/pstack/plugin.json" ]; then
  v=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$TARGET_FULL/.agents/plugins/pstack/plugin.json" | head -n 1)
  [ -n "$v" ] && PSTACK_VER="$v"
fi

UPDATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > "$MANIFEST_PATH" <<EOF
{
  "name": "agent-starter-kit",
  "sourceRepo": "$SOURCE_REPO",
  "branch": "$BRANCH",
  "starterKitCommit": "$STARTER_COMMIT",
  "pstackSource": "https://github.com/michael-denyer/pstack-claude.git",
  "pstackVersion": "$PSTACK_VER",
  "updatedAt": "$UPDATED_AT"
}
EOF

echo "[OK] agent-starter-kit ready on-project at $TARGET_FULL (commit: $STARTER_COMMIT, pstack: $PSTACK_VER)"
