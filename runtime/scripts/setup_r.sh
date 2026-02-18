#!/bin/bash
set -euo pipefail

# Create a global R profile that pins CRAN to the specified mirror
RPROFILE_PATH="/etc/R/Rprofile.site"

mkdir -p "$(dirname "${RPROFILE_PATH}")"

cat > "${RPROFILE_PATH}" <<'EOF'
options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/noble/latest"))
EOF

echo "Global R profile written to ${RPROFILE_PATH}"
