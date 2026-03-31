# ADR-001: Rust Shared Core + uniFFI Binding Strategy

- Status: Accepted
- Date: 2026-03-31

## Context
ShadowChat is intended to ship as a serious mobile product on iOS and Android with:
- native platform UI
- Matrix-based messaging
- privacy-sensitive session and device lifecycle
- long-term maintainability across two mobile clients

The product needs a shared implementation surface for messaging, room/session logic, verification flows, and other correctness-sensitive client behavior without duplicating core logic in Swift and Kotlin.

At the same time, platform-specific responsibilities such as notifications, biometrics, permissions, secure storage integration, accessibility behavior, and OS lifecycle handling must remain native.

## Decision
Use a shared Rust core with uniFFI-generated bindings for Swift and Kotlin.

### Rust core responsibilities
The Rust core will own:
- Matrix client integration
- session lifecycle abstractions
- room list and timeline access abstractions
- messaging use-case interfaces
- device/session visibility abstractions
- verification and recovery entry points
- shared validation and mapping logic where it is domain-level rather than UI-level

### Native layer responsibilities
The native iOS and Android layers will own:
- all UI code
- navigation
- platform-specific state presentation
- OS permissions
- push registration and token lifecycle integration
- biometrics and app-lock UI behavior
- secure storage adapters where platform-native storage is required
- deep link handling
- app lifecycle and background behavior

## Module Boundary Rules
The shared core must not:
- contain SwiftUI or Compose concerns
- directly depend on APNs or FCM SDK behavior
- assume identical iOS and Android lifecycle semantics
- own platform presentation strings or accessibility behavior

The native layers must not:
- reimplement shared messaging/session domain rules already available in the Rust core
- bypass shared abstractions for core messaging flows without explicit justification

## FFI Shape
Bindings will be generated with uniFFI.

The public FFI surface should:
- expose small, stable interfaces
- prefer explicit request/response models over overly dynamic structures
- avoid leaking internal Matrix SDK types directly into Swift/Kotlin
- keep ownership and lifetime rules simple
- be designed for incremental evolution without breaking consumers unnecessarily

## Error Mapping
Do not expose raw internal error types directly across the FFI boundary.

Instead:
- define stable domain-oriented error categories in Rust
- map internal failures to explicit external error types
- include machine-meaningful fields where needed, such as:
  - code
  - retryability
  - classification
- avoid placing sensitive payloads, tokens, or server responses into surfaced error messages

Native layers may map those categories into platform-specific UI and logging behavior.

## Async Model
Use async Rust APIs with uniFFI-compatible async exposure where appropriate.

Rules:
- long-running operations should be asynchronous
- synchronous FFI calls should be limited to cheap, deterministic work
- event streams and state updates should be modeled explicitly rather than hidden behind polling wherever practical
- cancellation expectations must be documented at the boundary

Native layers remain responsible for integrating async results into Swift structured concurrency and Kotlin coroutines/Flow patterns.

## Consequences
### Positive
- one correctness-oriented shared implementation surface
- less duplicated domain logic
- clearer cross-platform parity for messaging/session behavior
- better long-term maintainability for a security-sensitive app

### Costs
- FFI design discipline is required from the start
- debugging across native and Rust boundaries becomes part of normal engineering work
- build and CI complexity increases compared with fully separate native implementations

## Alternatives Considered
### Duplicate native implementations in Swift and Kotlin
Rejected because it increases logic drift risk and maintenance burden for a messaging product with sensitive flows.

### Flutter-first app with plugin bridges
Rejected as the default path because the target product benefits more from native UI and explicit platform behavior handling.

### Shared core without generated bindings
Rejected for initial strategy because manual bindings add avoidable integration cost and inconsistency risk.

## Follow-Up
Create subsequent ADRs or implementation docs for:
- Rust workspace/module layout
- event stream/state observation pattern across FFI
- local storage boundary ownership
- test strategy for Rust core and native integration layers
