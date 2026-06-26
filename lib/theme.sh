#!/usr/bin/env bash

# Theme and Termux terminal configuration.

copy_runtime_assets() {
  mkdir -p "$TERMUX_X_HOME"

  cp "$TERMUX_X_SOURCE_DIR/assets/banner.txt" "$TERMUX_X_HOME/banner.txt" >> "$LOG_FILE" 2>&1
  cp "$TERMUX_X_SOURCE_DIR/assets/colors.properties" "$TERMUX_X_HOME/colors.properties" >> "$LOG_FILE" 2>&1
  cp "$TERMUX_X_SOURCE_DIR/assets/termux.properties" "$TERMUX_X_HOME/termux.properties" >> "$LOG_FILE" 2>&1

  return 0
}

apply_cyberpunk_theme() {
  mkdir -p "$HOME/.termux"
  copy_runtime_assets

  backup_file "$HOME/.termux/colors.properties"
  cp "$TERMUX_X_SOURCE_DIR/assets/colors.properties" "$HOME/.termux/colors.properties" >> "$LOG_FILE" 2>&1
  local status=$?

  if command -v termux-reload-settings >/dev/null 2>&1; then
    run_logged "reload Termux settings after colors update" termux-reload-settings
  else
    log_warn "termux-reload-settings not found. Theme will apply after Termux restart."
  fi

  return "$status"
}

configure_termux_extra_keys() {
  mkdir -p "$HOME/.termux"

  backup_file "$HOME/.termux/termux.properties"
  cp "$TERMUX_X_SOURCE_DIR/assets/termux.properties" "$HOME/.termux/termux.properties" >> "$LOG_FILE" 2>&1
  local status=$?

  if command -v termux-reload-settings >/dev/null 2>&1; then
    run_logged "reload Termux settings after extra keys update" termux-reload-settings
  else
    log_warn "termux-reload-settings not found. Extra keys will apply after Termux restart."
  fi

  return "$status"
}
