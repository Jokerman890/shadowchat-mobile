#!/usr/bin/env bash
set -euo pipefail

IOS_DIR="apps/ios"
DESTINATION="${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

if compgen -G "${IOS_DIR}/*.xcworkspace" > /dev/null; then
  workspace=$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcworkspace' | head -n 1)
  scheme=$(xcodebuild -list -workspace "${workspace}" | awk '/Schemes:/ {getline; gsub(/^ +| +$/,"",$0); print; exit}')

  if [[ -z "${scheme}" ]]; then
    echo "[ios-codeql] No shared scheme found in ${workspace}; cannot run manual CodeQL build."
    exit 1
  fi

  xcodebuild -resolvePackageDependencies -workspace "${workspace}" -scheme "${scheme}"
  xcodebuild build -workspace "${workspace}" -scheme "${scheme}" -destination "${DESTINATION}"
  exit 0
fi

if compgen -G "${IOS_DIR}/*.xcodeproj" > /dev/null; then
  project=$(find "${IOS_DIR}" -maxdepth 1 -name '*.xcodeproj' | head -n 1)
  scheme=$(xcodebuild -list -project "${project}" | awk '/Schemes:/ {getline; gsub(/^ +| +$/,"",$0); print; exit}')

  if [[ -z "${scheme}" ]]; then
    echo "[ios-codeql] No shared scheme found in ${project}; cannot run manual CodeQL build."
    exit 1
  fi

  xcodebuild -resolvePackageDependencies -project "${project}" -scheme "${scheme}"
  xcodebuild build -project "${project}" -scheme "${scheme}" -destination "${DESTINATION}"
  exit 0
fi

echo "[ios-codeql] No .xcworkspace or .xcodeproj found under ${IOS_DIR}."
exit 1
