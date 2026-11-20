# dotfiles

My terminal setup for Linux and macOS, all in TokyoNight Night:

| Tool | What's configured |
|---|---|
| Ghostty | theme, Cascadia Code font, padding, shell integration, keybinds (per-OS) |
| zsh | Oh My Zsh with autosuggestions, syntax highlighting, fzf, eza/bat aliases |
| starship | prompt |
| atuin | Ctrl+R history search |
| git | aliases, delta pager |
| Neovim | LazyVim |
| tmux | Ctrl+a prefix, vi copy mode, theme |
| lazygit, bat | theme |
| mise | language runtimes |

## Install

### macOS
```sh
xcode-select --install
# install Homebrew: https://brew.sh
git clone https://github.com/karsanda/dotfiles ~/Workspace/dotfiles
cd ~/Workspace/dotfiles && ./install.sh --brew
```

### Linux
```sh
git clone https://github.com/karsanda/dotfiles ~/Workspace/dotfiles
cd ~/Workspace/dotfiles && ./install.sh          # add --brew if Homebrew is installed
```

`install.sh` symlinks each config into `~` / `~/.config`. Anything already there gets moved to `~/.dotfiles-backup/<timestamp>/` first. You can safely run it again.

## Per-machine files (not in the repo)

| File | Use |
|---|---|
| `~/.gitconfig.local` | `[user]` name and email (copied from your old `~/.gitconfig` on first run) |
| `~/.zshrc.local` | tokens, SSH agent, anything specific to one machine |
| `ghostty/local.ghostty` | Ghostty tweaks for one machine |

`ghostty/platform.ghostty` is a symlink to `linux.ghostty` or `macos.ghostty`. `install.sh` creates it.
