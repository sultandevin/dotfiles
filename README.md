# dotfiles

Arch Linux + Ubuntu (WSL2) dotfiles, stowed into `$HOME`.

## Install order

Run these in order on a fresh machine. `install.sh` refuses to run before
`install-dev.sh`, because it stows a `~/.zshrc` that sources Oh My Zsh.

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles

./install-dev.sh    # system packages, bun, nvm, goenv, uv, oh-my-zsh, zsh plugins
./install.sh        # distro packages, bob/neovim, then stow
```

`install.sh` previews every Stow operation and asks before applying. Any file
that already exists at a target path is moved to
`~/.dotfiles-backup/<timestamp>/` first, so plain `stow` never aborts on
existing dotfiles.

Stow runs with `--no-folding`, so `~/.codex` and `~/.config/lazygit` stay real
directories with only the tracked file symlinked. Without it, Stow would turn
`~/.codex` into a symlink and Codex runtime state would be written into this
repo.

## Packages

`packages/arch.txt` and `packages/ubuntu.txt` are the source of truth for the
distro packages `install.sh` installs. Add a line to the relevant file rather
than a flag to the script.

`arch.txt` is a full machine manifest (GUI libs, valkey, postgres libs), not a
minimal CLI set — expect a large install on a fresh Arch box.

## Secrets

Tokens are not tracked. `.zshrc` sources `~/.config/secrets/env.sh` if it
exists, so create it after cloning:

```sh
mkdir -p ~/.config/secrets
$EDITOR ~/.config/secrets/env.sh
chmod 600 ~/.config/secrets/env.sh
```

```sh
export OPENCODE_SERVER_PASSWORD="..."
export GITLAB_TOKEN="..."
```

## Packages (stow)

| Package   | Target                                  |
| --------- | --------------------------------------- |
| `zsh`     | `~/.zshrc`                              |
| `tmux`    | `~/.config/tmux/tmux.conf`              |
| `git`     | `~/.gitconfig`                          |
| `lazygit` | `~/.config/lazygit/config.yml`          |
| `codex`   | `~/.codex/config.toml`                  |

Only portable files from `~/.codex` are tracked. Runtime state (sqlite DBs,
sessions, logs, `auth.json`, plugin caches) stays untracked.

`~/.agents` is intentionally not tracked: it is an Iris-managed install tree
of third-party skills with absolute paths and its own symlinks. Rebuild it by
re-running the Iris installer.

## Neovim

Neovim is installed and version-managed by [bob](https://github.com/MordechaiHadad/bob),
not by a distro `neovim` package. `install.sh` selects `stable` if bob has no
version selected yet, and leaves an existing selection alone.

Bob's shim directory is on `PATH` via `.zshrc`:
`$HOME/.local/share/bob/nvim-bin`.

## Manual dependencies

Not stowed, tracked elsewhere:

- `~/.config/nvim` — [sultandevin/neovim](https://github.com/sultandevin/neovim)
- `~/.config/texlive/env.sh` — sourced by `.zshrc` if present
