# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick find file by name
ff() {
  fd --type f --hidden --exclude .git "$1"
}

# Quick find directory by name
fdir() {
  fd --type d --hidden --exclude .git "$1"
}

# Preview files with fzf + bat
fzp() {
  fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}

# Git log with fzf
gflog() {
  git log --oneline --graph --decorate --color=always | fzf --ansi --no-sort --preview 'git show --color=always {2}'
}
