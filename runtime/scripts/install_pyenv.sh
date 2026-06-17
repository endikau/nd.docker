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

# Install pyenv into a shared location. All users can read and execute it;
# members of the pyenv group can add or update installed Python versions.
export PYENV_ROOT="${PYENV_ROOT:-/opt/pyenv}"
PYENV_GROUP="${PYENV_GROUP:-pyenv}"

if ! getent group "${PYENV_GROUP}" >/dev/null; then
  groupadd --system "${PYENV_GROUP}"
fi

install -d -m 0755 "$(dirname "${PYENV_ROOT}")"

# Install pyenv via the official installer
if [[ ! -x "${PYENV_ROOT}/bin/pyenv" ]]; then
  if [[ -e "${PYENV_ROOT}" ]]; then
    echo "ERROR: ${PYENV_ROOT} exists but does not contain a pyenv executable" >&2
    exit 1
  fi
  curl -fsSL https://pyenv.run | bash
fi

# Make pyenv available in the current build shell
export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# System-wide login shell setup.
cat >/etc/profile.d/pyenv.sh <<'EOF'
export PYENV_ROOT="${PYENV_ROOT:-/opt/pyenv}"
case ":${PATH}:" in
  *":${PYENV_ROOT}/shims:"*) ;;
  *) export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}" ;;
esac

if [ -n "${BASH_VERSION:-}" ] && command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
  if pyenv virtualenv-init - >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi
EOF

chmod 0644 /etc/profile.d/pyenv.sh

# Interactive non-login bash shells read /etc/bash.bashrc instead of /etc/profile.
if ! grep -q '/etc/profile.d/pyenv.sh' /etc/bash.bashrc 2>/dev/null; then
  printf '\n# Load pyenv for all interactive bash users.\nif [ -r /etc/profile.d/pyenv.sh ]; then\n  . /etc/profile.d/pyenv.sh\nfi\n' >> /etc/bash.bashrc
fi

# Optionally install and activate a default Python version
REQUESTED_PYTHON_VERSION="${PYENV_DEFAULT_PYTHON_VERSION:-}"
if [[ -n "$REQUESTED_PYTHON_VERSION" ]]; then
  "$PYENV_ROOT/bin/pyenv" install -s "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" global "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" rehash
fi

chown -R root:"${PYENV_GROUP}" "${PYENV_ROOT}"
chmod -R a+rX,g+rwX "${PYENV_ROOT}"
find "${PYENV_ROOT}" -type d -exec chmod g+s {} +
