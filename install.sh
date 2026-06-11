#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
DATA_DIR="$HOME/.fisk"
no_data=false

for arg in "$@"; do
  case $arg in
    --help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --update           Update binary only (skip data directory setup)"
      echo "  --no-data          Skip creating the data directory"
      echo "  --data-dir=PATH    Create data directory at PATH (sets FISK_DIR in shell rc)"
      echo "  --help             Show this help message"
      exit 0
      ;;
    --update)       no_data=true ;;
    --no-data)      no_data=true ;;
    --data-dir=*)   DATA_DIR="${arg#*=}" ;;
  esac
done

# Install binary
mkdir -p "$BIN"
cp "$SCRIPT_DIR/fisk" "$BIN/fisk"; chmod +x "$BIN/fisk"

# Add to PATH if needed
if ! echo "$PATH" | grep -q "$BIN"; then
  SHELL_RC="$HOME/.zshrc"
  [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
  echo "Added ~/.local/bin to PATH in $(basename "$SHELL_RC"). Restart your terminal or run: source $SHELL_RC"
fi

# Create data directory
if $no_data; then
  echo "fisk updated in ~/.local/bin"
  exit 0
fi

mkdir -p "$DATA_DIR"

if [ "$DATA_DIR" != "$HOME/.fisk" ]; then
  SHELL_RC="$HOME/.zshrc"
  [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"
  grep -q "FISK_DIR" "$SHELL_RC" 2>/dev/null || echo "export FISK_DIR=\"$DATA_DIR\"" >> "$SHELL_RC"
  echo "Added FISK_DIR=$DATA_DIR to $(basename "$SHELL_RC")"
fi

echo "fisk installed to ~/.local/bin"
echo "Data directory: $DATA_DIR"
