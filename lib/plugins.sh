#!/usr/bin/env bash

# Zsh UX plugins for Termux-X.
# Plugins are cloned into a temporary directory first.
# Only required runtime files are copied into ~/.termux-x/plugins.
# This avoids leaving .git folders and full source repositories in Termux.

copy_clean_plugin_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest" >> "$LOG_FILE" 2>&1
  return $?
}

install_zsh_ux_plugins() {
  local plugin_dir="$TERMUX_X_HOME/plugins"
  local tmp_plugin_dir
  local status=0

  mkdir -p "$plugin_dir"

  if ! command -v git >/dev/null 2>&1; then
    log_error "git not found. Cannot install zsh plugins."
    return 1
  fi

  tmp_plugin_dir="$(mktemp -d)"

  log_info "Temporary plugin directory: $tmp_plugin_dir"

  rm -rf "$plugin_dir/zsh-autosuggestions"
  rm -rf "$plugin_dir/zsh-syntax-highlighting"

  run_logged \
    "clone zsh-autosuggestions to temporary directory" \
    git clone --depth=1 \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$tmp_plugin_dir/zsh-autosuggestions"

  if [ $? -eq 0 ]; then
    mkdir -p "$plugin_dir/zsh-autosuggestions"

    copy_clean_plugin_file \
      "$tmp_plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" \
      "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"

    if [ $? -eq 0 ]; then
      log_info "zsh-autosuggestions runtime file installed."
    else
      log_warn "Failed to copy zsh-autosuggestions runtime file."
      status=1
    fi
  else
    log_warn "Failed to clone zsh-autosuggestions."
    status=1
  fi

  run_logged \
    "clone zsh-syntax-highlighting to temporary directory" \
    git clone --depth=1 \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$tmp_plugin_dir/zsh-syntax-highlighting"

  if [ $? -eq 0 ]; then
    mkdir -p "$plugin_dir/zsh-syntax-highlighting"

    copy_clean_plugin_file \
      "$tmp_plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
      "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    if [ $? -ne 0 ]; then
      log_warn "Failed to copy zsh-syntax-highlighting main runtime file."
      status=1
    fi

    cp -r \
      "$tmp_plugin_dir/zsh-syntax-highlighting/highlighters" \
      "$plugin_dir/zsh-syntax-highlighting/highlighters" \
      >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
      log_info "zsh-syntax-highlighting runtime files installed."
    else
      log_warn "Failed to copy zsh-syntax-highlighting highlighters directory."
      status=1
    fi
  else
    log_warn "Failed to clone zsh-syntax-highlighting."
    status=1
  fi

  rm -rf "$tmp_plugin_dir"
  log_info "Temporary plugin directory removed."

  return "$status"
}
