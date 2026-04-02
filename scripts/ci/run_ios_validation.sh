#!/usr/bin/env bash
set -euo pipefail

IOS_DIR="apps/ios"
if [[ ! -d "${IOS_DIR}" ]]; then
  echo "[ios] Missing ${IOS_DIR}; cannot run iOS validation."
  exit 1
fi

workspace=""
scheme=""
if compgen -G "${IOS_DIR}/*.xcworkspace" > /dev/null; then
  workspace=$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcworkspace' | head -n 1)
  scheme=$(xcodebuild -list -workspace "${workspace}" | awk '/Schemes:/ {getline; gsub(/^ +| +$/,"",$0); print; exit}')

  if [[ -z "${scheme}" ]]; then
    echo "[ios] Found workspace (${workspace}) but no scheme; skipping build/test."
    exit 0
  fi

  echo "[ios] Resolving dependencies using workspace ${workspace} / scheme ${scheme}"
  xcodebuild -resolvePackageDependencies -workspace "${workspace}" -scheme "${scheme}"

  echo "[ios] Running simulator build for ${scheme}"
  xcodebuild build -workspace "${workspace}" -scheme "${scheme}" -destination "${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

  echo "[ios] Running tests for ${scheme}"
  xcodebuild test -workspace "${workspace}" -scheme "${scheme}" -destination "${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"
  exit 0
fi

if compgen -G "${IOS_DIR}/*.xcodeproj" > /dev/null; then
  project=$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcodeproj' | head -n 1)
  scheme=$(xcodebuild -list -project "${project}" | awk '/Schemes:/ {getline; gsub(/^ +| +$/,"",$0); print; exit}')

  if [[ -z "${scheme}" ]]; then
    echo "[ios] Found project (${project}) but no scheme; skipping build/test."
    exit 0
  fi

  echo "[ios] Resolving dependencies using project ${project} / scheme ${scheme}"
  xcodebuild -resolvePackageDependencies -project "${project}" -scheme "${scheme}"

  echo "[ios] Running simulator build for ${scheme}"
  xcodebuild build -project "${project}" -scheme "${scheme}" -destination "${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

  echo "[ios] Running tests for ${scheme}"
  xcodebuild test -project "${project}" -scheme "${scheme}" -destination "${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"
  exit 0
fi

echo "[ios] No .xcworkspace or .xcodeproj found in ${IOS_DIR}; skipping iOS build/test for now."
