#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"

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

echo "fisk installed to ~/.local/bin"
