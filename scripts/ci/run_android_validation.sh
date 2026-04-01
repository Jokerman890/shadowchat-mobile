#!/usr/bin/env bash
set -euo pipefail

ANDROID_DIR="apps/android"
if [[ ! -d "${ANDROID_DIR}" ]]; then
  echo "[android] Missing ${ANDROID_DIR}; cannot run Android validation."
  exit 1
fi

if [[ ! -f "${ANDROID_DIR}/gradlew" ]]; then
  echo "[android] No gradlew found in ${ANDROID_DIR}; skipping assembleDebug/test/lint for now."
  exit 0
fi

cd "${ANDROID_DIR}"
chmod +x ./gradlew

echo "[android] Running assembleDebug"
./gradlew assembleDebug

echo "[android] Running test"
./gradlew test

echo "[android] Running lint"
./gradlew lint
