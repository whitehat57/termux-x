#!/usr/bin/env bash

# Logging helpers for Termux-X installer.

LOG_FILE=''

init_logger() {
  mkdir -p "$TERMUX_X_LOG_DIR"
  LOG_FILE="$TERMUX_X_LOG_DIR/install-$(date +%Y-%m-%d-%H-%M-%S).log"
  export LOG_FILE
  : > "$LOG_FILE"
  ln -sf "$LOG_FILE" "$TERMUX_X_LOG_DIR/latest.log" 2>/dev/null
  log_info "Termux-X installer started"
  log_info "Source dir: $TERMUX_X_SOURCE_DIR"
  log_info "Install dir: $TERMUX_X_HOME"
}

log_info() {
  printf '[INFO] %s\n' "$1" >> "$LOG_FILE"
}

log_warn() {
  printf '[WARN] %s\n' "$1" >> "$LOG_FILE"
}

log_error() {
  printf '[ERROR] %s\n' "$1" >> "$LOG_FILE"
}

run_logged() {
  local description="$1"
  shift

  log_info "RUN: $description"
  printf '\n$ %s\n' "$*" >> "$LOG_FILE"
  "$@" >> "$LOG_FILE" 2>&1
  local status=$?

  if [ "$status" -ne 0 ]; then
    log_warn "Command failed: $description | exit_code=$status"
  fi

  return "$status"
}

print_failure_hint() {
  local status="$1"
  printf 'Reason : command/function returned exit code %s\n' "$status"
  printf 'Log    : %s\n' "$LOG_FILE"
  printf 'Recent :\n'
  tail -n 6 "$LOG_FILE" 2>/dev/null | sed 's/^/  /'
}

backup_file() {
  local file_path="$1"
  local backup_dir="$TERMUX_X_HOME/backups"
  local base_name

  if [ ! -f "$file_path" ]; then
    return 0
  fi

  mkdir -p "$backup_dir"
  base_name="$(basename "$file_path")"
  cp "$file_path" "$backup_dir/${base_name}.$(date +%Y%m%d%H%M%S).bak" >> "$LOG_FILE" 2>&1
  return $?
}
