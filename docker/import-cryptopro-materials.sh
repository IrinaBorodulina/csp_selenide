#!/usr/bin/env bash
set -euo pipefail

CP_BIN_DIR="${CPROCSP_HOME:-/opt/cprocsp}/bin/amd64"
if [ ! -d "${CP_BIN_DIR}" ]; then
  CP_BIN_DIR="${CPROCSP_HOME:-/opt/cprocsp}/bin/ia32"
fi

CERTMGR="${CP_BIN_DIR}/certmgr"

if [ ! -x "${CERTMGR}" ]; then
  echo "certmgr not found. CryptoPro CSP is not installed." >&2
  exit 1
fi

PFX_FILE="${CRYPTOPRO_PFX_PATH:-}"
PFX_PIN="${CRYPTOPRO_PFX_PIN:-}"
CONTAINER_NAME="${CRYPTOPRO_CONTAINER_NAME:-}"
CONTAINER_PIN="${CRYPTOPRO_CONTAINER_PIN:-}"
CERT_FILE="${CRYPTOPRO_CERT_PATH:-}"
ROOT_CERT_FILE="${CRYPTOPRO_ROOT_CERT_PATH:-}"
CA_CERT_FILE="${CRYPTOPRO_CA_CERT_PATH:-}"

if [ -n "${PFX_FILE}" ]; then
  if [ -z "${PFX_PIN}" ] || [ -z "${CONTAINER_NAME}" ] || [ -z "${CONTAINER_PIN}" ]; then
    echo "CRYPTOPRO_PFX_PATH requires CRYPTOPRO_PFX_PIN, CRYPTOPRO_CONTAINER_NAME and CRYPTOPRO_CONTAINER_PIN." >&2
    exit 1
  fi

  "${CERTMGR}" -install -pfx \
    -file "${PFX_FILE}" \
    -pin "${PFX_PIN}" \
    -newpin "${CONTAINER_PIN}" \
    -cont "\\\\.\\HDIMAGE\\${CONTAINER_NAME}"

  "${CERTMGR}" -install -store uMy -cont "\\\\.\\HDIMAGE\\${CONTAINER_NAME}" -pin "${CONTAINER_PIN}"
fi

if [ -n "${CERT_FILE}" ]; then
  if [ -z "${CONTAINER_NAME}" ] || [ -z "${CONTAINER_PIN}" ]; then
    echo "CRYPTOPRO_CERT_PATH requires CRYPTOPRO_CONTAINER_NAME and CRYPTOPRO_CONTAINER_PIN." >&2
    exit 1
  fi

  "${CERTMGR}" -install \
    -file "${CERT_FILE}" \
    -cont "\\\\.\\HDIMAGE\\${CONTAINER_NAME}" \
    -pin "${CONTAINER_PIN}"
fi

if [ -n "${ROOT_CERT_FILE}" ]; then
  "${CERTMGR}" -install -store root -file "${ROOT_CERT_FILE}"
fi

if [ -n "${CA_CERT_FILE}" ]; then
  "${CERTMGR}" -install -store uCA -file "${CA_CERT_FILE}"
fi
