# ── Modern CLI Replacements (conditional) ─────────────────
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --group-directories-first --git"
  alias lt="eza --tree --level=2 --icons"
  alias la="eza -a --icons --group-directories-first"
fi

if command -v bat &>/dev/null; then
  alias cat="bat --paging=never"
  alias catp="bat"
fi

if command -v rg &>/dev/null; then
  alias grep="rg"
fi

if command -v fd &>/dev/null; then
  alias find="fd"
fi

if command -v zoxide &>/dev/null; then
  alias cd="z"
fi

# ── Git ───────────────────────────────────────────────────
alias lg="lazygit"
alias glog="git log --oneline --graph --decorate -20"

# ── Editors ───────────────────────────────────────────────
alias vim="nvim"
alias zshrc="nvim ~/dotfiles/zsh/.zshrc"
alias ghosttyrc="nvim ~/dotfiles/ghostty/.config/ghostty/config"

# ── System ────────────────────────────────────────────────
alias ports="lsof -i -P -n | grep LISTEN"
alias path='echo $PATH | tr ":" "\n"'
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# ── Laravel / PHP ─────────────────────────────────────────
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias a="php artisan"

# ── Project-specific ──────────────────────────────────────
alias slm='/Users/peterbedorjr/code/slm/app/slm-docker/slm'
