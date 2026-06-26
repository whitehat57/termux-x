#!/usr/bin/env bash

# UI helpers for Termux-X installer.

TX_RESET='\033[0m'
TX_BOLD='\033[1m'
TX_DIM='\033[2m'
TX_CYAN='\033[1;36m'
TX_MAGENTA='\033[1;35m'
TX_GREEN='\033[1;32m'
TX_YELLOW='\033[1;33m'
TX_RED='\033[1;31m'
TX_WHITE='\033[1;37m'

ui_clear() {
  clear 2>/dev/null || printf '\n'
}

ui_line() {
  printf '%b%s%b\n' "$TX_CYAN" '────────────────────────────────────────────' "$TX_RESET"
}

ui_banner_from_source() {
  local banner="$TERMUX_X_SOURCE_DIR/assets/banner.txt"
  if [ -f "$banner" ]; then
    printf '%b' "$TX_CYAN"
    cat "$banner"
    printf '%b\n' "$TX_RESET"
  else
    printf '%bTermux-X%b\n' "$TX_MAGENTA" "$TX_RESET"
  fi
}

ui_intro() {
  printf '%b╭────────────────────────────────────────────╮%b\n' "$TX_CYAN" "$TX_RESET"
  printf '%b│%b              %bTermux-X Setup%b              %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_MAGENTA" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b├────────────────────────────────────────────┤%b\n' "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Fresh Termux cyberpunk UI customizer.     %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Mode      : Automatic wizard              %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Focus     : UI, Zsh, theme, extra keys     %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Root      : Not required                   %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b╰────────────────────────────────────────────╯%b\n' "$TX_CYAN" "$TX_RESET"
  printf '\n'
}

ui_press_enter() {
  printf '%bPress ENTER to begin...%b' "$TX_DIM" "$TX_RESET"
  IFS= read -r _
  printf '\n'
}

ui_step() {
  local current="$1"
  local total="$2"
  local title="$3"
  printf '%b[%02d/%02d]%b %b%s%b\n' "$TX_MAGENTA" "$current" "$total" "$TX_RESET" "$TX_WHITE" "$title" "$TX_RESET"
}

ui_ok() {
  printf '%b[OK]%b   %s\n' "$TX_GREEN" "$TX_RESET" "$1"
}

ui_warn() {
  printf '%b[WARN]%b %s\n' "$TX_YELLOW" "$TX_RESET" "$1"
}

ui_fail() {
  printf '%b[FAIL]%b %s\n' "$TX_RED" "$TX_RESET" "$1"
}

ui_info() {
  printf '%b[INFO]%b %s\n' "$TX_CYAN" "$TX_RESET" "$1"
}

ui_finish() {
  local log_file="$1"
  printf '%b╭────────────────────────────────────────────╮%b\n' "$TX_CYAN" "$TX_RESET"
  printf '%b│%b              %bTERMUX-X READY%b              %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_MAGENTA" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b├────────────────────────────────────────────┤%b\n' "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Theme      : Cyberpunk                    %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Shell      : Zsh                          %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b UX Plugin  : autosuggest + syntax         %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b│%b Extra Keys : Enabled                      %b│%b\n' "$TX_CYAN" "$TX_RESET" "$TX_CYAN" "$TX_RESET"
  printf '%b╰────────────────────────────────────────────╯%b\n' "$TX_CYAN" "$TX_RESET"
  printf '\n'
  printf '%bLog file:%b %s\n' "$TX_DIM" "$TX_RESET" "$log_file"
  printf '%bRestart Termux to enjoy the new interface.%b\n' "$TX_GREEN" "$TX_RESET"
}
