# AGENTS.md

## Mission
Build ShadowChat as a production-grade, privacy-first mobile messenger for iOS and Android.

This repository is for a serious long-term communication product, not a demo app.

Optimize for:
- security-aware engineering
- maintainable architecture
- mobile-native quality
- reviewable diffs
- realistic implementation
- conservative handling of dependencies
- predictable CI behavior
- privacy by default

Do not optimize for fake completeness, visual fluff, or architecture theater.

---

## Product Intent
ShadowChat is a Matrix-based mobile messenger with:

- username-first identity
- optional phone number
- strong privacy defaults
- end-to-end encrypted private communication
- optional controlled/self-hosted deployment
- optional AI only if explicitly opt-in and privacy-coherent

Core expectations:
- 1:1 chats
- group chats
- text messaging
- replies
- reactions
- typing indicators
- read receipts
- media sending
- session/device management
- secure backup/recovery design
- privacy-safe notifications
- mute / block / report basics

---

## Non-Negotiable Identity Rules
Always preserve these product rules:

- `username` is required
- phone number is optional
- phone number must never be the canonical identity
- registration must work without phone number
- display name is separate from username
- phone discoverability must be opt-in
- phone number must be removable
- privacy defaults must favor the user

Do not introduce:
- phone-first onboarding
- forced contact sync
- hidden discoverability by phone number
- flows that pressure users into providing a phone number

---

## Stack Preference
Prefer this architecture unless the repository clearly dictates otherwise:

- shared core using Matrix Rust SDK
- iOS app in Swift / SwiftUI
- Android app in Kotlin / Jetpack Compose

Use Flutter only if:
- the repo is already clearly Flutter-based
- changing architecture would be unrealistic now
- the tradeoff is documented

If the repo is greenfield or very early:
- prefer clear multi-app or monorepo structure
- keep boundaries simple
- design for growth without overengineering

Suggested high-level structure:
- `apps/ios/`
- `apps/android/`
- `core/` or `shared/`
- `docs/`
- `scripts/`
- `ci/`

---

## Working Order
For every task, work in this order:

1. Inspect the repository
2. Read project instructions and docs
3. Assess current architecture and constraints
4. Make a short plan
5. Implement the smallest high-value slice
6. Validate narrowly first, then broadly if needed
7. Update docs when decisions matter
8. Summarize files changed, validation run, and next step

Do not jump into coding without understanding existing structure.

---

## Files to Read First
Always read these first if present:

- `README.md`
- `AGENTS.md`
- `docs/`
- architecture notes / ADRs
- CI configuration
- iOS project files
- Android Gradle files
- package manifests
- scripts used by local development and CI

Important repo signals:
- `Package.swift`
- `Package.resolved`
- `.xcodeproj` / `.xcworkspace`
- `settings.gradle.kts`
- `build.gradle.kts`
- `gradle/libs.versions.toml`
- `gradle.properties`
- `Podfile` if legacy iOS exists
- lint / format config
- test config
- fastlane / xcodebuild / Gradle scripts

---

## Repo Discipline
Reuse good existing patterns.
Do not casually replace working foundations.
Do not mix unrelated refactors into feature work.
Keep diffs understandable.

If the repo is inconsistent:
- improve only the area required by the task
- document systemic issues separately
- avoid surprise rewrites

If the repo is nearly empty:
- create the smallest scalable foundation
- prefer one real working vertical slice over broad scaffolding

---

## Architecture Rules

### General
Prefer:
- layered architecture
- explicit boundaries
- unidirectional data flow
- testable business logic
- minimal cross-module coupling
- dependency injection only when it clearly helps

Avoid:
- feature code directly talking to persistence/network everywhere
- giant god-services
- global mutable state
- UI-driven domain logic
- hidden side effects
- inconsistent async models

### Feature Structure
Prefer features/modules organized by responsibility, not by random file type buckets only.

Good examples:
- `auth`
- `chatlist`
- `chatroom`
- `media`
- `settings`
- `session`
- `security`
- `discovery`

Each feature should have clearly separated:
- UI
- state holder / view model
- domain logic if needed
- repository / data access
- models / mapping when justified

---

## Swift / iOS Rules

### Language and UI
Prefer:
- Swift
- SwiftUI for new UI
- UIKit interop only when required
- structured concurrency with `async/await`
- `@MainActor` where UI state ownership must be explicit

Avoid:
- new Objective-C unless required by an existing integration
- callback pyramids for new code
- business logic embedded in SwiftUI views
- storing secrets in `UserDefaults`

### Packaging and Dependencies
Prefer:
- Swift Package Manager for iOS dependencies
- minimal package footprint
- target-scoped package usage
- committed and updated `Package.resolved`

Do not:
- add CocoaPods for new work unless the repo already depends on it
- add duplicate networking, image, or DI libraries
- add packages without checking maintenance and transitive cost

Before adding a Swift dependency:
- check whether the standard library or Apple frameworks already solve it
- inspect transitive dependencies
- inspect license suitability
- inspect minimum iOS version support
- inspect binary size / runtime cost if relevant
- inspect whether the package is actively maintained
- inspect whether it overlaps with existing repo choices

If changing package dependencies:
- update `Package.resolved`
- ensure CI can resolve packages
- do not leave dependency state half-updated

### iOS Security
For secrets and sensitive material:
- use Keychain
- use LocalAuthentication for app lock / gated access when required
- prefer Secure Enclave backed flows where appropriate for keys
- do not store credentials, recovery material, or encryption secrets in plaintext files, `UserDefaults`, or logs

### iOS Platform Behavior
Respect iOS realities:
- APNs for notifications
- background behavior differs from Android
- force-quit behavior must not be misrepresented in UX
- permission prompts should be intentional and timed

Do not assume Android-like background execution semantics on iOS.

### iOS Validation
When working on iOS, discover the correct scheme/workspace first, then use the narrowest correct command.

Typical commands to prefer:
- `xcodebuild -resolvePackageDependencies -project <Project>.xcodeproj`
- `xcodebuild -resolvePackageDependencies -workspace <Workspace>.xcworkspace -scheme <Scheme>`
- `xcodebuild build -project <Project>.xcodeproj -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16'`
- `xcodebuild test -project <Project>.xcodeproj -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16'`

If the repo uses workspace-based setup, do not use project-only commands blindly.
If the repo uses package-based modules, validate package resolution before larger edits.

---

## Kotlin / Android Rules

### Language and UI
Prefer:
- Kotlin
- Jetpack Compose for new UI
- ViewModel-based UI state holders
- coroutines and Flow
- lifecycle-aware collection and structured async work
- clear immutable UI state models

Avoid:
- new Java unless required by existing integrations
- business logic in composables
- direct repository/network calls from UI
- uncontrolled coroutine scopes
- storing secrets in plain SharedPreferences

### Android Architecture
Prefer:
- UI layer + data layer separation
- unidirectional data flow
- repositories as boundaries
- ViewModel for state production
- explicit error/state handling
- domain layer only when it reduces complexity or improves reuse

Avoid:
- architecture for architecture’s sake
- multiple conflicting patterns in one feature
- direct mutable shared state across screens

### Dependency Management
Prefer:
- Gradle Kotlin DSL if already used
- centralized dependency management
- `gradle/libs.versions.toml` version catalogs when available
- conservative upgrades
- one clear solution per concern

Do not:
- scatter versions across modules
- add repositories ad hoc inside feature modules
- mix multiple DI stacks or multiple HTTP stacks without strong reason
- upgrade AGP/Kotlin casually without checking compatibility

Before adding an Android dependency:
- check whether AndroidX / Kotlin stdlib / existing libs already cover it
- inspect transitive dependencies
- inspect license suitability
- inspect minSdk / targetSdk compatibility
- inspect Compose / Kotlin / AGP compatibility
- inspect method count / binary size implications if relevant
- inspect maintenance status and release stability

If a dependency is not clearly justified, do not add it.

### Android Security
For secrets and sensitive operations:
- use Android Keystore where key material must be protected
- use BiometricPrompt or platform-auth flows where needed
- avoid plaintext token storage
- ensure backup behavior does not leak sensitive state
- review backup rules when handling credentials, recovery data, or encryption state

### Android Platform Behavior
Respect Android realities:
- FCM for mainstream distribution
- privacy-oriented distribution can support UnifiedPush later
- battery, process death, and lifecycle behavior must be handled deliberately
- permissions should be requested contextually
- background behavior must be lifecycle-aware, not assumed

### Android Validation
Use the narrowest relevant Gradle command first.

Typical commands to prefer:
- `./gradlew tasks`
- `./gradlew assembleDebug`
- `./gradlew test`
- `./gradlew lint`
- `./gradlew :app:dependencies`
- `./gradlew :app:dependencyInsight --dependency <name>`

If the repo is multi-module:
- validate only affected modules when possible
- do not run full builds first unless needed

---

## Dependency Policy
Every new dependency must clear a high bar.

Before adding any dependency, verify:
- real need
- scope of usage
- whether existing code already solves it
- maintenance quality
- license suitability
- security posture
- platform/version compatibility
- transitive dependency impact
- CI/build impact
- long-term removal cost

Prefer:
- standard library / platform frameworks first
- official SDKs where appropriate
- well-maintained and widely used libraries only when justified
- single-purpose small libraries over giant frameworks when possible

Avoid:
- alpha or beta dependencies for core production paths unless explicitly approved
- overlapping libraries for the same concern
- dependencies that lock the app into avoidable complexity
- hidden binary blobs without good reason

If a dependency is introduced:
- explain why
- explain why existing options were insufficient
- update lock/resolved files
- validate build and tests
- document any notable tradeoff

---

## Security and Privacy Non-Negotiables
Never violate these rules:

- do not implement custom cryptography
- do not weaken Matrix E2EE assumptions
- do not log message contents
- do not log secrets, tokens, recovery phrases, phone numbers, or key identifiers unnecessarily
- do not store sensitive data in insecure local storage
- do not place plaintext message content into push notification payloads
- do not silently design AI flows that undermine E2EE
- do not expose private identifiers by default
- do not treat recovery, session revocation, or device trust as afterthoughts

Prefer:
- redacted logging
- least-privilege storage
- explicit recovery UX
- privacy-by-default toggles
- defensive error handling around auth/session/security flows

---

## Notifications
Notification behavior must respect platform reality.

- iOS uses APNs
- Android uses FCM for mainstream distribution
- Android privacy-oriented distribution may support UnifiedPush later
- previews must be privacy-aware
- per-chat mute and notification controls should be supported in architecture
- no sensitive payload assumptions
- deeplink behavior must be deliberate and safe

Do not assume iOS and Android behave the same in background or after process termination.

---

## AI Rules
AI is secondary and optional.

Allowed:
- explicit opt-in AI
- local AI where feasible
- clearly separated AI services
- assistive features that do not silently bypass privacy expectations

Not allowed:
- making server-side decryption the hidden default
- coupling core messaging correctness to AI
- vague AI placeholders presented as privacy-safe

If AI is touched, document:
- what data is used
- where processing happens
- whether it is opt-in
- how it interacts with encryption/privacy boundaries

---

## Testing and Validation
Validate every meaningful change.

Prefer:
- narrow test runs first
- unit tests for logic-heavy code
- integration or smoke tests for user flows
- lint/format checks when configured
- module-specific validation before full-repo validation

Prioritize tests for:
- username validation
- phone-number optionality and toggles
- privacy settings
- session/device state
- onboarding logic
- room list loading
- message send happy path
- retry/error handling
- notification settings behavior
- recovery-related state transitions

Do not:
- disable tests to get a green build
- claim validation you did not run
- leave critical logic untested when the repo already has a test pattern

If full platform builds are too heavy:
- still validate syntax
- validate changed modules
- validate affected unit tests
- document what remains unverified

---

## Logging Rules
Logs must never leak sensitive data.

Do not log:
- message bodies
- tokens
- auth headers
- passwords
- phone numbers
- recovery material
- cryptographic key material
- raw server responses containing secrets

Prefer:
- redacted identifiers
- structured error categories
- internal debug logging only in non-production builds
- centralized logging helpers if the repo supports them

---

## Backup / Restore Rules
Treat backup and restore as security-sensitive product behavior.

- do not allow sensitive material to be backed up accidentally
- review Android backup rules when touching auth/session/security storage
- review iOS storage decisions when handling secrets
- recovery flows must be explicit, not implied
- if backup/recovery behavior changes, document it

---

## Documentation Rules
Update docs when the change affects:
- architecture
- dependency strategy
- security model
- notifications
- identity model
- storage/recovery behavior
- CI/build workflow

Prefer:
- `docs/implementation-plan.md`
- `docs/architecture.md`
- `docs/adrs/`
- short focused notes over long vague prose

Document:
- decision
- rationale
- tradeoff
- migration impact if any
- follow-up work

---

## Code Review Standard
Before considering work complete, check:

- Is the code understandable without tribal knowledge?
- Are platform patterns respected?
- Are dependencies justified?
- Are failure states handled?
- Are privacy/security expectations preserved?
- Is the change too broad for one task?
- Are docs/tests aligned with the implementation?

If the answer is no, tighten the change before stopping.

---

## Forbidden Actions
Do not:

- force phone-based identity
- add insecure analytics or ad-tech SDKs
- remove working code without explanation
- fabricate production readiness
- leave security-sensitive flows undocumented
- add broad placeholder scaffolding instead of usable progress
- introduce multiple frameworks for the same concern without a documented reason
- upgrade core tooling casually without checking impact
- hide unresolved blockers

---

## Definition of Ready
A task is ready when:
- goal is clear
- affected platforms are known
- affected modules are known
- constraints are explicit
- dependency impact is understood
- validation path is known
- security/privacy implications are identified

---

## Definition of Done
A task is done only when, where applicable:

- implementation is complete
- error states are handled
- iOS and/or Android validation was run as appropriate
- changed modules build or are syntax-validated
- relevant tests were run
- sensitive data is not exposed in logs/storage
- dependency files are updated consistently
- docs are updated when necessary
- remaining follow-up items are explicit

---

## Response Style for Agent Work
When reporting progress, use this structure:

1. Current repo assessment
2. Plan
3. Changes made
4. Validation performed
5. Risks / assumptions
6. Next highest-value step

Be concise, concrete, and technically honest.

Always include:
- files changed
- commands run
- what was verified
- what was not verified

---

## Stop Rule
Stop when one of these is true:

- the requested slice is implemented and validated
- a real external blocker exists
- the next step requires a larger architectural decision

When stopping, list:
- files changed
- commands run
- remaining follow-up tasks in priority order

Do not keep expanding scope just because more work is possible.
