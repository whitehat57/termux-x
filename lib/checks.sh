#!/usr/bin/env bash

# Environment checks and package installation.

check_termux_environment() {
  mkdir -p "$TERMUX_X_HOME" "$TERMUX_X_LOG_DIR" "$TERMUX_X_HOME/cache"

  if [ -z "${PREFIX:-}" ]; then
    log_warn "PREFIX is empty. This may not be Termux. Continuing anyway."
  else
    log_info "PREFIX=$PREFIX"
  fi

  if ! command -v pkg >/dev/null 2>&1; then
    log_error "pkg command not found. This installer is designed for Termux."
    return 1
  fi

  if [ "$(id -u 2>/dev/null)" = "0" ]; then
    log_warn "Running as root is not recommended. Termux-X is designed for non-root Termux."
  fi

  if ! command -v bash >/dev/null 2>&1; then
    log_error "bash command not found."
    return 1
  fi

  return 0
}

update_termux_packages() {
  if ! command -v pkg >/dev/null 2>&1; then
    log_error "pkg command not available."
    return 1
  fi

  run_logged "pkg update" pkg update -y
  local update_status=$?

  run_logged "pkg upgrade" pkg upgrade -y
  local upgrade_status=$?

  if [ "$update_status" -ne 0 ] || [ "$upgrade_status" -ne 0 ]; then
    return 1
  fi

  return 0
}

install_base_ui_dependencies() {
  local status=0

  run_logged "install required packages" pkg install -y zsh git curl
  [ $? -ne 0 ] && status=1

  # Optional visual tools. Failure is logged but does not fail the whole step.
  run_logged "install optional visual packages" pkg install -y figlet toilet ncurses-utils
  if [ $? -ne 0 ]; then
    log_warn "Optional visual packages failed to install. Continuing without them."
  fi

  return "$status"
}
