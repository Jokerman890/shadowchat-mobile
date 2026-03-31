# ShadowChat Implementation Plan

## Status
Initial implementation plan for a production-oriented mobile MVP.

## Objective
Build the first serious version of ShadowChat as a privacy-first Matrix-based mobile messenger for iOS and Android with:
- username-first identity
- optional phone number
- secure messaging foundation
- room/session lifecycle
- privacy-safe mobile behavior
- clean path to future expansion

## Delivery Strategy
Prefer small, validated vertical slices.
Do not try to scaffold the entire product before any flow works.

Recommended cadence:
- foundation first
- first end-to-end auth slice
- room list and session restore
- basic messaging
- media and privacy controls
- security/recovery hardening
- notifications and moderation basics
- performance, accessibility, and release readiness

## Phase 0 — Repository Foundation
Goal:
Create a minimal but scalable starting structure and baseline conventions.

Deliverables:
- AGENTS.md in project root
- docs/architecture.md
- docs/implementation-plan.md
- docs/adrs/ placeholder
- initial README if missing or too thin
- target repo structure agreed
- basic CI direction documented

Exit criteria:
- project direction is documented
- architecture preference is explicit
- implementation order is clear

## Phase 1 — Bootstrap the Mobile Workspace
Goal:
Establish the technical foundation for iOS and Android without overcommitting too early.

Target outcomes:
- baseline iOS app shell
- baseline Android app shell
- agreed package/module layout
- initial shared core integration plan
- basic lint/format/test commands identified

Recommended structure target:
```text
apps/
  ios/
  android/
core/
docs/
  adrs/
scripts/
ci/
```

Tasks:
- create app shells or import them if already present
- define naming conventions
- define environment/config pattern
- define secrets handling approach for development
- identify simulator/emulator validation commands

Exit criteria:
- iOS app launches locally
- Android app launches locally
- repo structure is understandable
- first validation commands are documented

## Phase 2 — Auth and Identity Foundation
Goal:
Implement the first real product path.

Scope:
- registration shell
- login shell
- username required
- phone number optional in data model and UI shape
- invite-code support in model/API boundary if required
- session restore entry point
- profile basics: display name, username display, avatar placeholder

Tasks:
- define identity models
- implement validation rules for username and optional phone number
- implement onboarding state flow
- build auth error state handling
- define secure storage boundary for session/auth state

Exit criteria:
- registration works without phone number
- username is treated as the primary identity
- auth/session flow is testable
- sensitive material is not stored in insecure local storage

## Phase 3 — Session, Sync, and Room List
Goal:
Transition from account access into a usable messaging shell.

Scope:
- session restoration
- room list loading
- initial sync
- loading/error/empty states
- reconnect handling
- local cache for room list shell

Tasks:
- integrate or stub shared core room/session interfaces
- define room list view state
- implement retry and connectivity state handling
- establish cache boundary

Exit criteria:
- user can enter the app and see a room list shell
- reconnect behavior is defined
- room list state is not tightly coupled to raw UI widgets

## Phase 4 — Core Messaging MVP
Goal:
Deliver the first real chat flow.

Scope:
- 1:1 chat screen
- group chat screen
- send text message
- receive/render text message
- local echo
- send status
- retry on failure
- replies
- reactions
- typing indicator
- read receipts if feasible in slice order

Tasks:
- define timeline item models
- implement UI state and mapping
- define send/retry path
- validate state transitions

Exit criteria:
- basic messaging is usable end to end
- failure and retry states are visible
- chat UI remains separate from data/core logic

## Phase 5 — Media and Privacy Controls
Goal:
Add essential messaging support and user-facing privacy control.

Scope:
- image sending
- file sending
- voice note shell or first implementation
- upload/download progress
- EXIF/GPS stripping for images
- privacy settings shell
- phone discoverability toggle
- notification preview privacy toggle
- read receipt toggle if architecture allows

Tasks:
- define media pipeline boundaries
- define local media cache policy
- add privacy settings state and persistence rules

Exit criteria:
- media path works for the first supported types
- privacy controls are represented clearly in product state
- sensitive metadata is not sent unintentionally

## Phase 6 — Device Trust, Recovery, and App Protection
Goal:
Make the product trustworthy beyond happy-path chat.

Scope:
- active session/device list
- device verification entry points
- secure backup/recovery entry points
- biometric app lock
- security-focused settings area

Tasks:
- define trusted/untrusted device state representation
- connect OS-native secret storage
- define recovery UX and warnings
- define what can be locally protected vs remotely revoked

Exit criteria:
- device/session visibility exists
- app protection exists
- recovery is not an afterthought

## Phase 7 — Notifications, Safety, and Moderation Basics
Goal:
Make the app usable in normal mobile conditions.

Scope:
- APNs path for iOS
- FCM path for Android
- privacy-aware notification content behavior
- mute controls
- block user
- report user/message/room shell

Tasks:
- define push token lifecycle
- define notification deep-link behavior
- define mute/report/block state shape

Exit criteria:
- notification architecture is documented and partially or fully implemented
- moderation basics exist in product design and backlog
- privacy expectations are preserved in notifications

## Phase 8 — Performance, Accessibility, and Release Readiness
Goal:
Make the MVP credible for testing and distribution.

Scope:
- room/timeline performance checks
- offline/reconnect hardening
- screen reader support for core flows
- larger text and reduced motion review
- privacy and release documentation
- store metadata preparation

Tasks:
- validate critical user flows with accessibility enabled
- review logs for redaction compliance
- prepare compliance checklist
- tighten build/test instructions

Exit criteria:
- core flows are accessible
- release docs are not missing essential pieces
- main flows are stable enough for beta

## Dependency Rules During Implementation
When adding dependencies, always check:
- whether platform-native APIs already solve the problem
- maintenance quality
- transitive dependency impact
- license suitability
- iOS / Android version compatibility
- Kotlin / Compose / AGP compatibility on Android
- Xcode / Swift / package compatibility on iOS
- CI/build implications

Do not add dependencies casually.

## Validation Rules
For each slice:
- run the narrowest relevant checks first
- prefer module-specific validation before full builds
- add tests for logic-heavy flows where the repo already supports testing
- document what was validated and what was not

Typical validation targets later in implementation:
- iOS package resolution and scheme build
- Android Gradle assemble/test/lint
- logic tests for identity, privacy toggles, and session state

## Documentation Rules
Update docs whenever a change affects:
- architecture
- dependency strategy
- security model
- identity model
- notification behavior
- storage/recovery behavior

Create ADRs for decisions with long-term impact.

## Immediate Next Steps
1. Add `docs/adrs/README.md`
2. Add a concise `README.md` describing product intent and repo direction
3. Decide the exact initial repo shape
4. Choose the first executable technical slice
5. Start with the auth/onboarding foundation

## Recommended First Slice
The first coding slice should be small but real:
- bootstrap app shells
- implement auth/onboarding shell
- model username-first registration
- model optional phone number settings
- prepare session restore entry point

This creates a usable, testable path without prematurely building the entire messenger.
