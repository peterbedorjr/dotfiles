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

# Prune local branches that are gone from remote
git-prune-local() {
  git fetch -p && git branch -vv | grep gone | awk '{print $1}' | xargs git branch -d
}

# DNS lookup
digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# Remove host from known_hosts
removehost() {
  sed -i "" "/^$1/d" ~/.ssh/known_hosts
}
