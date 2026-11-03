#!/usr/bin/env bash
set -euo pipefail

# Links the managed agent config into ~/.agents, and points every agent that
# reads global instructions at the single copy in this repo.
#
# stow cannot do this: a hidden package name is silently mangled (stow strips
# the dot and links the contents into $HOME/skills), and stow always flattens
# package contents into the target root, so it cannot produce one symlink per
# skill directory. Unmanaged skills under ~/.agents/skills are left alone.

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$DOTFILES_DIR/.agents"
TARGET="$HOME/.agents"

mkdir -p "$TARGET/skills"

for path in \
    "$TARGET/AGENTS.md" \
    "$HOME/AGENTS.md" \
    "$HOME/.codex/AGENTS.md" \
    "$HOME/.pi/agent/AGENTS.md" \
    "$HOME/.config/opencode/AGENTS.md" \
    "$HOME/.claude/CLAUDE.md"
do
    if [[ -e "$path" && ! -L "$path" ]]; then
        echo "Refusing to overwrite $path: not a symlink" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$path")"
    ln -sfn "$AGENTS_DIR/AGENTS.md" "$path"
    echo "Linked: $path"
done

for skill in "$AGENTS_DIR"/skills/*/; do
    name="$(basename "$skill")"
    ln -sfn "${skill%/}" "$TARGET/skills/$name"
    echo "Linked: $TARGET/skills/$name"
done
