# ADR-002: Identity Normalization and Uniqueness Rules

- Status: Accepted
- Date: 2026-03-31

## Context
ShadowChat uses a username-first identity model. Phone number is optional and must never become the canonical product identity.

Before implementation starts, the system needs clear rules for:
- allowed username syntax
- canonicalization and uniqueness checks
- collision handling
- predictable client and backend validation behavior

Without a strict contract, Swift, Kotlin, and backend implementations can drift and create inconsistent account creation or lookup behavior.

## Decision
Use a normalized username model with instance-wide uniqueness enforced on a canonical value.

### Primary rules
- Username is required.
- Phone number is optional.
- Username is the primary user identity within the product.
- Uniqueness is enforced instance-wide.
- Uniqueness comparisons are case-insensitive via canonical normalization.

## Allowed Username Format
Initial username policy:
- length: 3 to 32 characters
- allowed characters: lowercase ASCII letters `a-z`, digits `0-9`, dot `.`, underscore `_`, hyphen `-`
- username must start with a letter or digit
- username must end with a letter or digit
- consecutive separators are not allowed
- reserved names are blocked

Examples of valid usernames:
- `michael`
- `michael_01`
- `michael.breger`
- `shadow-chat`

Examples of invalid usernames:
- `.michael`
- `michael.`
- `mi`
- `michael..test`
- `Michaël`
- `михаил`

## Canonicalization Algorithm
Canonicalization rules for uniqueness:
1. trim leading and trailing whitespace
2. normalize Unicode input to NFKC before validation
3. reject any character outside the allowed ASCII username set
4. lowercase the result
5. reject if the final value violates syntax rules

The canonical username is the value used for:
- uniqueness checks
- indexing
- lookup
- mention/search identity matching where applicable

## Storage Model
Store at least:
- `username_canonical`
- optionally `display_name` as a separate user-facing field

For initial implementation, `username_canonical` may also be the displayed username value, since the allowed set is already lowercase ASCII only.

Display name remains separate and may support broader character sets later.

## Reserved Names
Block reserved and system-sensitive identifiers such as:
- `admin`
- `administrator`
- `support`
- `security`
- `system`
- `root`
- `null`
- `undefined`

The reserved-name list should be configurable server-side, but client validation may include a baseline deny-list for user feedback.

## Collision Handling
On canonical collision:
- registration fails with a stable `USERNAME_TAKEN` style error
- no automatic suffixing is performed by default
- the client may suggest alternatives, but the backend remains the source of truth

Do not silently mutate user identity during registration.

## Client and Backend Validation Responsibilities
### Client responsibilities
- run fast local validation
- show clear inline feedback
- normalize input consistently for preview and preflight checks
- never assume local validation alone is authoritative

### Backend responsibilities
- re-run canonicalization and validation
- enforce uniqueness at persistence level
- return stable machine-readable error codes
- remain authoritative in all acceptance/rejection decisions

## Consequences
### Positive
- predictable username behavior across iOS, Android, and backend
- reduced impersonation/confusion risk from case-only variants
- simpler initial search and lookup behavior
- clearer testing surface for identity logic

### Costs
- no non-ASCII usernames in the initial version
- migration work may be required later if broader username policy is desired
- stricter upfront constraints may reduce flexibility in early community feedback

## Alternatives Considered
### Preserve original-case usernames and compare case-insensitively
Rejected for initial implementation because it adds avoidable presentation and normalization complexity.

### Allow arbitrary Unicode usernames
Rejected for initial implementation because it introduces confusable character risk, more complex canonicalization, and cross-platform inconsistency early.

### Auto-suffix conflicting usernames
Rejected because silent mutation of identity is harder to reason about and complicates trust.

## Follow-Up
Create implementation notes or tests for:
- canonicalization helper behavior
- reserved-name policy ownership
- username search and mention matching rules
- future rename policy, if username changes are allowed later
