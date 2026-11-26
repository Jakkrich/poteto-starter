#!/usr/bin/env sh
set -eu

REINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --reinstall|-Reinstall) REINSTALL=1 ;;
  esac
done

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
AGENTS_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
PLUGINS_DIR="$AGENTS_DIR/plugins"
PSTACK_DIR="$PLUGINS_DIR/pstack"
CACHE_DIR="$AGENTS_DIR/.cache/pstack-claude"
REPO_URL="https://github.com/michael-denyer/pstack-claude.git"
BRANCH="main"

mkdir -p "$PLUGINS_DIR" "$(dirname "$CACHE_DIR")"
rm -rf "$PLUGINS_DIR/.git"

if [ "$REINSTALL" -eq 0 ] && [ -d "$CACHE_DIR/.git" ]; then
  echo "Updating pstack-claude cache in $CACHE_DIR ..."
  git -C "$CACHE_DIR" pull --ff-only origin "$BRANCH"
else
  rm -rf "$CACHE_DIR"
  echo "Cloning pstack-claude (sparse checkout) from $REPO_URL ($BRANCH) ..."
  git clone --depth 1 --branch "$BRANCH" --filter=blob:none --no-checkout "$REPO_URL" "$CACHE_DIR"
  git -C "$CACHE_DIR" sparse-checkout init --cone
  git -C "$CACHE_DIR" sparse-checkout set plugins/pstack VERSION
  git -C "$CACHE_DIR" checkout "$BRANCH"
fi

SOURCE_PSTACK="$CACHE_DIR/plugins/pstack"
if [ ! -f "$SOURCE_PSTACK/skills/poteto-mode/SKILL.md" ]; then
  echo "[ERROR] Expected plugins/pstack/skills/poteto-mode/SKILL.md not found in $CACHE_DIR" >&2
  exit 1
fi

rm -rf "$PSTACK_DIR"
cp -R "$SOURCE_PSTACK" "$PSTACK_DIR"

if [ -f "$PSTACK_DIR/.antigravity-plugin/plugin.json" ] && [ ! -f "$PSTACK_DIR/plugin.json" ]; then
  cp "$PSTACK_DIR/.antigravity-plugin/plugin.json" "$PSTACK_DIR/plugin.json"
fi

rm -f \
  "$PSTACK_DIR/hooks.json" \
  "$PSTACK_DIR/hooks/hooks.json" \
  "$PSTACK_DIR/hooks/codex-hooks.json" \
  "$PSTACK_DIR/hooks/copilot-hooks.json"

VER="unknown"
if [ -f "$CACHE_DIR/VERSION" ]; then
  VER=$(tr -d ' \r\n' < "$CACHE_DIR/VERSION")
fi
SHA=$(git -C "$CACHE_DIR" rev-parse --short HEAD)
echo "[OK] pstack-claude (version $VER, commit $SHA) ready at $PstackDir"
