# AGENTS.md

## Scope and current shape
- This repo is a single Xcode project (`FoundationModelsSandbox.xcodeproj`) with three targets: app, unit tests, UI tests.
- There is no Swift Package manifest, no CI workflow, no lint/typecheck/format config, and no repo-local OpenCode instruction config (`opencode.json`) at the time of writing.

## Verified commands (don’t guess)
- List available schemes/targets:
  - `xcodebuild -list -project "FoundationModelsSandbox.xcodeproj"`
- Build app (macOS):
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' build`
- Run all tests:
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' test`
- Run only unit tests target:
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' -only-testing:FoundationModelsSandboxTests test`
- Run only UI tests target:
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' -only-testing:FoundationModelsSandboxUITests test`

## Command-order / defaults that can bite
- `xcodebuild` defaults to **Release** if you omit scheme/configuration (`xcodebuild -list` reports this); pass scheme (and config if needed) explicitly.
- Use `-destination 'platform=macOS'` for deterministic local runs.

## Architecture map (high-signal)
- App entrypoint: `FoundationModelsSandbox/FoundationModelsSandboxApp.swift` (`@main`, loads `MainView`).
- **Clean Architecture** folder structure:
  - `Business/` - Interactors (e.g., `FoundationModelsInteractor`), Use Cases, Error types
  - `Components/` - Reusable UI components (SwiftUI Views)
  - `Scenes/` - Feature modules/scenes with ViewModels
- UI uses `@Observable` ViewModels for state management.
- Tests:
  - `FoundationModelsSandboxTests/` uses **Swift Testing** (`import Testing`, `@Test`), not XCTest.
  - `FoundationModelsSandboxUITests/` uses XCTest UI testing and launches the app via `XCUIApplication()`.

## Async/await priority
- All asynchronous flows MUST use `async`/`await`. No completion handlers.
- Use Swift Concurrency features: `Task`, `@MainActor`, `actor` isolation.
- Prefer structured concurrency over unstructured `Task`.

## Repo-specific constraints
- Deployment target is macOS 26.4 (`MACOSX_DEPLOYMENT_TARGET = 26.4` in project settings), so older local runtimes/toolchains may fail builds.
- Project uses Xcode file-system synchronized groups (`PBXFileSystemSynchronizedRootGroup`): add/move source files through Xcode (or verify project references carefully) to avoid missing-file/build-graph drift.
