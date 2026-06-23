#!/usr/bin/env bash
set -euo pipefail

SWS_VERSION="${SWS_VERSION:?SWS_VERSION must be set}"
ARCH="$(dpkg --print-architecture)"

case "${ARCH}" in
  amd64)
    SWS_ARCH="x86_64"
    SWS_SHA256="${SWS_SHA256_AMD64:?SWS_SHA256_AMD64 must be set}"
    ;;
  arm64)
    SWS_ARCH="aarch64"
    SWS_SHA256="${SWS_SHA256_ARM64:?SWS_SHA256_ARM64 must be set}"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

TARBALL="static-web-server-v${SWS_VERSION}-${SWS_ARCH}-unknown-linux-gnu.tar.gz"
URL="https://github.com/static-web-server/static-web-server/releases/download/v${SWS_VERSION}/${TARBALL}"
TMPDIR="$(mktemp -d)"

trap 'rm -rf "${TMPDIR}"' EXIT

curl -fsSL "${URL}" -o "${TMPDIR}/${TARBALL}"
printf '%s  %s\n' "${SWS_SHA256}" "${TMPDIR}/${TARBALL}" | sha256sum --check -
tar -xzf "${TMPDIR}/${TARBALL}" -C "${TMPDIR}"
install -m 0755 \
  "${TMPDIR}/${TARBALL%.tar.gz}/static-web-server" \
  /usr/local/bin/static-web-server

static-web-server --version
