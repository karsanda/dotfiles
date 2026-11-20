#!/bin/sh
# Symlink these dotfiles into place. Safe to re-run.
#   ./install.sh          link configs, install oh-my-zsh + plugins if missing
#   ./install.sh --brew   also install the Brewfile packages
set -eu

REPO=$(cd "$(dirname "$0")" && pwd)
CONFIG="$HOME/.config"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
WITH_BREW=0
[ "${1:-}" = "--brew" ] && WITH_BREW=1

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux) OS=linux ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

say() { printf '==> %s\n' "$*"; }

# link SRC DEST: back up whatever is at DEST (unless it's already our link), then symlink
link() {
  src="$REPO/$1"
  dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    # keep the path relative to $HOME so same-named files (e.g. config.toml) don't collide
    saved="$BACKUP/${dest#"$HOME"/}"
    mkdir -p "$(dirname "$saved")"
    mv "$dest" "$saved"
    say "backed up $dest -> $saved"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  say "linked $dest"
}

# --- Per-machine files (untracked) ---
# keep [user] name/email out of the repo: copy it from an existing real ~/.gitconfig
if [ ! -e "$HOME/.gitconfig.local" ]; then
  if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ] && grep -q '^\[user\]' "$HOME/.gitconfig"; then
    awk '/^\[/{keep = ($0 == "[user]")} keep' "$HOME/.gitconfig" > "$HOME/.gitconfig.local"
    say "wrote ~/.gitconfig.local from your existing [user] section"
  else
    printf '[user]\n\tname = \n\temail = \n' > "$HOME/.gitconfig.local"
    say "TODO: fill in name/email in ~/.gitconfig.local"
  fi
fi
if [ ! -e "$HOME/.zshrc.local" ]; then
  printf '# Machine-specific zsh config (untracked). Sourced near the end of ~/.zshrc.\n' > "$HOME/.zshrc.local"
  say "created empty ~/.zshrc.local"
fi

# --- Ghostty per-OS file ---
ln -sfn "$OS.ghostty" "$REPO/ghostty/platform.ghostty"

# --- Links ---
link ghostty                 "$CONFIG/ghostty"
link zsh/.zshrc              "$HOME/.zshrc"
link starship/starship.toml  "$CONFIG/starship.toml"
link atuin/config.toml       "$CONFIG/atuin/config.toml"
link git/.gitconfig          "$HOME/.gitconfig"
link nvim                    "$CONFIG/nvim"
link tmux                    "$CONFIG/tmux"
link lazygit/config.yml      "$CONFIG/lazygit/config.yml"
link bat                     "$CONFIG/bat"
link mise/config.toml        "$CONFIG/mise/config.toml"

# --- Oh My Zsh + plugins ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  say "installing oh-my-zsh"
  KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    say "installing $plugin"
    git clone --depth 1 "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# --- Packages ---
if [ "$WITH_BREW" = 1 ]; then
  command -v brew >/dev/null || { echo "Homebrew not found: install it from https://brew.sh first" >&2; exit 1; }
  brew bundle --file "$REPO/Brewfile"
fi
if command -v bat >/dev/null; then
  bat cache --build >/dev/null && say "rebuilt bat theme cache"
fi

# --- macOS: a config in Application Support loads after ~/.config and overrides it ---
if [ "$OS" = macos ]; then
  for f in "$HOME/Library/Application Support/com.mitchellh.ghostty/config" \
           "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"; do
    [ -s "$f" ] && say "WARNING: $f exists and overrides this repo's Ghostty config; consider removing it"
  done
fi

say "done. Open a new terminal (or: exec zsh)."
