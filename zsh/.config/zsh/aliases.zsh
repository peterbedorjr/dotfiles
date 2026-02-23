# Navigation
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --level=2 --icons"
alias la="eza -a --icons --group-directories-first"

# File viewing
alias cat="bat --paging=never"
alias catp="bat"

# Git
alias lg="lazygit"
alias glog="git log --oneline --graph --decorate -20"

# Directory jumping (zoxide)
alias cd="z"

# Editors
alias vim="nvim"
alias zshrc="nvim ~/dotfiles/zsh/.zshrc"
alias ghosttyrc="nvim ~/dotfiles/ghostty/.config/ghostty/config"

# System
alias ports="lsof -i -P -n | grep LISTEN"
alias path='echo $PATH | tr ":" "\n"'

# Laravel Sail
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'

# SLM Docker Management
alias slm='/Users/peterbedorjr/code/slm/app/slm-docker/slm'
