#!/usr/bin/env bash

# Termux-X
# Cyberpunk UI customizer for fresh Termux installations.
# Designed to continue on non-fatal errors and save logs for troubleshooting.

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TERMUX_X_SOURCE_DIR="$SCRIPT_DIR"
export TERMUX_X_HOME="${TERMUX_X_HOME:-$HOME/.termux-x}"
export TERMUX_X_LOG_DIR="$TERMUX_X_HOME/logs"
export TERMUX_X_STEP_TOTAL=8
export TERMUX_X_STEP_CURRENT=0

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=lib/logger.sh
source "$SCRIPT_DIR/lib/logger.sh"
# shellcheck source=lib/checks.sh
source "$SCRIPT_DIR/lib/checks.sh"
# shellcheck source=lib/theme.sh
source "$SCRIPT_DIR/lib/theme.sh"
# shellcheck source=lib/plugins.sh
source "$SCRIPT_DIR/lib/plugins.sh"
# shellcheck source=lib/zsh.sh
source "$SCRIPT_DIR/lib/zsh.sh"

run_step() {
  local title="$1"
  local fn="$2"
  local status

  TERMUX_X_STEP_CURRENT=$((TERMUX_X_STEP_CURRENT + 1))
  ui_step "$TERMUX_X_STEP_CURRENT" "$TERMUX_X_STEP_TOTAL" "$title"
  log_info "STEP $TERMUX_X_STEP_CURRENT/$TERMUX_X_STEP_TOTAL: $title"

  "$fn"
  status=$?

  if [ "$status" -eq 0 ]; then
    ui_ok "$title"
    log_info "DONE: $title"
  else
    ui_warn "$title failed, continuing to next step"
    log_warn "FAILED: $title | exit_code=$status"
    print_failure_hint "$status"
  fi

  echo
  return 0
}

main() {
  init_logger
  ui_clear
  ui_banner_from_source
  ui_intro
  ui_press_enter

  run_step "Checking Termux environment" check_termux_environment
  run_step "Updating packages" update_termux_packages
  run_step "Installing base UI dependencies" install_base_ui_dependencies
  run_step "Applying cyberpunk color scheme" apply_cyberpunk_theme
  run_step "Configuring Termux extra keys" configure_termux_extra_keys
  run_step "Installing Zsh UX plugins" install_zsh_ux_plugins
  run_step "Building Termux-X shell profile" build_termux_x_shell_profile
  run_step "Finalizing setup" finalize_termux_x

  ui_finish "$LOG_FILE"
}

main "$@"
