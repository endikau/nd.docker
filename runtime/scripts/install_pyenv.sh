#!/bin/bash
set -euo pipefail

# a function to install apt packages only if they are not installed
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    curl \
    ca-certificates \
    git \
    python3 \
    python3-venv \
    python3-pip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    libncursesw5-dev \
    xz-utils

# Clean up
rm -rf /var/lib/apt/lists/*

# Install pyenv via the official installer
curl -fsSL https://pyenv.run | bash

# Make pyenv available in the current build shell
export PYENV_ROOT="$HOME/.pyenv"
export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# Prepare login shell config: prefer ~/.bash_profile, otherwise ~/.profile
LOGIN_SHELL_RC="$HOME/.bash_profile"
if [[ ! -f "$LOGIN_SHELL_RC" ]]; then
  LOGIN_SHELL_RC="$HOME/.profile"
fi

LOGIN_SNIPPET='export PYENV_ROOT="$HOME/.pyenv"
export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init - bash)"'

if ! grep -q 'pyenv init - bash' "$LOGIN_SHELL_RC" 2>/dev/null; then
  printf "\\n%s\\n" "$LOGIN_SNIPPET" >> "$LOGIN_SHELL_RC"
fi

# Interactive shells (.bashrc) get both pyenv and pyenv-virtualenv
BASHRC_SNIPPET='export PYENV_ROOT="$HOME/.pyenv"
export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"'

if ! grep -q 'pyenv virtualenv-init' "$HOME/.bashrc" 2>/dev/null; then
  printf "\\n%s\\n" "$BASHRC_SNIPPET" >> "$HOME/.bashrc"
fi

# Optionally install and activate a default Python version
REQUESTED_PYTHON_VERSION="${PYENV_DEFAULT_PYTHON_VERSION:-}"
if [[ -n "$REQUESTED_PYTHON_VERSION" ]]; then
  "$PYENV_ROOT/bin/pyenv" install -s "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" global "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" rehash
fi
