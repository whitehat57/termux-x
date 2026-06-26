#!/usr/bin/env bash

# Zsh UX plugins for Termux-X.
# Plugins are cloned into a temporary directory first.
# Only required runtime files are copied into ~/.termux-x/plugins.
# This avoids leaving .git folders and full source repositories in Termux.

copy_file_or_placeholder() {
  local src="$1"
  local dest="$2"
  local placeholder="${3:-unknown}"

  mkdir -p "$(dirname "$dest")"

  if [ -f "$src" ]; then
    cp "$src" "$dest" >> "$LOG_FILE" 2>&1
    return $?
  fi

  printf '%s\n' "$placeholder" > "$dest"
  return $?
}

install_clean_zsh_autosuggestions() {
  local tmp_root="$1"
  local plugin_dir="$2"
  local repo_dir="$tmp_root/zsh-autosuggestions"
  local stage_dir="$tmp_root/runtime-zsh-autosuggestions"
  local dest_dir="$plugin_dir/zsh-autosuggestions"

  run_logged \
    "clone zsh-autosuggestions to temporary directory" \
    git clone --depth=1 \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$repo_dir"

  if [ $? -ne 0 ]; then
    log_warn "Failed to clone zsh-autosuggestions."
    return 1
  fi

  mkdir -p "$stage_dir"

  cp "$repo_dir/zsh-autosuggestions.zsh" \
    "$stage_dir/zsh-autosuggestions.zsh" \
    >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    log_warn "Failed to copy zsh-autosuggestions runtime file."
    return 1
  fi

  rm -rf "$dest_dir"
  mv "$stage_dir" "$dest_dir" >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    log_warn "Failed to move zsh-autosuggestions runtime directory."
    return 1
  fi

  log_info "zsh-autosuggestions runtime installed cleanly."
  return 0
}

install_clean_zsh_syntax_highlighting() {
  local tmp_root="$1"
  local plugin_dir="$2"
  local repo_dir="$tmp_root/zsh-syntax-highlighting"
  local stage_dir="$tmp_root/runtime-zsh-syntax-highlighting"
  local dest_dir="$plugin_dir/zsh-syntax-highlighting"

  run_logged \
    "clone zsh-syntax-highlighting to temporary directory" \
    git clone --depth=1 \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$repo_dir"

  if [ $? -ne 0 ]; then
    log_warn "Failed to clone zsh-syntax-highlighting."
    return 1
  fi

  mkdir -p "$stage_dir"

  cp "$repo_dir/zsh-syntax-highlighting.zsh" \
    "$stage_dir/zsh-syntax-highlighting.zsh" \
    >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    log_warn "Failed to copy zsh-syntax-highlighting main runtime file."
    return 1
  fi

  cp -r "$repo_dir/highlighters" \
    "$stage_dir/highlighters" \
    >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    log_warn "Failed to copy zsh-syntax-highlighting highlighters directory."
    return 1
  fi

  copy_file_or_placeholder \
    "$repo_dir/.version" \
    "$stage_dir/.version" \
    "unknown"

  if [ $? -ne 0 ]; then
    log_warn "Failed to prepare zsh-syntax-highlighting .version file."
    return 1
  fi

  copy_file_or_placeholder \
    "$repo_dir/.revision-hash" \
    "$stage_dir/.revision-hash" \
    "unknown"

  if [ $? -ne 0 ]; then
    log_warn "Failed to prepare zsh-syntax-highlighting .revision-hash file."
    return 1
  fi

  rm -rf "$dest_dir"
  mv "$stage_dir" "$dest_dir" >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    log_warn "Failed to move zsh-syntax-highlighting runtime directory."
    return 1
  fi

  log_info "zsh-syntax-highlighting runtime installed cleanly."
  return 0
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

  install_clean_zsh_autosuggestions "$tmp_plugin_dir" "$plugin_dir"
  [ $? -ne 0 ] && status=1

  install_clean_zsh_syntax_highlighting "$tmp_plugin_dir" "$plugin_dir"
  [ $? -ne 0 ] && status=1

  rm -rf "$tmp_plugin_dir"
  log_info "Temporary plugin directory removed."

  return "$status"
}