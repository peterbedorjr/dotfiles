#!/usr/bin/env bash
set -euo pipefail

step() { echo "▶ $*"; }
success() { echo "✓ $*"; }
warn() { echo "⚠ $*"; }

# Require Linux Mint / Ubuntu / Debian
if [[ ! -f /etc/os-release ]] || ! grep -qiE 'ubuntu|mint|debian' /etc/os-release; then
  warn "This script is intended for Linux Mint / Ubuntu / Debian"
  read -rp "Continue anyway? [y/N] " yn
  [[ "$yn" =~ ^[Yy]$ ]] || exit 1
fi

step "Installing dotfiles (Linux Mint)"

# ── System packages (apt) ────────────────────────────────
step "Updating apt and installing system packages..."
sudo apt update
sudo apt install -y \
  bat \
  build-essential \
  composer \
  curl \
  fd-find \
  fzf \
  git \
  jq \
  libssl-dev \
  php \
  php-cli \
  php-mbstring \
  php-xml \
  ripgrep \
  stow \
  unzip \
  wget \
  zlib1g-dev \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting
success "Apt packages installed"

# ── Symlinks for Debian-renamed binaries ─────────────────
# Debian/Ubuntu ship bat as "batcat" and fd as "fdfind"
mkdir -p "$HOME/.local/bin"
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  success "Symlinked batcat → bat"
fi
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  success "Symlinked fdfind → fd"
fi

# ── Neovim (latest stable via PPA) ──────────────────────
if ! command -v nvim &>/dev/null; then
  step "Installing Neovim..."
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt update
  sudo apt install -y neovim
  success "Neovim installed"
fi

# ── eza (official apt repo) ─────────────────────────────
if ! command -v eza &>/dev/null; then
  step "Installing eza..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update
  sudo apt install -y eza
  success "eza installed"
fi

# ── GitHub CLI ──────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  step "Installing GitHub CLI..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
  sudo apt update
  sudo apt install -y gh
  success "GitHub CLI installed"
fi

# ── lazygit (GitHub release) ────────────────────────────
if ! command -v lazygit &>/dev/null; then
  step "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin/lazygit
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
  success "lazygit $LAZYGIT_VERSION installed"
fi

# ── git-delta (GitHub release) ──────────────────────────
if ! command -v delta &>/dev/null; then
  step "Installing git-delta..."
  DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | jq -r '.tag_name')
  curl -Lo /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
  sudo dpkg -i /tmp/git-delta.deb
  rm -f /tmp/git-delta.deb
  success "git-delta $DELTA_VERSION installed"
fi

# ── fnm (fast Node manager) ────────────────────────────
if ! command -v fnm &>/dev/null; then
  step "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  success "fnm installed"
fi

# ── starship prompt ─────────────────────────────────────
if ! command -v starship &>/dev/null; then
  step "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "starship installed"
fi

# ── zoxide ──────────────────────────────────────────────
if ! command -v zoxide &>/dev/null; then
  step "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  success "zoxide installed"
fi

# ── atuin (shell history) ───────────────────────────────
if ! command -v atuin &>/dev/null; then
  step "Installing atuin..."
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  success "atuin installed"
fi

# ── pyenv ───────────────────────────────────────────────
if ! command -v pyenv &>/dev/null; then
  step "Installing pyenv..."
  curl https://pyenv.run | bash
  success "pyenv installed"
fi

# ── nvm ─────────────────────────────────────────────────
if [[ ! -d "$HOME/.nvm" ]]; then
  step "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  success "nvm installed"
fi

# ── Oh My Zsh ───────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  step "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "Oh My Zsh installed"
fi

# ── zsh-autosuggestions (Oh My Zsh plugin) ──────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  step "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  success "zsh-autosuggestions plugin installed"
fi

# ── fzf-tab (zsh plugin) ───────────────────────────────
if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
  step "Installing fzf-tab plugin..."
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
  success "fzf-tab plugin installed"
fi

# ── Node via fnm ────────────────────────────────────────
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &>/dev/null; then
  step "Installing Node via fnm..."
  eval "$(fnm env)"
  fnm install --lts
  fnm default lts-latest
  success "Node $(fnm current) installed"
fi

# ── Stow packages ──────────────────────────────────────
step "Stowing dotfiles..."
cd "$(dirname "$0")"

packages=(zsh ghostty starship nvim zellij git bat lazygit)
for pkg in "${packages[@]}"; do
  echo "  stow $pkg"
  stow -v --restow "$pkg"
done
success "Dotfiles stowed"

# ── Secrets template ────────────────────────────────────
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

# ── Set zsh as default shell ────────────────────────────
if [[ "$SHELL" != */zsh ]]; then
  step "Setting zsh as default shell..."
  chsh -s "$(command -v zsh)"
  success "Default shell set to zsh"
fi

success "Done! Restart your shell or run: exec zsh"

echo ""
warn "NOTE: Your .zshrc has macOS-specific paths that need updating for Linux."
warn "See the platform-specific lines in zsh/.zshrc (Homebrew, fzf-tab, syntax-highlighting)."
