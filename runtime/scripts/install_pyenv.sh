#!/bin/bash
set -e

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
    git

# Clean up
rm -rf /var/lib/apt/lists/*

# Install pyenv via the official installer
curl -fsSL https://pyenv.run | bash

# Ensure pyenv is available in the current shell during build
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Make pyenv available in login and interactive shells
cat >/etc/profile.d/pyenv.sh <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF

if ! grep -q "pyenv init" /root/.bashrc 2>/dev/null; then
cat >>/root/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF
fi
