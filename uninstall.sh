#!/usr/bin/env bash
set -euo pipefail

rm -f "$HOME/.local/bin/fisk"

echo "fisk uninstalled."
echo "Note: ~/.fisk/ data directory was left intact. Remove it manually if no longer needed."
