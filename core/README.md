# Shared Core

This directory is reserved for shared logic used across mobile platforms.

Planned role:
- shared messaging core
- session and room abstractions
- security-sensitive client integration boundaries
- Matrix SDK integration strategy

Preferred direction:
- Matrix Rust SDK based shared core, if and when the repository reaches implementation stage

Rules:
- keep platform UI logic out of shared core
- keep security and session boundaries explicit
- avoid speculative abstraction before real product slices exist
