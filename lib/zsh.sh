#!/usr/bin/env bash

# Zsh profile generation and shell activation.

render_zsh_template() {
  local template="$TERMUX_X_SOURCE_DIR/assets/zshrc.template"
  local target="$HOME/.zshrc"

  if [ ! -f "$template" ]; then
    log_error "zshrc template not found: $template"
    return 1
  fi

  backup_file "$target"
  sed "s#__TERMUX_X_HOME__#$TERMUX_X_HOME#g" "$template" > "$target"
  return $?
}

ensure_bashrc_zsh_bootstrap() {
  local bashrc="$HOME/.bashrc"
  local marker_start="# >>> TERMUX-X ZSH BOOTSTRAP >>>"
  local marker_end="# <<< TERMUX-X ZSH BOOTSTRAP <<<"

  touch "$bashrc" >> "$LOG_FILE" 2>&1

  if grep -q "TERMUX-X ZSH BOOTSTRAP" "$bashrc" 2>/dev/null; then
    log_info "Termux-X zsh bootstrap already exists in .bashrc"
    return 0
  fi

  backup_file "$bashrc"

  cat >> "$bashrc" <<'BOOTSTRAP'

# >>> TERMUX-X ZSH BOOTSTRAP >>>
if command -v zsh >/dev/null 2>&1 && [ -z "$ZSH_VERSION" ] && [ -t 1 ]; then
  exec zsh -l
fi
# <<< TERMUX-X ZSH BOOTSTRAP <<<
BOOTSTRAP

  log_info "Added zsh bootstrap to $bashrc"
  return 0
}

try_set_default_shell_to_zsh() {
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null)"

  if [ -z "$zsh_path" ]; then
    log_error "zsh binary not found."
    return 1
  fi

  if command -v chsh >/dev/null 2>&1; then
    run_logged "set default shell with chsh" chsh -s zsh
    if [ $? -eq 0 ]; then
      log_info "Default shell changed to zsh using chsh."
      return 0
    fi
    log_warn "chsh failed. Falling back to .bashrc bootstrap."
  else
    log_warn "chsh not available. Falling back to .bashrc bootstrap."
  fi

  ensure_bashrc_zsh_bootstrap
  return $?
}

build_termux_x_shell_profile() {
  local status=0

  if ! command -v zsh >/dev/null 2>&1; then
    log_error "zsh not installed."
    return 1
  fi

  copy_runtime_assets

  render_zsh_template
  [ $? -ne 0 ] && status=1

  try_set_default_shell_to_zsh
  [ $? -ne 0 ] && status=1

  return "$status"
}

finalize_termux_x() {
  mkdir -p "$TERMUX_X_HOME/logs" "$TERMUX_X_HOME/cache"

  cat > "$TERMUX_X_HOME/README.txt" <<EOF2
Termux-X installed.

Profile:
- Cyberpunk mobile workstation
- Zsh shell profile
- Autosuggestions
- Syntax highlighting
- Python, Go, and Node.js runtime
- Ranger, nnn, and modern CLI tools

Files:
- $HOME/.zshrc
- $HOME/.bashrc
- $HOME/.termux/colors.properties
- $TERMUX_X_HOME

Extra keys:
- Termux default

Latest log:
- $TERMUX_X_LOG_DIR/latest.log

Restart Termux after installation.
EOF2

  log_info "Termux-X finalization complete"
  return 0
}
