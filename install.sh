#!/usr/bin/env bash
# install.sh — Ansible AAP Skills CLI installer
# Installs SKILL.md-based agent skills for Claude Code and Cursor IDE
# Usage: ./install.sh <command> [options]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${SCRIPT_DIR}/skills"

CLAUDE_SKILLS_PATH="${HOME}/.claude/skills"
CURSOR_SKILLS_PATH="${HOME}/.cursor/skills"

# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

_info()    { echo "[INFO]  $*"; }
_success() { echo "[OK]    $*"; }
_warn()    { echo "[WARN]  $*" >&2; }
_error()   { echo "[ERROR] $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  install   Copy skill(s) to detected or specified IDE path(s)
  update    Re-copy skill(s), overwriting existing installations
  verify    Check that installed skills match the source
  list      Print all available skills and their installation status

Options:
  --skill <name>          Target a specific skill (default: all)
  --ide <claude|cursor|all>  Target a specific IDE (default: all)
  --dry-run               Preview actions without making changes
  --help                  Show this help message

Examples:
  ./install.sh install
  ./install.sh install --skill aap-config-structure --ide cursor
  ./install.sh install --dry-run
  ./install.sh update --skill ee-yaml-schema
  ./install.sh verify
  ./install.sh list
EOF
}

# --------------------------------------------------------------------------- #
# IDE detection
# --------------------------------------------------------------------------- #

detect_ides() {
  DETECTED_IDES=()
  [[ -d "${HOME}/.claude" ]] && DETECTED_IDES+=("claude")
  [[ -d "${HOME}/.cursor" ]] && DETECTED_IDES+=("cursor")
  if [[ ${#DETECTED_IDES[@]} -eq 0 ]]; then
    _warn "No supported IDE directories found (looked for ~/.claude and ~/.cursor)"
  fi
}

ide_path() {
  local ide="$1"
  case "$ide" in
    claude) echo "${CLAUDE_SKILLS_PATH}" ;;
    cursor) echo "${CURSOR_SKILLS_PATH}" ;;
    *) _error "Unknown IDE: $ide" ;;
  esac
}

resolve_ides() {
  local requested="$1"
  if [[ "$requested" == "all" ]]; then
    detect_ides
    echo "${DETECTED_IDES[@]:-}"
  else
    echo "$requested"
  fi
}

# --------------------------------------------------------------------------- #
# Skill discovery
# --------------------------------------------------------------------------- #

get_all_skills() {
  local skills=()
  for cfg in "${SKILLS_DIR}"/*/config.sh; do
    [[ -f "$cfg" ]] || continue
    skills+=("$(basename "$(dirname "$cfg")")")
  done
  echo "${skills[@]:-}"
}

load_skill_config() {
  local skill_name="$1"
  local cfg="${SKILLS_DIR}/${skill_name}/config.sh"
  [[ -f "$cfg" ]] || _error "Skill not found: ${skill_name}"
  # shellcheck disable=SC1090
  source "$cfg"
}

# --------------------------------------------------------------------------- #
# Core operations
# --------------------------------------------------------------------------- #

install_skill() {
  local skill_name="$1"
  local ide="$2"
  local dry_run="${3:-false}"

  load_skill_config "$skill_name"
  local dest
  dest="$(ide_path "$ide")/${skill_name}"

  if [[ "$dry_run" == "true" ]]; then
    _info "[dry-run] Would install ${skill_name} -> ${dest}"
    return
  fi

  mkdir -p "$(ide_path "$ide")"
  cp -r "${SKILLS_DIR}/${skill_name}" "$(ide_path "$ide")/"
  _success "Installed ${skill_name} (v${SKILL_VERSION}) -> ${dest}"
}

update_skill() {
  local skill_name="$1"
  local ide="$2"
  local dry_run="${3:-false}"

  load_skill_config "$skill_name"
  local dest
  dest="$(ide_path "$ide")/${skill_name}"

  if [[ "$dry_run" == "true" ]]; then
    _info "[dry-run] Would update ${skill_name} -> ${dest}"
    return
  fi

  if [[ ! -d "$dest" ]]; then
    _warn "${skill_name} not installed for ${ide}; running install instead"
    install_skill "$skill_name" "$ide" "$dry_run"
    return
  fi

  rm -rf "$dest"
  cp -r "${SKILLS_DIR}/${skill_name}" "$(ide_path "$ide")/"
  _success "Updated ${skill_name} (v${SKILL_VERSION}) -> ${dest}"
}

verify_skill() {
  local skill_name="$1"
  local ide="$2"

  load_skill_config "$skill_name"
  local dest
  dest="$(ide_path "$ide")/${skill_name}"

  if [[ ! -d "$dest" ]]; then
    _warn "MISSING  ${skill_name} [${ide}] — not installed at ${dest}"
    return 1
  fi
  if [[ ! -f "${dest}/SKILL.md" ]]; then
    _warn "INVALID  ${skill_name} [${ide}] — SKILL.md missing in ${dest}"
    return 1
  fi
  _success "OK       ${skill_name} [${ide}] — ${dest}"
}

list_skills() {
  printf "%-30s %-10s %-10s %s\n" "SKILL" "VERSION" "IDE" "STATUS"
  printf "%-30s %-10s %-10s %s\n" "-----" "-------" "---" "------"

  local skills
  read -ra skills <<< "$(get_all_skills)"

  detect_ides

  for skill_name in "${skills[@]}"; do
    load_skill_config "$skill_name"
    if [[ ${#DETECTED_IDES[@]} -eq 0 ]]; then
      printf "%-30s %-10s %-10s %s\n" "$skill_name" "${SKILL_VERSION}" "—" "no IDE detected"
    else
      for ide in "${DETECTED_IDES[@]}"; do
        local dest
        dest="$(ide_path "$ide")/${skill_name}"
        local status="not installed"
        [[ -d "$dest" ]] && status="installed"
        printf "%-30s %-10s %-10s %s\n" "$skill_name" "${SKILL_VERSION}" "$ide" "$status"
      done
    fi
  done
}

# --------------------------------------------------------------------------- #
# also install ansible-good-practices as baseline alongside any skill
# --------------------------------------------------------------------------- #

install_baseline() {
  local ide="$1"
  local dry_run="${2:-false}"
  local baseline="ansible-good-practices"
  if [[ -d "${SKILLS_DIR}/${baseline}" ]]; then
    install_skill "$baseline" "$ide" "$dry_run"
  fi
}

# --------------------------------------------------------------------------- #
# Argument parsing & dispatch
# --------------------------------------------------------------------------- #

COMMAND=""
OPT_SKILL="all"
OPT_IDE="all"
OPT_DRY_RUN="false"

parse_args() {
  [[ $# -eq 0 ]] && { usage; exit 0; }
  COMMAND="$1"; shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skill)   OPT_SKILL="${2:?--skill requires a value}"; shift 2 ;;
      --ide)     OPT_IDE="${2:?--ide requires a value}";   shift 2 ;;
      --dry-run) OPT_DRY_RUN="true"; shift ;;
      --help|-h) usage; exit 0 ;;
      *) _error "Unknown option: $1" ;;
    esac
  done
}

main() {
  parse_args "$@"

  local skills=()
  if [[ "$OPT_SKILL" == "all" ]]; then
    read -ra skills <<< "$(get_all_skills)"
  else
    skills=("$OPT_SKILL")
  fi

  local ides=()
  read -ra ides <<< "$(resolve_ides "$OPT_IDE")"

  case "$COMMAND" in
    install)
      for ide in "${ides[@]:-}"; do
        [[ -z "$ide" ]] && continue
        for skill in "${skills[@]}"; do
          install_skill "$skill" "$ide" "$OPT_DRY_RUN"
        done
        # ensure baseline good-practices is always present
        if [[ "$OPT_SKILL" != "ansible-good-practices" ]]; then
          install_baseline "$ide" "$OPT_DRY_RUN"
        fi
      done
      ;;
    update)
      for ide in "${ides[@]:-}"; do
        [[ -z "$ide" ]] && continue
        for skill in "${skills[@]}"; do
          update_skill "$skill" "$ide" "$OPT_DRY_RUN"
        done
      done
      ;;
    verify)
      local exit_code=0
      for ide in "${ides[@]:-}"; do
        [[ -z "$ide" ]] && continue
        for skill in "${skills[@]}"; do
          verify_skill "$skill" "$ide" || exit_code=1
        done
      done
      exit "$exit_code"
      ;;
    list)
      list_skills
      ;;
    --help|-h|help)
      usage
      ;;
    *)
      _error "Unknown command: ${COMMAND}. Run './install.sh --help' for usage."
      ;;
  esac
}

main "$@"
