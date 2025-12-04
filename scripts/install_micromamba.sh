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
    gnupg2 \
    curl \
    ca-certificates

MICROMAMBA_VERSION=${MICROMAMBA_VERSION:-2.4.0-0}

echo "Installing micromamba v${MICROMAMBA_VERSION}"

TMPDIR="$(mktemp -d)"
cd "${TMPDIR}"

curl -fsSLo install.sh \
  https://raw.githubusercontent.com/mamba-org/micromamba-releases/main/install.sh

INIT_YES=no VERSION="${MICROMAMBA_VERSION}" bash ./install.sh

export PATH="$HOME/.local/bin:$PATH"

cd /
rm -rf "${TMPDIR}"

# Clean up
rm -rf /var/lib/apt/lists/*

echo "micromamba installed successfully:"
micromamba --version
