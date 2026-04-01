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

## Code scanning note

CodeQL is currently managed by GitHub default setup at the repository level.
Do not add an advanced CodeQL workflow in-repo unless default setup is explicitly disabled first, otherwise uploads fail with:
`CodeQL analyses from advanced configurations cannot be processed when the default setup is enabled`.
