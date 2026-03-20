# ── Oh My Zsh ─────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — starship handles the prompt

plugins=(
  git
  colored-man-pages
  command-not-found
  zsh-autosuggestions
  # zsh-autocomplete
)

# ── Custom completions ────────────────────────────────────
fpath=(~/.zfunc $fpath)

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# ── Emacs mode + macOS-style keybinds ────────────────────
bindkey -e

# Option+Left/Right — move by word
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Option+Backspace — delete word behind cursor
bindkey '^[^?' backward-kill-word

# Ctrl+A / Ctrl+E — start/end of line
# (emacs mode has these by default, listed for clarity)

# Ctrl+U — delete to start of line
bindkey '^U' backward-kill-line

# Ctrl+K — delete to end of line
bindkey '^K' kill-line

# Ctrl+W — delete word behind cursor
bindkey '^W' backward-kill-word

# ── Homebrew (macOS only) ─────────────────────────────────
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Modular Config ────────────────────────────────────────
source ~/.config/zsh/exports.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh
source ~/.config/zsh/project.zsh

# ── Secrets (not tracked in git) ──────────────────────────
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

# ── fnm (fast Node version manager) ──────────────────────
eval "$(fnm env)"
command -v fnm &>/dev/null && eval "$(fnm completions --shell zsh)"

# ── Bun ───────────────────────────────────────────────────
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── fzf ───────────────────────────────────────────────────
source <(fzf --zsh)
if [[ -f /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh ]]; then
  source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
elif [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab/fzf-tab.plugin.zsh
fi

# ── Tool Inits ────────────────────────────────────────────
eval "$(zoxide init zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
eval "$(starship init zsh)"

# ── Syntax Highlighting (must be near end) ────────────────
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
