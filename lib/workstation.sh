#!/usr/bin/env bash

# Termux-X Mobile Workstation Pack.
# Installs developer runtimes, file explorers, modern CLI tools,
# editors, session tools, archive tools, and system comfort utilities.

install_pkg_required() {
  local pkg="$1"

  run_apt_noninteractive "install required package: $pkg" install -y "$pkg"
  return $?
}

install_pkg_optional() {
  local pkg="$1"

  run_apt_noninteractive "install optional package: $pkg" install -y "$pkg"

  if [ $? -ne 0 ]; then
    log_warn "Optional workstation package failed: $pkg. Continuing."
    return 1
  fi

  return 0
}

install_node_runtime() {
  run_apt_noninteractive "install Node.js LTS" install -y nodejs-lts

  if [ $? -eq 0 ]; then
    log_info "Node.js LTS installed."
    return 0
  fi

  log_warn "nodejs-lts failed. Trying fallback package: nodejs"

  run_apt_noninteractive "install Node.js fallback" install -y nodejs

  if [ $? -ne 0 ]; then
    log_warn "Node.js installation failed."
    return 1
  fi

  return 0
}

install_developer_runtimes() {
  local status=0

  install_pkg_required python
  [ $? -ne 0 ] && status=1

  install_pkg_required golang
  [ $? -ne 0 ] && status=1

  install_node_runtime
  [ $? -ne 0 ] && status=1

  return "$status"
}

install_file_explorer_tools() {
  local status=0

  install_pkg_optional ranger
  [ $? -ne 0 ] && status=1

  install_pkg_optional nnn
  [ $? -ne 0 ] && status=1

  install_pkg_optional tree
  [ $? -ne 0 ] && status=1

  return "$status"
}

install_modern_cli_tools() {
  local status=0
  local pkg

  for pkg in fzf ripgrep fd bat eza zoxide; do
    install_pkg_optional "$pkg"
    [ $? -ne 0 ] && status=1
  done

  return "$status"
}

install_editor_tools() {
  local status=0
  local pkg

  for pkg in nano micro neovim; do
    install_pkg_optional "$pkg"
    [ $? -ne 0 ] && status=1
  done

  return "$status"
}

install_session_tools() {
  local status=0

  install_pkg_optional tmux
  [ $? -ne 0 ] && status=1

  return "$status"
}

install_network_remote_tools() {
  local status=0
  local pkg

  for pkg in openssh wget rsync aria2; do
    install_pkg_optional "$pkg"
    [ $? -ne 0 ] && status=1
  done

  return "$status"
}

install_archive_data_tools() {
  local status=0
  local pkg

  for pkg in zip unzip tar jq; do
    install_pkg_optional "$pkg"
    [ $? -ne 0 ] && status=1
  done

  return "$status"
}

install_system_comfort_tools() {
  local status=0
  local pkg

  for pkg in htop ncdu fastfetch; do
    install_pkg_optional "$pkg"
    [ $? -ne 0 ] && status=1
  done

  return "$status"
}

write_workstation_manifest() {
  local manifest="$TERMUX_X_HOME/workstation-pack.txt"

  mkdir -p "$TERMUX_X_HOME"

  cat > "$manifest" <<'EOF'
Termux-X Mobile Workstation Pack

Developer runtimes:
- Python
- Go
- Node.js LTS / Node.js fallback

File tools:
- Ranger
- nnn
- tree

Modern CLI:
- fzf
- ripgrep
- fd
- bat
- eza
- zoxide

Editors:
- nano
- micro
- neovim

Session:
- tmux

Network / remote:
- openssh
- wget
- rsync
- aria2

Archive / data:
- zip
- unzip
- tar
- jq

System comfort:
- htop
- ncdu
- fastfetch
EOF

  log_info "Workstation manifest written to $manifest"
  return 0
}

install_mobile_workstation_pack() {
  local status=0

  repair_pending_dpkg
  [ $? -ne 0 ] && status=1

  install_developer_runtimes
  [ $? -ne 0 ] && status=1

  install_file_explorer_tools
  [ $? -ne 0 ] && log_warn "Some file explorer tools failed."

  install_modern_cli_tools
  [ $? -ne 0 ] && log_warn "Some modern CLI tools failed."

  install_editor_tools
  [ $? -ne 0 ] && log_warn "Some editor tools failed."

  install_session_tools
  [ $? -ne 0 ] && log_warn "Some session tools failed."

  install_network_remote_tools
  [ $? -ne 0 ] && log_warn "Some network/remote tools failed."

  install_archive_data_tools
  [ $? -ne 0 ] && log_warn "Some archive/data tools failed."

  install_system_comfort_tools
  [ $? -ne 0 ] && log_warn "Some system comfort tools failed."

  write_workstation_manifest

  return "$status"
}