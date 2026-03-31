# ADR-004: GitHub Actions CI Baseline

- Status: Accepted
- Date: 2026-03-31

## Context
ShadowChat is hosted on GitHub and needs an initial CI baseline before implementation begins.

The project will involve:
- iOS code
- Android code
- shared core work
- security-sensitive behavior
- dependency-sensitive build pipelines

The first CI setup must be simple, predictable, and aligned with incremental development. It should validate the repository without introducing unnecessary release complexity too early.

## Decision
Use GitHub Actions as the initial CI provider and define a conservative baseline of required validation jobs.

## Initial CI Scope
The initial baseline should cover:
- repository and documentation sanity
- iOS dependency resolution and build validation once iOS code exists
- Android dependency resolution and build validation once Android code exists
- Rust formatting/lint/test validation once Rust code exists

CI should evolve in step with actual repository contents.

## Required Jobs
### 1. Docs / Repo Sanity
Purpose:
- ensure repository basics remain coherent
- catch missing docs references or obvious structural regressions where scripted checks exist

Initial examples:
- markdown/link or structure checks if simple and stable
- basic repository script validation if added later

### 2. iOS Baseline Job
Run once iOS project files exist.

Minimum expectations:
- resolve Swift package dependencies
- build the main scheme for simulator
- run affected tests when available

Do not overcomplicate the initial job with signing or release-only requirements.

### 3. Android Baseline Job
Run once Android project files exist.

Minimum expectations:
- Gradle sync-compatible setup
- `assembleDebug`
- `test`
- `lint`

Prefer module-scoped optimization later only when the repo structure justifies it.

### 4. Rust Core Job
Run once Rust shared core exists.

Minimum expectations:
- `cargo fmt --check`
- `cargo clippy` with agreed baseline settings
- `cargo test`

## Branch Protection Expectations
For the default branch:
- require PR-based changes for normal development once the project becomes active
- require passing baseline CI checks before merge
- do not bypass failing checks casually
- keep branch protection aligned with actual implemented jobs

If the repository is still documentation-heavy early on, branch protection may stay lightweight until code-bearing workflows exist.

## Failure Policy
- failing required CI jobs block merge
- flaky jobs must be fixed, quarantined, or removed from required status; they must not remain permanently required and unstable
- red builds must not be normalized
- temporary bypasses must be explicit and documented

## CI Design Rules
- keep jobs understandable
- prefer deterministic checks over fragile environment-dependent ones
- prefer fast baseline validation over large slow pipelines initially
- avoid secret-heavy workflows early unless necessary
- avoid release automation in the first baseline unless the repo has real release artifacts

## Consequences
### Positive
- CI starts simple and matches actual project maturity
- GitHub-native workflow for a GitHub-hosted project
- clear merge quality gate as code begins to land
- easier future extension toward matrix builds, previews, and release automation

### Costs
- macOS runners for iOS can be slower and more expensive than Linux jobs
- some later refactoring of workflows is expected as the repo grows
- branch protection needs deliberate maintenance as jobs evolve

## Alternatives Considered
### Multiple CI providers from the start
Rejected because it adds operational complexity without early payoff.

### No CI until the first app shells are implemented
Rejected because baseline workflow discipline should exist before the repo starts accumulating real code.

### Full release automation immediately
Rejected because early focus should be validation, not deployment complexity.

## Follow-Up
When implementation starts, add concrete workflow definitions for:
- docs sanity
- iOS baseline build
- Android baseline build
- Rust baseline checks
- branch protection configuration notes
