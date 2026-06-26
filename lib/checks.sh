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

  if ! command -v apt-get >/dev/null 2>&1; then
    log_error "apt-get command not found."
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

run_apt_noninteractive() {
  local description="$1"
  shift

  log_info "RUN: $description"
  printf '\n$ DEBIAN_FRONTEND=noninteractive apt-get %s\n' "$*" >> "$LOG_FILE"

  yes '' | DEBIAN_FRONTEND=noninteractive apt-get "$@" \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    >> "$LOG_FILE" 2>&1

  local status="${PIPESTATUS[1]}"

  if [ "$status" -ne 0 ]; then
    log_warn "Command failed: $description | exit_code=$status"
  fi

  return "$status"
}

repair_pending_dpkg() {
  if ! command -v dpkg >/dev/null 2>&1; then
    return 0
  fi

  log_info "Checking pending dpkg configuration..."

  yes '' | DEBIAN_FRONTEND=noninteractive dpkg \
    --force-confdef \
    --force-confold \
    --configure -a \
    >> "$LOG_FILE" 2>&1

  local status="${PIPESTATUS[1]}"

  if [ "$status" -ne 0 ]; then
    log_warn "dpkg repair returned exit code $status"
    return 1
  fi

  return 0
}

update_termux_packages() {
  local status=0

  repair_pending_dpkg
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "apt-get update" update
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "apt-get upgrade" upgrade -y
  [ $? -ne 0 ] && status=1

  return "$status"
}

install_base_ui_dependencies() {
  local status=0
  local optional_pkg

  repair_pending_dpkg
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "install required packages" install -y zsh git curl
  [ $? -ne 0 ] && status=1

  for optional_pkg in figlet toilet ncurses-utils; do
    run_apt_noninteractive "install optional package: $optional_pkg" install -y "$optional_pkg"

    if [ $? -ne 0 ]; then
      log_warn "Optional package failed to install: $optional_pkg. Continuing."
    fi
  done

  return "$status"
}