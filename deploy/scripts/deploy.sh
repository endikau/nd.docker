#!/usr/bin/env bash
set -euo pipefail

# Keep this wrapper for compatibility with hooks.json (execute-command).
# The heavy lifting lives in deploy.py next to this script.
exec /opt/venv/bin/python /usr/local/bin/deploy.py "$@"
