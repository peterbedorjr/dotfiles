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

# ── NVM (lazy-loaded for fast startup) ────────────────────
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm node npm npx
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}
node() { nvm use default >/dev/null 2>&1; command node "$@"; }
npm() { nvm use default >/dev/null 2>&1; command npm "$@"; }
npx() { nvm use default >/dev/null 2>&1; command npx "$@"; }

# ── Bun ───────────────────────────────────────────────────
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── fzf ───────────────────────────────────────────────────
source <(fzf --zsh)

# ── Tool Inits ────────────────────────────────────────────
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
