#!/usr/bin/env bash
set -euo pipefail

if [ "${CRYPTOPRO_AUTO_IMPORT:-false}" = "true" ]; then
  /usr/local/bin/import-cryptopro-materials.sh
fi

exec "$@"
