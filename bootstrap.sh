#!/data/data/com.termux/files/usr/bin/bash

set +e
set -u

REPO_TARBALL_URL="${TERMUX_X_REPO_TARBALL_URL:-https://github.com/whitehat57/termux-x/archive/refs/heads/main.tar.gz}"

TMP_DIR="$(mktemp -d)"
LOG_PREFIX="[Termux-X Bootstrap]"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

echo "$LOG_PREFIX Preparing temporary installer..."

if ! command -v pkg >/dev/null 2>&1; then
  echo "$LOG_PREFIX This script must be run inside Termux."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  pkg install -y curl
fi

if ! command -v tar >/dev/null 2>&1; then
  pkg install -y tar
fi

echo "$LOG_PREFIX Downloading Termux-X..."

curl -fsSL "$REPO_TARBALL_URL" -o "$TMP_DIR/termux-x.tar.gz"

if [ $? -ne 0 ]; then
  echo "$LOG_PREFIX Failed to download installer."
  exit 1
fi

tar -xzf "$TMP_DIR/termux-x.tar.gz" -C "$TMP_DIR"

PROJECT_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'termux-x-*' | head -n 1)"

if [ -z "$PROJECT_DIR" ]; then
  echo "$LOG_PREFIX Failed to locate extracted installer."
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

chmod +x install.sh

echo "$LOG_PREFIX Running installer..."

TERMUX_X_TEMP_INSTALL=1 bash install.sh

INSTALL_STATUS=$?

echo "$LOG_PREFIX Cleaning temporary source files..."

exit "$INSTALL_STATUS"