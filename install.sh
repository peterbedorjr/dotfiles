#!/usr/bin/env bash
set -euo pipefail

step() { echo "▶ $*"; }
success() { echo "✓ $*"; }

step "Installing dotfiles"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install from Brewfile
step "Installing brew packages..."
brew bundle --file="$(dirname "$0")/Brewfile"
success "Brew packages installed"

# Install Node via fnm
if command -v fnm &>/dev/null; then
  step "Installing Node via fnm..."
  eval "$(fnm env)"
  fnm install --lts
  fnm default lts-latest
  success "Node $(fnm current) installed"
fi

# Stow packages
step "Stowing dotfiles..."
cd "$(dirname "$0")"

packages=(zsh ghostty starship nvim zellij git bat lazygit)
for pkg in "${packages[@]}"; do
  echo "  stow $pkg"
  stow -v --restow "$pkg"
done
success "Dotfiles stowed"

# Secrets template
if [[ ! -f "$HOME/.secrets.zsh" ]]; then
  step "Creating ~/.secrets.zsh template..."
  cat > "$HOME/.secrets.zsh" << 'SECRETS'
# API Keys and Secrets — NOT tracked in git
# export GEMINI_API_KEY=""
# export JIRA_API_TOKEN=""
# export JIRA_AUTH_TYPE=""
SECRETS
  echo "  Edit ~/.secrets.zsh to add your API keys"
fi

success "Done! Restart your shell or run: exec zsh"
