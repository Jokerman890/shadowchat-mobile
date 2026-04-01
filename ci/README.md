# CI

This directory contains CI guidance for cross-platform validation of ShadowChat's iOS and Android slices.

## Baseline workflow

GitHub Actions workflow:
- `.github/workflows/cross-platform-validation.yml`

It defines two baseline jobs aligned with ADR-004:
- iOS simulator dependency resolution, build, and tests (when iOS project files exist)
- Android `assembleDebug`, `test`, and `lint` (when Android Gradle wrapper exists)

## Toolchain environment configuration

### iOS (GitHub macOS runners)
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- `IOS_SIMULATOR_DESTINATION='platform=iOS Simulator,name=iPhone 16'`

Validation entrypoint:
- `scripts/ci/run_ios_validation.sh`

The script auto-detects a workspace or project under `apps/ios/`, resolves Swift package dependencies, then runs full simulator build and tests.
If no `.xcworkspace` or `.xcodeproj` is present yet, it exits cleanly with a skip message.

### Android (GitHub Ubuntu runners)
- `ANDROID_SDK_ROOT=/usr/local/lib/android/sdk`
- `ANDROID_HOME=/usr/local/lib/android/sdk`
- Java 17 via `actions/setup-java`
- SDK provisioning via `android-actions/setup-android`

Validation entrypoint:
- `scripts/ci/run_android_validation.sh`

The script runs `assembleDebug`, `test`, and `lint` from `apps/android` when `gradlew` exists.
If no wrapper is present yet, it exits cleanly with a skip message.

## Local developer parity commands

Run the same entrypoints locally:

```bash
./scripts/ci/run_ios_validation.sh
./scripts/ci/run_android_validation.sh
```

These scripts are intentionally conservative and avoid guessing missing platform projects.

## Code scanning guardrail

GitHub CodeQL is configured in `.github/workflows/codeql.yml` to:
- always analyze GitHub Actions
- run Swift analysis only when an iOS Xcode workspace/project exists under `apps/ios`
- use **manual** build mode for Swift via `scripts/ci/run_ios_codeql_build.sh`

This avoids automatic Swift autobuild failures and keeps scanning aligned with actual repository contents.
