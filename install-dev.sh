#!/usr/bin/env bash
set -euo pipefail

# Developer environment installer
# Supports Arch Linux and Ubuntu WSL2

export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$HOME/.bun/bin:$PATH"

NVM_VERSION="v0.40.8"
GO_VERSION="${GO_VERSION:-}"

log() {
    printf '\n==> %s\n' "$1"
}

if [[ "$EUID" -eq 0 ]]; then
    echo "Run without sudo."
    exit 1
fi

# ------------------------------------------
# 1. System dependencies
# ------------------------------------------

source /etc/os-release

log "Installing dependencies"

case "$ID" in
    arch)
        sudo pacman -Syu --needed \
            git curl unzip tar ca-certificates \
            base-devel zsh
        ;;
    ubuntu)
        sudo apt-get update
        sudo apt-get install -y \
            git curl unzip tar ca-certificates \
            build-essential zsh
        ;;
    *)
        echo "Unsupported distribution: $ID"
        exit 1
        ;;
esac

# ------------------------------------------
# 2. Bun
# ------------------------------------------

log "Bun"

if [[ ! -x "$HOME/.bun/bin/bun" ]]; then
    curl -fsSL https://bun.com/install | bash
else
    echo "Already installed"
fi

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ------------------------------------------
# 3. NVM
# ------------------------------------------

log "NVM"

export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    curl -fsSL \
        "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" \
        | PROFILE=/dev/null bash
fi

source "$NVM_DIR/nvm.sh"

# Install and select Node.js LTS using NVM
nvm install --lts
nvm alias default 'lts/*'
nvm use default

# ------------------------------------------
# 4. goenv
# ------------------------------------------

log "goenv"

export GOENV_ROOT="$HOME/.goenv"

if [[ ! -e "$GOENV_ROOT" ]]; then
    git clone \
        https://github.com/go-nv/goenv.git \
        "$GOENV_ROOT"
else
    echo "Already installed; skipping"
fi

export PATH="$GOENV_ROOT/bin:$PATH"

# Optional: GO_VERSION=1.x.y ./install-dev.sh
if [[ -n "$GO_VERSION" ]]; then
    if ! "$GOENV_ROOT/bin/goenv" versions --bare | grep -Fxq "$GO_VERSION"; then
        "$GOENV_ROOT/bin/goenv" install "$GO_VERSION"
    fi
    "$GOENV_ROOT/bin/goenv" global "$GO_VERSION"
fi

# ------------------------------------------
# 5. uv
# ------------------------------------------

log "uv"

if [[ ! -x "$HOME/.local/bin/uv" ]]; then
    curl -LsSf https://astral.sh/uv/install.sh \
        | UV_NO_MODIFY_PATH=1 sh
else
    echo "Already installed"
fi

# ------------------------------------------
# 6. Oh My Zsh
# ------------------------------------------

log "Oh My Zsh"

ZSH_DIR="$HOME/.oh-my-zsh"

# Clone directly to preserve the Stow-managed .zshrc
if [[ ! -d "$ZSH_DIR" ]]; then
    git clone --depth=1 \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$ZSH_DIR"
else
    echo "Already installed"
fi

# ------------------------------------------
# 7. Oh My Zsh plugins
# ------------------------------------------

log "Zsh plugins"

PLUGIN_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}/plugins"
mkdir -p "$PLUGIN_DIR"

install_plugin() {
    local name="$1"
    local repo="$2"

    if [[ ! -d "$PLUGIN_DIR/$name" ]]; then
        git clone --depth=1 \
            "$repo" \
            "$PLUGIN_DIR/$name"
    else
        echo "$name already installed"
    fi
}

install_plugin \
    zsh-autosuggestions \
    https://github.com/zsh-users/zsh-autosuggestions

install_plugin \
    zsh-syntax-highlighting \
    https://github.com/zsh-users/zsh-syntax-highlighting

install_plugin \
    zsh-completions \
    https://github.com/zsh-users/zsh-completions

# ------------------------------------------
# 8. Done
# ------------------------------------------

log "Installation complete!"

echo "Bun:  $("$HOME/.bun/bin/bun" --version)"
echo "Node: $(node --version)"
echo "npm:  $(npm --version)"
echo "uv:   $("$HOME/.local/bin/uv" --version)"
echo "goenv installed in: $GOENV_ROOT"
echo
echo "Reload Zsh after configuring ~/.zshrc."
