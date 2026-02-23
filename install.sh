#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing dotfiles"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install tools
echo "==> Installing brew packages..."
brew install \
  stow \
  starship \
  zoxide \
  git-delta \
  bat \
  eza \
  fzf \
  fd \
  ripgrep \
  lazygit \
  neovim

# Stow packages
echo "==> Stowing dotfiles..."
cd "$(dirname "$0")"

packages=(zsh ghostty starship nvim zellij git bat lazygit)
for pkg in "${packages[@]}"; do
  echo "  stow $pkg"
  stow -v --restow "$pkg"
done

# Secrets template
if [[ ! -f "$HOME/.secrets.zsh" ]]; then
  echo "==> Creating ~/.secrets.zsh template..."
  cat > "$HOME/.secrets.zsh" << 'SECRETS'
# API Keys and Secrets — NOT tracked in git
# export GEMINI_API_KEY=""
# export JIRA_API_TOKEN=""
# export JIRA_AUTH_TYPE=""
SECRETS
  echo "  Edit ~/.secrets.zsh to add your API keys"
fi

echo "==> Done! Restart your shell or run: source ~/.zshrc"
