# ── PATH ──────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$(pyenv root)/shims:$PATH"
export PATH="/Users/peterbedorjr/.codeium/windsurf/bin:$PATH"
export PATH="/Users/peterbedorjr/.antigravity/antigravity/bin:$PATH"

# ── Editor ────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── History ───────────────────────────────────────────────
export HISTSIZE=32768
export SAVEHIST=$HISTSIZE
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# ── Locale ────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── Colored man pages ────────────────────────────────────
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export MANPAGER="less -X"

# ── Homebrew ──────────────────────────────────────────────
export HOMEBREW_NO_AUTO_UPDATE=1
