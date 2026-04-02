# Scripts

This directory is reserved for development, validation, and automation scripts.

## Current scripts

- `scripts/ci/run_ios_validation.sh`
  - Detects Xcode workspace/project in `apps/ios`
  - Resolves Swift package dependencies
  - Runs simulator build + tests when a scheme exists
- `scripts/ci/run_android_validation.sh`
  - Runs `assembleDebug`, `test`, and `lint` in `apps/android` when `gradlew` exists

Examples of future contents:
- bootstrap helpers
- local environment setup
- validation wrappers
- release helpers

Keep scripts:
- documented
- reproducible
- safe for local development and CI
