#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-/tmp/cryptopro}"

if [ ! -d "${SOURCE_DIR}" ] || [ -z "$(find "${SOURCE_DIR}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "CryptoPro distributive not provided. Skipping cryptcp installation."
  exit 0
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

find "${SOURCE_DIR}" -type f \( -name "*.tgz" -o -name "*.tar.gz" \) -exec tar -xzf {} -C "${WORK_DIR}" \;
cp -R "${SOURCE_DIR}"/. "${WORK_DIR}"/

if find "${WORK_DIR}" -type f -name "_FNS_INSTALLER.sh" | grep -q .; then
  INSTALLER="$(find "${WORK_DIR}" -type f -name "_FNS_INSTALLER.sh" | head -n 1)"
  chmod +x "${INSTALLER}"
  (cd "$(dirname "${INSTALLER}")" && "${INSTALLER}")
elif find "${WORK_DIR}" -type f -name "install.sh" | grep -q .; then
  INSTALLER="$(find "${WORK_DIR}" -type f -name "install.sh" | head -n 1)"
  chmod +x "${INSTALLER}"
  (cd "$(dirname "${INSTALLER}")" && "${INSTALLER}")
elif find "${WORK_DIR}" -type f -name "*.deb" | grep -q .; then
  find "${WORK_DIR}" -type f -name "*.deb" -print0 | xargs -0 dpkg -i || apt-get update && apt-get install -f -y && rm -rf /var/lib/apt/lists/*
elif find "${WORK_DIR}" -type f -name "*.rpm" | grep -q .; then
  find "${WORK_DIR}" -type f -name "*.rpm" -print0 | xargs -0 alien -kci
else
  echo "No supported CryptoPro packages found in ${SOURCE_DIR}" >&2
  exit 1
fi

if [ ! -x "/opt/cprocsp/bin/amd64/cryptcp" ] && [ ! -x "/opt/cprocsp/bin/ia32/cryptcp" ]; then
  echo "CryptoPro installation completed, but cryptcp was not found." >&2
  exit 1
fi
