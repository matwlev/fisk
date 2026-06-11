#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
FISK_HOME="$HOME/.fisk"

update_only=false
reset_config=false
for arg in "$@"; do
  case $arg in
    --help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --update           Update binary only (skip config setup)"
      echo "  --reset-config     Overwrite existing ~/.fisk/config"
      echo "  --help             Show this help message"
      exit 0
      ;;
    --update)       update_only=true ;;
    --reset-config) reset_config=true ;;
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

if $update_only; then
  echo "fisk updated in ~/.local/bin"
  exit 0
fi

# Set up ~/.fisk/config
if [[ -f "$FISK_HOME/config" ]] && ! $reset_config; then
  echo "fisk installed to ~/.local/bin (~/.fisk/config already exists, skipping)"
  exit 0
fi

mkdir -p "$FISK_HOME"
cat > "$FISK_HOME/config" <<EOF
# fisk config
# Config lookup order: ./fisk.config, then ~/.fisk/config

[ledgers]
# Map ledger names to CSV file paths
# checkbook  ~/finances/checkbook.csv
# savings    ~/finances/savings.csv

[defaults]
# Default flags applied to every command
# --sort desc
# --limit 20
EOF

echo "fisk installed to ~/.local/bin"
echo "Config created at ~/.fisk/config"
