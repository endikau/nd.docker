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

HUGO_VERSION=${HUGO_VERSION:-0.152.2}

# Detect architecture
ARCH=$(dpkg --print-architecture)
HUGO_ARCH="linux-${ARCH}"

echo "Installing Hugo v${HUGO_VERSION} (${HUGO_ARCH})"

TMPDIR="$(mktemp -d)"
cd "${TMPDIR}"

HUGO_TARBALL="hugo_extended_${HUGO_VERSION}_${HUGO_ARCH}.tar.gz"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

curl -fsSLO "${HUGO_URL}"

# Extract only the hugo binary
tar -xzf "${HUGO_TARBALL}" hugo

install -m 0755 hugo /usr/local/bin/hugo

cd /
rm -rf "${TMPDIR}"

# Clean up
rm -rf /var/lib/apt/lists/*


echo "Hugo installed successfully:"
hugo version

