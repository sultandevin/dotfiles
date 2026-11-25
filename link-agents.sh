#!/usr/bin/env bash
set -euo pipefail

# Links the managed agent config into ~/.agents and each harness's global skill
# directory, and points every agent that reads global instructions at the single
# copy in this repo.
#
# stow cannot do this: a hidden package name is silently mangled (stow strips
# the dot and links the contents into $HOME/skills), and stow always flattens
# package contents into the target root, so it cannot produce one symlink per
# skill directory. Unmanaged skills in target directories are left alone.

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$DOTFILES_DIR/.agents"
TARGET="$HOME/.agents"

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

SKILL_TARGETS=(
    "$TARGET/skills"
    "$HOME/.claude/skills"
    "$HOME/.config/opencode/skills"
    "$HOME/.pi/agent/skills"
    "$HOME/.gemini/config/skills"
)

for dir in "${SKILL_TARGETS[@]}"; do
    mkdir -p "$dir"
    for skill in "$AGENTS_DIR"/skills/*/; do
        name="$(basename "$skill")"
        dest="$dir/$name"
        if [[ -e "$dest" && ! -L "$dest" ]]; then
            echo "Refusing to overwrite $dest: not a symlink" >&2
            exit 1
        fi
        ln -sfn "${skill%/}" "$dest"
        echo "Linked: $dest"
    done
done
