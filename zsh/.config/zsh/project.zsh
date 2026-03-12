# ── Project Switcher ──────────────────────────────────────
# Switch between development projects with a single command.
#
# Config files live in ~/.config/projects/<name>.conf
# Active project tracked in ~/.config/projects/.active
#
# Usage:
#   project switch <name>   Switch to a project
#   project start <name>    Force restart (stop + switch), even if already active
#   project stop            Stop the current project
#   project active          Show the active project
#   project list            List available projects

typeset -g PROJECT_CONFIG_DIR="$HOME/.config/projects"
typeset -g PROJECT_ACTIVE_FILE="$PROJECT_CONFIG_DIR/.active"

# ── Colors ───────────────────────────────────────────────
typeset -g _P_RESET=$'\e[0m'
typeset -g _P_BOLD=$'\e[1m'
typeset -g _P_DIM=$'\e[2m'
typeset -g _P_CYAN=$'\e[36m'
typeset -g _P_GREEN=$'\e[32m'
typeset -g _P_RED=$'\e[31m'
typeset -g _P_YELLOW=$'\e[33m'
typeset -g _P_MAGENTA=$'\e[35m'
typeset -g _P_BLUE=$'\e[34m'

_p_header()  { print -P "${_P_BOLD}${_P_CYAN}$1${_P_RESET}"; }
_p_success() { print -P "${_P_GREEN}  $1${_P_RESET}"; }
_p_error()   { print -P "${_P_RED}  $1${_P_RESET}"; }
_p_warn()    { print -P "${_P_YELLOW}  $1${_P_RESET}"; }
_p_info()    { print -P "${_P_DIM}  $1${_P_RESET}"; }
_p_step()    { print -P "  ${_P_BLUE}>${_P_RESET} $1"; }
_p_label()   { print -Pn "${_P_BOLD}${_P_MAGENTA}$1${_P_RESET}"; }

project() {
  local cmd="${1:-help}"

  case "$cmd" in
    switch)  _project_switch "$2" ;;
    start)   _project_switch "$2" --force ;;
    stop)    _project_stop ;;
    active)  _project_active ;;
    list)    _project_list ;;
    edit)    _project_edit "$2" ;;
    *)       _project_help ;;
  esac
}

_project_switch() {
  local name="$1"
  local force="$2"

  if [[ -z "$name" ]]; then
    _p_error "Usage: project switch <name>"
    return 1
  fi

  local conf="$PROJECT_CONFIG_DIR/${name}.conf"
  if [[ ! -f "$conf" ]]; then
    _p_error "Unknown project: ${_P_BOLD}$name"
    echo ""
    _project_list
    return 1
  fi

  # Check if already active (skip when forced via `project start`)
  local current
  current="$(_project_read_active)"
  if [[ "$current" == "$name" && "$force" != "--force" ]]; then
    _p_warn "Already on ${_P_BOLD}$name"
    return 0
  fi

  # ── Deactivate current project ──
  if [[ -n "$current" ]]; then
    _project_deactivate "$current"
    echo ""
  fi

  # ── Load new project config ──
  local project_dir=""
  local setup_cmds=()
  local open_tabs=()
  local deactivate_cmds=()
  local kill_claude=false

  source "$conf"

  if [[ ! -d "$project_dir" ]]; then
    _p_error "Directory does not exist: $project_dir"
    return 1
  fi

  # Record as active
  echo "$name" > "$PROJECT_ACTIVE_FILE"

  _p_header "┌ Switching to $name"

  # CD into project directory
  builtin cd "$project_dir"
  _p_step "cd ${_P_DIM}$project_dir"

  # Run setup commands (blocking, sequential)
  for cmd in "${setup_cmds[@]}"; do
    _p_step "$cmd"
    eval "$cmd"
    if [[ $? -ne 0 ]]; then
      _p_error "Setup failed: $cmd"
      return 1
    fi
  done

  _p_header "└ Ready"
}

_project_deactivate() {
  local name="$1"

  if [[ -z "$name" ]]; then
    name="$(_project_read_active)"
  fi

  if [[ -z "$name" ]]; then
    return
  fi

  local conf="$PROJECT_CONFIG_DIR/${name}.conf"
  if [[ ! -f "$conf" ]]; then
    rm -f "$PROJECT_ACTIVE_FILE"
    return
  fi

  _p_header "┌ Stopping $name"

  # Load config
  local project_dir=""
  local setup_cmds=()
  local open_tabs=()
  local deactivate_cmds=()
  local kill_claude=false

  source "$conf"

  # Kill claude sessions if configured
  if [[ "$kill_claude" == true ]]; then
    _project_kill_claude
  fi

  # Run deactivation commands in the project directory
  if [[ -d "$project_dir" ]]; then
    (
      builtin cd "$project_dir"
      for cmd in "${deactivate_cmds[@]}"; do
        _p_step "$cmd"
        eval "$cmd"
      done
    )
  fi

  rm -f "$PROJECT_ACTIVE_FILE"
  _p_header "└ Stopped"
}

_project_kill_claude() {
  local pids
  pids=($(pgrep -x "claude" 2>/dev/null))

  if [[ ${#pids[@]} -eq 0 ]]; then
    return
  fi

  _p_step "Killing ${#pids[@]} claude session(s)"
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null
  done
}

_project_stop() {
  local current
  current="$(_project_read_active)"

  if [[ -z "$current" ]]; then
    _p_warn "No active project"
    return 0
  fi

  _project_deactivate "$current"
}

_project_active() {
  local current
  current="$(_project_read_active)"

  if [[ -n "$current" ]]; then
    _p_label "active  "
    echo "$current"
  else
    _p_warn "No active project"
  fi
}

_project_list() {
  local found=false
  local current
  current="$(_project_read_active)"

  for conf in "$PROJECT_CONFIG_DIR"/*.conf(N); do
    local name="${conf:t:r}"
    if [[ "$name" == "$current" ]]; then
      print -P "  ${_P_GREEN}${_P_BOLD}$name${_P_RESET} ${_P_DIM}(active)${_P_RESET}"
    else
      print -P "  ${_P_DIM}$name${_P_RESET}"
    fi
    found=true
  done

  if [[ "$found" == false ]]; then
    _p_warn "No projects configured"
    _p_info "Add configs to $PROJECT_CONFIG_DIR/<name>.conf"
  fi
}

_project_edit() {
  local name="$1"

  if [[ -z "$name" ]]; then
    _p_error "Usage: project edit <name>"
    return 1
  fi

  local conf="$PROJECT_CONFIG_DIR/${name}.conf"

  if [[ ! -f "$conf" ]]; then
    # Create from template
    cat > "$conf" <<'TMPL'
# Project directory (required)
project_dir="$HOME/code/your-project"

# Commands that run and complete before tabs open
setup_cmds=()

# Each entry opens in its own Ghostty tab (in project_dir)
open_tabs=("claude")

# Commands to run when deactivating this project
deactivate_cmds=()

# Kill running claude sessions on deactivate
kill_claude=true
TMPL
    _p_success "Created config: $conf"
  fi

  ${EDITOR:-nvim} "$conf"
}

_project_read_active() {
  if [[ -f "$PROJECT_ACTIVE_FILE" ]]; then
    cat "$PROJECT_ACTIVE_FILE"
  fi
}

_project_help() {
  echo ""
  _p_header "project"
  _p_info "Switch between development projects"
  echo ""
  print -P "  ${_P_BOLD}Usage${_P_RESET}  project ${_P_DIM}<command> [args]${_P_RESET}"
  echo ""
  print -P "  ${_P_BOLD}Commands${_P_RESET}"
  print -P "    ${_P_CYAN}switch${_P_RESET} ${_P_DIM}<name>${_P_RESET}   Switch to a project"
  print -P "    ${_P_CYAN}start${_P_RESET}  ${_P_DIM}<name>${_P_RESET}   Force restart (stop + switch)"
  print -P "    ${_P_CYAN}stop${_P_RESET}            Stop the current project"
  print -P "    ${_P_CYAN}active${_P_RESET}          Show the active project"
  print -P "    ${_P_CYAN}list${_P_RESET}            List available projects"
  print -P "    ${_P_CYAN}edit${_P_RESET} ${_P_DIM}<name>${_P_RESET}     Edit or create a project config"
  echo ""
  _p_info "Config: ~/.config/projects/<name>.conf"
  echo ""
}
