# Shared zsh config (Linux + macOS). Machine-specific bits go in ~/.zshrc.local (untracked).

export XDG_CONFIG_HOME="$HOME/.config"

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
# prompt is drawn by starship (see bottom of file)
ZSH_THEME=""
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting)

# brew first so plugins (fzf) can find their binaries
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$_brew" ]; then eval "$("$_brew" shellenv)"; break; fi
done
unset _brew

source $ZSH/oh-my-zsh.sh

# --- Tooling ---
eval "$(mise activate zsh)"

export PATH="$HOME/.local/bin:$PATH"
export BUILDX_NO_DEFAULT_ATTESTATIONS=1

# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# --- Modern CLI ---
export BAT_THEME="tokyonight_night"
# TokyoNight colors for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
  --color=bg+:#283457,bg:#16161e,border:#27a1b9,fg:#c0caf5,gutter:#16161e \
  --color=header:#ff9e64,hl:#2ac3de,hl+:#2ac3de,info:#545c7e,marker:#ff007c \
  --color=pointer:#ff007c,prompt:#2ac3de,query:#c0caf5:regular,spinner:#ff007c"

alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
alias cat='bat --paging=never'
alias lg='lazygit'
alias vim='nvim'
alias vi='nvim'
# git, crontab, sudo -e, etc.
export EDITOR='nvim'
export VISUAL='nvim'

# --- Machine-specific (work tokens, SSH agent, ...) ---
[ -r ~/.zshrc.local ] && source ~/.zshrc.local

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
# Ctrl+R = atuin search; up arrow keeps normal history
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(starship init zsh)"
