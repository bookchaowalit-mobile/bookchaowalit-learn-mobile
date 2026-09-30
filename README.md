# Learn — Mobile

SwiftUI app for **Learn** — study with flashcards and spaced repetition.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/LearnCore` — Foundation-only domain logic, unit-tested in
  `Tests/LearnCoreTests` (XCTest).
- `Sources/LearnUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `LearnCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`LearnCore`)

- SuperMemo-2 scheduling: 1 → 6 → interval × easiness, easiness floor 1.3, resets and lapse counting on failed recalls
- Decks with trimmed, case-insensitive duplicate-free cards
- Daily study queue: overdue reviews first (most overdue first), then a capped number of new cards
- Mastery fraction (interval ≥ 21 days)

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs LearnCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/learn-frontend](https://github.com/bookchaowalit-website/bookchaowalit-learn-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
