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
- **Dependency Injection**: Pass dependencies via initializers. Use protocols for testability.
- Tests:
  - `FoundationModelsSandboxTests/` uses **Swift Testing** (`import Testing`, `@Test`), not XCTest.
  - `FoundationModelsSandboxUITests/` uses XCTest UI testing and launches the app via `XCUIApplication()`.

## Async/await + Swift 6 Strict Concurrency
- All asynchronous flows MUST use `async`/`await`. No completion handlers.
- Use Swift Concurrency features: `Task`, `@MainActor`, `actor` isolation.
- Prefer structured concurrency over unstructured `Task`.
- **Swift 6 Strict Concurrency** (`SWIFT_STRICT_CONCURRENCY = complete`) is enabled:
  - All types must be `Sendable` unless explicitly marked otherwise.
  - Use `@MainActor` for UI-bound state and actors for shared mutable state.
  - `nonisolated` for immutable computed properties in actors.
  - `@unchecked Sendable` only when truly safe (document why).

## UI Design Guidelines
- Follow **Apple Human Interface Guidelines** for all UI elements.
- Use **Liquid Glass** styling with the official Apple API:
  - `.glassEffect()` modifier on views (from `SwiftUI.View`)
  - `.glassEffect(_:in:)` for custom glass config with shape
  - `GlassEffectContainer` for grouping multiple glass-effect views
  - See `Common/Styles/Theme.swift` for `liquidGlass()` convenience wrapper
- Use native SwiftUI components: `List` with `.listStyle(.sidebar)`, `.buttonStyle(.bordered)`, `.buttonStyle(.borderedProminent)`.
- Use `NavigationSplitView` for three-column layouts.
- Use SF Symbols for all icons (system images).
- Spacing constants defined in `Theme.swift` via `Spacing` enum (8pt grid system).
- Corner radius constants via `CornerRadius` enum.

## Repo-specific constraints
- Deployment target is macOS 26.4 (`MACOSX_DEPLOYMENT_TARGET = 26.4` in project settings), so older local runtimes/toolchains may fail builds.
- Project uses Xcode file-system synchronized groups (`PBXFileSystemSynchronizedRootGroup`): add/move source files through Xcode (or verify project references carefully) to avoid missing-file/build-graph drift.

## Localization System
- Translations are stored in `FoundationModelsSandbox/Localizable.xcstrings` (JSON format).
- Supported languages: English (en), Spanish (es).
- The app has a language switcher in Settings that changes the UI language at runtime.

### How to add new translations
1. Add the key with translations in `Localizable.xcstrings`:
   ```json
   "Your key" : {
     "localizations" : {
       "en" : { "stringUnit" : { "state" : "translated", "value" : "English text" } },
       "es" : { "stringUnit" : { "state" : "translated", "value" : "Texto en español" } }
     }
   }
   ```

### How to use translations in SwiftUI (CORRECT WAY)
- **For reactive language updates**: Use `Text("key")` directly. This creates a `Text` view that automatically updates when the language changes.
  ```swift
  Text("Your key")
  ```
- **WRONG way**: Using `String(localized: "Your key")` or storing in a `String` variable - these evaluate once and won't update reactively.
- **For non-reactive cases** (e.g., button labels in alerts): You can use `String(localized: "Your key")` if the value is read once at creation time.

### Example: Placeholder in custom text field
```swift
// ✅ CORRECT - reactive to language changes
struct MyTextField: View {
    var placeholder: Text  // Use Text, not String
    var body: some View {
        // ...
        .overlay {
            if text.isEmpty {
                placeholder.foregroundStyle(.tertiary)
            }
        }
    }
}

// Usage:
MyTextField(placeholder: Text("Enter your prompt..."))
```

## Git Workflow
- **AI agents must NOT commit changes to the repository** unless explicitly instructed by the user.
- When the user requests a commit, the agent should:
  1. Show the changes (`git status`, `git diff`)
  2. Propose a commit message following the repo's commit style
  3. Wait for user confirmation before executing `git commit`
- If the user asks to "commit all changes" without specifying details, proceed with the commit.

## Localization Requirements
- **ALWAYS use the translation system** (`Localizable.xcstrings`) for any user-facing text literals.
- **ALL supported languages must be translated**: When adding a new key, provide translations for both English (en) and Spanish (es).
- **Use app context for translations**: Translate based on the app's domain (AI/Foundation Models), not literally. For example:
  - "Playground" → "Laboratorio" (not "Patio de juegos")
  - "Prompt" → Keep as "Prompt" or use context-appropriate term
- **Never hardcode user-facing strings** in SwiftUI views - always use `Text("key")` with the translation key.

## File Header Requirements
- **NEVER add Xcode-generated boilerplate headers** to new files. This includes:
  ```swift
  //
  //  FileName.swift
  //  FoundationModelsSandboxTests
  //
  //  Created by Javier Laguna on DD/MM/YYYY.
  //
  ```
- New files should start directly with imports and code.
- This applies to all new Swift files (app code, tests, etc.).
