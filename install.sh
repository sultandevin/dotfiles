#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Cross-distro Dotfiles Installer
# Supports Arch Linux and Ubuntu (WSL2)
#
# Run ./install-dev.sh first. This script
# requires Oh My Zsh and refuses to stow a
# ~/.zshrc that cannot load it.
# ==========================================

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux git lazygit codex)
BOB_VERSION="${BOB_VERSION:-4.2.0}"

# ------------------------------------------
# 1. Detect Linux distribution
# ------------------------------------------

if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot detect Linux distribution."
    exit 1
fi

source /etc/os-release

echo "Detected distribution: ${PRETTY_NAME:-$ID}"

# ------------------------------------------
# 2. Check shell prerequisites
# ------------------------------------------

echo
echo "Checking shell prerequisites..."

if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    echo "Error: Oh My Zsh is not installed."
    echo "Run ./install-dev.sh first, then re-run this script."
    exit 1
fi

echo "Found: $HOME/.oh-my-zsh"

# ------------------------------------------
# 3. Install dependencies from packages/
# ------------------------------------------

read_package_list() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: Missing package list: $file" >&2
        return 1
    fi

    grep -vE '^[[:space:]]*(#|$)' "$file"
}

install_dependencies() {
    local package_file="$DOTFILES_DIR/packages/$ID.txt"
    local packages=()

    mapfile -t packages < <(read_package_list "$package_file")

    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: No packages listed in $package_file"
        exit 1
    fi

    echo
    echo "Installing ${#packages[@]} packages from packages/$ID.txt..."

    case "$ID" in
        arch)
            sudo pacman -Syu --needed "${packages[@]}"
            ;;

        ubuntu)
            sudo apt-get update
            sudo apt-get install -y "${packages[@]}"
            ;;

        *)
            echo "Unsupported distribution: $ID"
            exit 1
            ;;
    esac
}

install_dependencies

# ------------------------------------------
# 4. Neovim via bob
# ------------------------------------------

install_neovim() {
    local tmp

    if ! command -v bob >/dev/null 2>&1; then
        case "$ID" in
            ubuntu)
                echo
                echo "Installing bob (neovim version manager)..."

                tmp="$(mktemp -d)"
                curl -fsSL \
                    "https://github.com/MordechaiHadad/bob/releases/download/v${BOB_VERSION}/bob-linux-x86_64.zip" \
                    -o "$tmp/bob.zip"
                unzip -q "$tmp/bob.zip" -d "$tmp"
                sudo install -m 755 "$tmp/bob-linux-x86_64/bob" /usr/local/bin/bob
                rm -rf "$tmp"
                ;;

            *)
                echo "Error: bob is not installed for $ID."
                echo "Add it to packages/$ID.txt or install it manually."
                exit 1
                ;;
        esac
    fi

    if [[ -f "$HOME/.local/share/bob/used" ]]; then
        echo "bob already managing neovim: $(cat "$HOME/.local/share/bob/used")"
    else
        echo
        echo "Selecting a neovim release with bob..."
        bob use stable
    fi
}

install_neovim

# ------------------------------------------
# 5. Check dotfiles packages
# ------------------------------------------

cd "$DOTFILES_DIR"

echo
echo "Checking dotfiles packages..."

for package in "${PACKAGES[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
        echo "Error: Missing package directory: $package"
        exit 1
    fi
done

# ------------------------------------------
# 6. Preview symlinks
# ------------------------------------------

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo
echo "Previewing Stow operations..."

if ! stow --simulate --verbose --no-folding \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    "${PACKAGES[@]}"
then
    echo
    echo "Existing files detected."
    echo "They will be backed up to: $BACKUP_DIR"
fi

# ------------------------------------------
# 7. Confirm installation
# ------------------------------------------

echo
read -r -p "Apply dotfiles? [y/N] " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# ------------------------------------------
# 8. Back up conflicting files
# ------------------------------------------

for package in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' path; do
        rel="${path#"$DOTFILES_DIR/$package/"}"
        target="$HOME/$rel"

        if [[ -e "$target" && ! -L "$target" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            mv "$target" "$BACKUP_DIR/$rel"
            echo "Backed up: $target"
        fi
    done < <(find "$DOTFILES_DIR/$package" -type f -print0)
done

# ------------------------------------------
# 9. Apply symlinks
# ------------------------------------------

echo
echo "Applying dotfiles..."

stow --verbose --no-folding \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    "${PACKAGES[@]}"

# ------------------------------------------
# 10. Verify configuration
# ------------------------------------------

echo
echo "Verifying symlinks..."

for config in \
    "$HOME/.zshrc" \
    "$HOME/.config/tmux/tmux.conf" \
    "$HOME/.config/lazygit/config.yml" \
    "$HOME/.codex/config.toml" \
    "$HOME/.gitconfig"
do
    if [[ -e "$config" ]]; then
        echo "Found: $config"
    else
        echo "Missing: $config"
    fi
done

if [[ -f "$HOME/.config/secrets/env.sh" ]]; then
    echo "Found: $HOME/.config/secrets/env.sh"
else
    echo "Missing: $HOME/.config/secrets/env.sh (create it for GitLab/opencode tokens)"
fi

echo
echo "Dotfiles installation complete!"
echo "Restart your shell to load configurations."
