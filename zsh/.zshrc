# ── Oh My Zsh ─────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — starship handles the prompt

plugins=(
  git
  colored-man-pages
  command-not-found
)

source $ZSH/oh-my-zsh.sh

# ── Homebrew ──────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── Modular Config ────────────────────────────────────────
source ~/.config/zsh/exports.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh

# ── Secrets (not tracked in git) ──────────────────────────
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

# ── fnm (fast Node version manager) ──────────────────────
eval "$(fnm env)"
eval "$(fnm completions --shell zsh)"

# ── Bun ───────────────────────────────────────────────────
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── fzf ───────────────────────────────────────────────────
source <(fzf --zsh)

# ── Tool Inits ────────────────────────────────────────────
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
