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

  yes '' | DEBIAN_FRONTEND=noninteractive dpkg --configure -a \
    --force-confdef \
    --force-confold \
    >> "$LOG_FILE" 2>&1

  local status="${PIPESTATUS[1]}"

  if [ "$status" -ne 0 ]; then
    log_warn "dpkg repair returned exit code $status"
    return 1
  fi

  return 0
}

update_termux_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    log_error "apt-get command not available."
    return 1
  fi

  local status=0

  repair_pending_dpkg
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "apt-get update" update -y
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "apt-get upgrade" upgrade -y
  [ $? -ne 0 ] && status=1

  return "$status"
}

install_base_ui_dependencies() {
  local status=0

  repair_pending_dpkg
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "install required packages" install -y zsh git curl
  [ $? -ne 0 ] && status=1

  run_apt_noninteractive "install optional visual packages" install -y figlet toilet ncurses-utils
  if [ $? -ne 0 ]; then
    log_warn "Optional visual packages failed to install. Continuing without them."
  fi

  return "$status"
}