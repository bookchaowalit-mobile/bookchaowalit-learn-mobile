# Upgrade plan

## Current state

Score: 3/10 (was 1/10) — domain logic + XCTest suite and honest CI exist, but
nothing has been compiled yet (no Swift toolchain was available when this was
written) and the UI is still a placeholder.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P0: Add an Xcode app target (`@main`) that hosts `LearnUI`, and build screens on
  top of `LearnCore` (an `@Observable` model wrapping the core API).
- P1: Study session UI (flip card, grade buttons) and deck list on top of `Deck`.
- P1: Persist decks (SwiftData) and import from CSV.
- P2: Add a Linux CI job that runs `swift test --filter LearnCoreTests` after
  making the UI target conditional, to keep the core portable.

## Done in this pass (pass 1)

- Split the package into `LearnCore` (Foundation-only logic), `LearnUI` (existing
  SwiftUI shell) and `LearnCoreTests` (6 XCTest cases).
- Removed `@main` from the library target (it belongs in an app target).
- CI: removed `|| echo` / `|| true` so build and test failures are visible.
- README now states what is verified and what is not.
- New Swift sources were syntax-checked with tree-sitter-swift only.

## Done in this pass (pass 2)

- Static compile review only (no Swift toolchain in this environment): read every
  source and test file for type/API errors (access levels across modules, tuple
  labels, closure destructuring, result-builder declarations, macOS 14/iOS 17
  API availability, `@testable` usage). No compile errors found; nothing changed.
  All files also parse cleanly with tree-sitter-swift.
- The P0 item (confirm the macOS `swift build` / `swift test` CI job is green) stays open.
