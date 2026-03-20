#!/usr/bin/env bash
set -euo pipefail

step() { echo "▶ $*"; }
success() { echo "✓ $*"; }

step "Installing dotfiles"

# Install Rust if missing
if ! command -v rustc &>/dev/null; then
  step "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
  success "Rust installed"
fi

# Install Oh My Zsh if missing
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  step "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  # Restore our .zshrc if Oh My Zsh overwrote it
  if [[ -f "$HOME/.zshrc.pre-oh-my-zsh" ]]; then
    mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
  fi
  success "Oh My Zsh installed"
fi

# Install Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  step "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  success "zsh-autosuggestions plugin installed"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
  step "Installing fzf-tab plugin..."
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
  success "fzf-tab plugin installed"
fi

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
