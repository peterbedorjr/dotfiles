# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that mirrors `$HOME` structure. Running `stow <pkg>` from the repo root symlinks its contents into `$HOME`.

## Setup & Installation

```bash
./install.sh          # Full bootstrap: Homebrew, Brewfile, fnm/Node, stow all packages
stow -v --restow zsh  # Re-stow a single package after editing
```

The install script stows these packages: `zsh ghostty starship nvim zellij git bat lazygit`

## Architecture

**Stow package layout** — each directory maps to `$HOME`:
- `zsh/` → `.zshrc` + modular configs in `.config/zsh/` (exports, aliases, functions, project switcher)
- `ghostty/` → Ghostty terminal config + GLSL shader collection
- `git/` → `.gitconfig` (delta pager, zdiff3 merge, aliases)
- `nvim/` → Neovim config (kickstart-based, Lua)
- `starship/` → Starship prompt (cyberpunk neon theme)
- `zellij/` → Zellij multiplexer (custom keybinds, clear-defaults mode)
- `bat/`, `lazygit/` → Respective tool configs

**Zsh module loading order** (in `.zshrc`): Oh My Zsh → exports → aliases → functions → project.zsh → secrets → fnm → bun → fzf/fzf-tab → zoxide → atuin → starship → syntax highlighting

**Secrets** are kept in `~/.secrets.zsh` (gitignored, template created by install.sh).

## Key Conventions

- **Conditional aliases**: CLI replacements (eza, bat, rg, fd, zoxide) are guarded with `command -v` checks so the shell works without them installed.
- **Ghostty shaders**: Multiple shader files exist; active shaders are controlled by uncommenting lines in `ghostty/.config/ghostty/config`. Multiple `custom-shader` lines can stack (e.g., CRT + bloom + cursor effect).
- **Project switcher** (`project` command in `project.zsh`): Config files live in `~/.config/projects/<name>.conf` with `project_dir`, `setup_cmds`, `deactivate_cmds`, and `kill_claude` options.
- **Claude Code helpers**: `cc` opens Claude in a new zellij tab, `ccf` in a floating pane. Zellij has `Alt c` bound to open a "claude" layout tab.

## When Editing Configs

- After modifying any stow package, re-stow it: `stow -v --restow <pkg>`
- Zsh config is split across files in `zsh/.config/zsh/` — put aliases in `aliases.zsh`, functions in `functions.zsh`, env vars in `exports.zsh`, project tooling in `project.zsh`
- Ghostty config uses `key = value` syntax (no quotes on values except font-family)
- Zellij config uses KDL format; keybinds use `clear-defaults=true` so all binds must be explicit
- Brewfile tracks all Homebrew dependencies — update it when adding/removing brew packages
