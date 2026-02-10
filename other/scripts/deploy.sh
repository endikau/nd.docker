#!/usr/bin/env bash
set -euo pipefail

# Keep this wrapper for compatibility with hooks.json (execute-command).
# The heavy lifting lives in deploy.py next to this script.
exec python3 /usr/local/bin/deploy.py "$@"
