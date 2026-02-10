#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install Miniconda with a pinned version
#
# Usage:
#   install_miniconda.sh py311_24.7.1-0
# or:
#   MINICONDA_VERSION=py311_24.7.1-0 install_miniconda.sh
#
# Installed to:
#   /opt/conda
# -----------------------------------------------------------------------------

MINICONDA_VERSION="${1:-${MINICONDA_VERSION:-}}"

if [[ -z "${MINICONDA_VERSION}" ]]; then
  echo "ERROR: MINICONDA_VERSION is not set"
  echo "Usage: MINICONDA_VERSION=py311_24.7.1-0 install_miniconda.sh"
  exit 1
fi

# Detect OS + architecture
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${ARCH}" in
  x86_64)  MINICONDA_ARCH="x86_64" ;;
  aarch64) MINICONDA_ARCH="aarch64" ;;
  arm64)   MINICONDA_ARCH="aarch64" ;;
  *)
    echo "ERROR: Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

PREFIX="/opt/conda"
INSTALLER="Miniconda3-${MINICONDA_VERSION}-${OS}-${MINICONDA_ARCH}.sh"
URL="https://repo.anaconda.com/miniconda/${INSTALLER}"

echo "Installing Miniconda ${MINICONDA_VERSION} (${OS}-${MINICONDA_ARCH})"

TMPDIR="$(mktemp -d)"
cd "${TMPDIR}"

curl -fsSLO "${URL}"

bash "${INSTALLER}" -b -p "${PREFIX}"

cd /
rm -rf "${TMPDIR}"

# Minimal conda cleanup
"${PREFIX}/bin/conda" clean -afy

echo "Miniconda installed successfully:"
"${PREFIX}/bin/conda" --version

