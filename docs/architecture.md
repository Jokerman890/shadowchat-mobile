# ShadowChat Architecture

## Status
Draft architecture for the first production-oriented iteration of ShadowChat.

## Product Direction
ShadowChat is a privacy-first mobile messenger for iOS and Android.

Core principles:
- Matrix-based communication
- username-first identity
- optional phone number
- strong privacy defaults
- end-to-end encrypted private communication
- optional self-hosted / controlled deployment
- AI only as explicit opt-in and never as a hidden compromise of encrypted messaging

## Architecture Goals
- native mobile quality on iOS and Android
- shared core for messaging, sync, and security-sensitive logic
- clear boundaries between UI, domain/state, and data access
- low dependency sprawl
- strong support for testing and incremental delivery
- future support for multi-account, advanced auth, and optional AI extensions

## Recommended Stack
### Shared Core
- Matrix Rust SDK for messaging, sync, crypto-adjacent client functionality, and room/session logic
- shared abstractions for:
  - account/session state
  - room list and timeline access
  - device/session management
  - verification and recovery entry points

### iOS
- Swift
- SwiftUI for new UI
- structured concurrency with async/await
- Keychain for secure secret handling
- LocalAuthentication for app lock and sensitive confirmation flows
- APNs for push notifications

### Android
- Kotlin
- Jetpack Compose for new UI
- Coroutines and Flow
- Android Keystore for secure secret handling
- BiometricPrompt for local protection flows
- FCM for mainstream distribution push
- potential UnifiedPush support later for privacy-oriented distribution

## Why This Shape
This app has messaging, sync, local cache, session lifecycle, device trust, notification behavior, and security-sensitive flows.
Those requirements favor:
- native platform UI
- a shared core for correctness and consistency
- explicit handling of platform differences instead of pretending iOS and Android behave the same

## Proposed Repository Layout
```text
apps/
  ios/
  android/
core/
  matrix/
docs/
  adrs/
scripts/
ci/
```

If the repository starts simple, this can be introduced incrementally rather than all at once.

## High-Level Layers
### Mobile UI Layer
Responsibilities:
- screen composition
- navigation
- accessibility
- local presentation state
- permission prompts and OS-native user interactions

Must not:
- contain heavy business logic
- directly own cross-feature persistence/network decisions

### Application / State Layer
Responsibilities:
- feature state production
- orchestration of actions, loading, retry, and error states
- mapping shared-core outputs into UI-ready models

Typical examples:
- authentication state
- room list state
- chat room state
- settings and privacy controls
- session/device management state

### Data / Core Integration Layer
Responsibilities:
- integrate Matrix Rust SDK or shared core APIs
- persistence access
- session restoration
- room/timeline synchronization
- notification token registration entry points

### Security / Secret Handling Layer
Responsibilities:
- OS-native secret storage
- app lock state and access gating
- session secret lifecycle
- backup/recovery entry points

## Identity Model
Primary identity fields:
- username: required, unique in product context
- display name: optional, user-facing
- avatar: optional
- phone number: optional only

Rules:
- phone number is never primary identity
- registration must work without phone number
- discoverability by phone must be opt-in
- phone number must be removable

## Security Model
### Non-Negotiables
- do not implement custom cryptography
- do not weaken Matrix E2EE assumptions
- do not log message contents
- do not store secrets in insecure storage
- do not place plaintext message content into push payloads
- do not silently introduce AI flows that undermine E2EE

### Core Security Capabilities
- device/session visibility
- device verification flows
- secure backup/recovery design
- biometric app lock
- sensitive storage isolation
- privacy-safe logging

## Notification Model
### iOS
- APNs
- privacy-aware previews
- account for platform-specific background limitations

### Android
- FCM for mainstream builds
- optional UnifiedPush later
- per-chat mute and privacy controls

## Persistence and Caching
Short-term expectation:
- local cache for account/session state
- local room list cache
- recent message/timeline cache
- explicit rules for what is sensitive and where it may be stored

Storage must distinguish between:
- secrets
- session metadata
- UI cache
- media cache

## Dependency Strategy
Default rule:
- prefer platform/framework/native solution first
- add third-party dependencies only when clearly justified
- check license, maintenance, compatibility, transitive cost, and CI impact before introduction

### iOS
- prefer Swift Package Manager
- keep Package.resolved committed and current
- avoid new CocoaPods unless repo already depends on them

### Android
- prefer centralized versions
- use version catalog if available
- avoid uncoordinated upgrades of Kotlin / Compose / AGP

## Observability and Logging
Allowed:
- redacted diagnostics
- structured error categories
- build-type-specific debug logging

Not allowed:
- raw tokens
- message contents
- passwords
- phone numbers
- recovery material

## AI Integration Boundary
AI is not a core dependency of MVP.
If added later:
- must be explicitly opt-in
- must document data flow clearly
- must not silently bypass privacy expectations
- should be isolated from core messaging correctness

## First Recommended Vertical Slice
The first implementation slice should be:
1. project foundation
2. auth/onboarding shell
3. username-first registration flow
4. optional phone number model and privacy toggles
5. basic room list shell after session restore

This yields a real product path without prematurely expanding into full messaging complexity.

## Open Decisions
These require ADRs as the project moves forward:
- exact repo/module structure
- minimum supported iOS version
- minimum supported Android SDK
- exact shared core integration approach
- local database choice per platform/shared layer
- push token registration strategy
- recovery UX shape
- whether multi-account is MVP or post-MVP

## ADRs To Create
- ADR-001: Native UI + shared Matrix core
- ADR-002: Username-first identity model
- ADR-003: Notification privacy model
- ADR-004: Secure storage and recovery model
- ADR-005: Dependency policy for iOS and Android
