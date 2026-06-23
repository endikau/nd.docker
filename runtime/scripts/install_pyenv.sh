#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    tk-dev \
    xz-utils \
    zlib1g-dev

rm -rf /var/lib/apt/lists/*

export PYENV_ROOT="${PYENV_ROOT:-/opt/pyenv}"
PYENV_RELEASE="${PYENV_RELEASE:-v2.7.2}"
PYENV_GROUP="${PYENV_GROUP:-pyenv}"

if ! getent group "${PYENV_GROUP}" >/dev/null; then
  groupadd --system "${PYENV_GROUP}"
fi

install -d -m 0755 "$(dirname "${PYENV_ROOT}")"

if [[ ! -x "${PYENV_ROOT}/bin/pyenv" ]]; then
  if [[ -e "${PYENV_ROOT}" ]]; then
    echo "ERROR: ${PYENV_ROOT} exists but does not contain a pyenv executable" >&2
    exit 1
  fi
  git clone \
    --branch "${PYENV_RELEASE}" \
    --depth 1 \
    https://github.com/pyenv/pyenv.git \
    "${PYENV_ROOT}"
fi

export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

cat >/etc/profile.d/pyenv.sh <<'EOF'
export PYENV_ROOT="${PYENV_ROOT:-/opt/pyenv}"
case ":${PATH}:" in
  *":${PYENV_ROOT}/shims:"*) ;;
  *) export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}" ;;
esac

if [ -n "${BASH_VERSION:-}" ] && command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
fi
EOF

chmod 0644 /etc/profile.d/pyenv.sh

if ! grep -q '/etc/profile.d/pyenv.sh' /etc/bash.bashrc 2>/dev/null; then
  printf '\n# Load pyenv for all interactive bash users.\nif [ -r /etc/profile.d/pyenv.sh ]; then\n  . /etc/profile.d/pyenv.sh\nfi\n' >> /etc/bash.bashrc
fi

REQUESTED_PYTHON_VERSION="${PYENV_DEFAULT_PYTHON_VERSION:-}"
if [[ -n "$REQUESTED_PYTHON_VERSION" ]]; then
  PYTHON_CONFIGURE_OPTS="${PYTHON_CONFIGURE_OPTS:---enable-shared}" \
    "$PYENV_ROOT/bin/pyenv" install -s "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" global "$REQUESTED_PYTHON_VERSION"
  "$PYENV_ROOT/bin/pyenv" rehash
fi

chown -R root:"${PYENV_GROUP}" "${PYENV_ROOT}"
chmod -R a+rX,g+rwX "${PYENV_ROOT}"
find "${PYENV_ROOT}" -type d -exec chmod g+s {} +
