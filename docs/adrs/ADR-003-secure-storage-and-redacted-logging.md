# ADR-003: Secure Storage and Redacted Logging Policy

- Status: Accepted
- Date: 2026-03-31

## Context
ShadowChat handles privacy-sensitive user data, authentication state, session material, device trust state, and potentially recovery-related information.

Because the product is security-sensitive and mobile-native, the project needs a strict policy for:
- what may be stored locally
- where it may be stored
- what may be logged
- how engineers audit changes touching storage and logging

This must be fixed before implementation to avoid accidental leakage through convenience APIs, debug statements, or poor local persistence choices.

## Decision
Use platform-native secure storage for secrets and apply a centralized redacted logging policy across the product.

## Data Classification
### Class A — Secret Material
Examples:
- auth tokens
- refresh tokens
- session secrets
- recovery material
- private key material or key references where sensitive
- secure-backup secrets

Policy:
- store only in platform-native secure storage
- never write to plaintext files, shared preferences, user defaults, logs, analytics payloads, or crash breadcrumbs

### Class B — Sensitive Identifiers
Examples:
- phone numbers
- email addresses if introduced later
- stable server-side account identifiers where privacy-sensitive
- device identifiers tied to user accounts

Policy:
- do not log raw values
- do not store in insecure caches without explicit justification
- prefer redacted or hashed representations only where operationally necessary

### Class C — Sensitive Operational Metadata
Examples:
- room identifiers in sensitive contexts
- verification flow state
- partial server error bodies
- notification routing metadata

Policy:
- store only where required
- log only in redacted/minimized form
- avoid broad persistence by default

### Class D — Non-Sensitive UI Cache
Examples:
- non-secret visual preferences
- local UI state not tied to secrets
- deterministic display configuration

Policy:
- may use normal local storage if clearly non-sensitive
- must not be mixed with secret storage paths

## Platform Storage Policy
### iOS
Use Keychain for secret material.

Rules:
- no secrets in `UserDefaults`
- no recovery material in plaintext local files
- use platform-native protection classes appropriate to the data sensitivity
- app-lock and gated access flows may use LocalAuthentication where required by UX

### Android
Use Keystore-backed secure storage for secret material.

Rules:
- no secrets in plain SharedPreferences
- no recovery material in unprotected files
- review backup interaction for any persisted auth/session data
- use biometric-gated access only where UX and threat model justify it

## Logging Policy
All logging must go through centralized logging helpers or a clearly defined logging layer once implementation begins.

### Prohibited log fields
Never log:
- message bodies
- auth tokens
- passwords
- phone numbers
- recovery phrases or recovery keys
- cryptographic key material
- full request/response payloads that may contain sensitive data
- raw server error bodies if they may include private identifiers or tokens

### Allowed logging patterns
Allowed:
- redacted identifiers
- stable internal error categories
- retryability and classification flags
- build-type-limited debug diagnostics
- operational counters that do not expose private content

### Redaction rules
When identifiers must appear for correlation:
- use truncated or redacted forms
- avoid reversible masking when not needed
- prefer structured fields over ad hoc string interpolation

## Crash Reporting and Telemetry Rule
No crash or telemetry integration may capture Class A or Class B data.

If crash reporting is introduced later:
- configuration must be reviewed against this ADR
- sensitive payload capture must be explicitly disabled
- breadcrumbs must follow the same redaction rules as logs

## Audit Checklist
Any PR touching storage, auth, session, recovery, or logging paths must be checked against this list:
- Are any Class A values written outside secure storage?
- Are any Class B values logged raw?
- Are new debug prints or console logs introduced?
- Are request/response payloads being logged unsafely?
- Does backup behavior expose sensitive state?
- Are platform-specific storage APIs used correctly?
- Are redaction helpers used instead of manual ad hoc logging?
- Does the change require documentation updates?

## Consequences
### Positive
- clear baseline for privacy-sensitive implementation
- reduced chance of accidental leakage in early development
- easier code review for auth/session/storage changes
- better long-term maintainability of security behavior

### Costs
- slightly higher implementation discipline for debugging
- more up-front work for storage and logging wrappers
- some debugging convenience is intentionally sacrificed

## Alternatives Considered
### Allow temporary raw debug logging during development
Rejected because temporary sensitive logging tends to persist and leak into shared environments.

### Use generic local storage for all client state first, secure it later
Rejected because security-sensitive migrations are harder and riskier after the fact.

## Follow-Up
Create implementation notes or helpers for:
- centralized logger design
- redaction utilities
- storage wrappers per platform
- backup-exclusion rules and testing
