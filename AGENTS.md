# AGENTS.md

## Scope and current shape
- This repo is a single Xcode project (`FoundationModelsSandbox.xcodeproj`) with two targets: app and unit tests (UI tests target was removed).
- There is no Swift Package manifest, no CI workflow, no lint/typecheck/format config, and no repo-local OpenCode instruction config (`opencode.json`) at the time of writing.
- **Swift Package dependencies**: Mockable (test mocking), sqlite-data (session persistence via GRDB), plus their transitive dependencies (swift-dependencies, swift-perception, GRDB, etc.).

## Verified commands (don’t guess)
- List available schemes/targets:
  - `xcodebuild -list -project "FoundationModelsSandbox.xcodeproj"`
- Build app (macOS):
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' build`
- Run all tests:
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' test`
- Run only unit tests target:
  - `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' -only-testing:FoundationModelsSandboxTests test`
- Test status: **212 tests** (all Swift Testing, no XCTest). Run with `-parallel-testing-enabled NO` for stable results.
- Run a specific test suite: `xcodebuild -project "FoundationModelsSandbox.xcodeproj" -scheme "FoundationModelsSandbox" -destination 'platform=macOS' -skipMacroValidation -parallel-testing-enabled NO -only-testing:FoundationModelsSandboxTests/HistoryViewModelTests test`

## Command-order / defaults that can bite
- `xcodebuild` defaults to **Release** if you omit scheme/configuration (`xcodebuild -list` reports this); pass scheme (and config if needed) explicitly.
- Use `-destination 'platform=macOS'` for deterministic local runs.
- **Macro approval**: `sqlite-data`'s transitive dependency `swift-perception` includes macros that require approval. In CI/CLI, pass `-skipMacroValidation` to `xcodebuild`. Without it, builds fail with `Macro … was changed since a previous approval and must be enabled`.
- **Parallel test flakiness**: Some tests (especially those involving `Task { }` in ViewModel init) can crash under parallel test execution. Use `-parallel-testing-enabled NO` for stable local runs.

## Architecture map (high-signal)
- App entrypoint: `FoundationModelsSandbox/FoundationModelsSandboxApp.swift` (`@main`, loads `MainView`).
- **Clean Architecture** folder structure:
  - `Business/` - Interactors (e.g., `FoundationModelsInteractor`), Use Cases, Error types
  - `Business/Repositories/` - Data persistence layer (Repository pattern, currently `SessionRepository` + `LiveSessionRepository` using SQLite/GRDB)
  - `Components/` - Reusable UI components (SwiftUI Views)
  - `Scenes/` - Feature modules/scenes with ViewModels
- UI uses `@Observable` ViewModels for state management.
- **Dependency Injection**: Pass dependencies via initializers. Use protocols for testability.
- **Persistence**: Session data stored via SQLite using GRDB (from the `sqlite-data` package). The database lives at `~/Library/Application Support/FoundationModelsSandbox/sessions.db`. Messages are serialized as JSON in a text column.
  - `SessionRepository` has a `lastSession()` method (SQL `LIMIT 1`) for efficient single-session restoration — prefer over `allSessions().first`.
- Tests:
  - `FoundationModelsSandboxTests/` uses **Swift Testing** (`import Testing`, `@Test`), not XCTest.
  - `FoundationModelsSandboxUITests/` uses XCTest UI testing and launches the app via `XCUIApplication()`.
  - Test files mirror the app's folder structure (e.g., `Business/Models/`, `Business/Interactors/`, `Scenes/Main/`).
  - **Mocks**: Uses **Mockable** library (`@Mockable` macro on protocols). No manual mocks - mocks generated at compile time when `MOCKING` flag is set.
  - **Testing ViewModels with Mockable**: ViewModels that call dependencies in `init` need `MockerPolicy.default = .relaxed` in the test struct's `init()` to avoid crashes from unstubbed mock calls during initialization.
  - **Mockable stubs are sticky**: With `MockerPolicy.default = .relaxed`, `given(mock).method().willReturn(value)` makes the mock return the same value on every subsequent call. You CANNOT change the return value mid-test by calling `given()` again — the first stub persists. Plan your test stubs accordingly.
  - **Async ViewModel init with Mockable**: If the ViewModel spawns a `Task` in `init`, use `await Task.yield()` in tests to let the task complete before making assertions. The task runs on the main actor because the ViewModel is `@MainActor`.
  - **Session restoration uses `lastSession()`**: `PlaygroundViewModel.restoreLastSession()` now calls `sessionRepository.lastSession()` (uses SQL `LIMIT 1`) instead of `allSessions().first`. Stub with `given(mock).lastSession().willReturn(nil)` in tests.
  - **Code Coverage**: Configured in `FoundationModelsSandbox.xctestplan` with exclusions for `**/*View.swift` and `**/Components/**/*.swift`. ViewModels are included in coverage.

## Observable patterns
- **`didSet` works with `@Observable`**: Property observers (`didSet`/`willSet`) fire normally on `@Observable` properties. This is useful for syncing a ViewModel property with a model property (e.g., `var instructions: String = "" { didSet { session.instructions = instructions } }`).
- **Bindings bypass methods**: When a view uses `$viewModel.property` as a `Binding`, writes go directly to the stored property, not through helper methods like `updateInstructions()`. Use `didSet` if you need side effects on every write.

## Async/await + Swift 6 Strict Concurrency
- All asynchronous flows MUST use `async`/`await`. No completion handlers.
- Use Swift Concurrency features: `Task`, `@MainActor`, `actor` isolation.
- Prefer structured concurrency over unstructured `Task`.
- **Swift 6 Strict Concurrency** (`SWIFT_STRICT_CONCURRENCY = complete`) is enabled:
  - All types must be `Sendable` unless explicitly marked otherwise.
  - Use `@MainActor` for UI-bound state and actors for shared mutable state.
  - `nonisolated` for immutable computed properties in actors.
- **🚫 STRICTLY PROHIBITED** — `@unchecked Sendable` and `@preconcurrency` are **never acceptable**:
  - If the compiler rejects Sendable conformance, fix the root cause (use `@MainActor`, an `actor`, or `let` + value types). Never silence the checker.
  - Apple SDK types that are already `@unchecked Sendable` (e.g., `LanguageModelSession`) are fine to *use* — we just can't add our own `@unchecked` on top.
- **In tests**: Use `@MainActor` on test structs when the source types have `@MainActor`-isolated properties (common with SwiftUI models).

## Installed skills (high-priority for this repo)
- **`swift-concurrency`** — Use for any concurrency-sensitive work:
  - Data races, actor isolation, `Sendable` issues, task cancellation, or callback-to-`async/await` migrations.
  - Swift 6 strict concurrency compiler warnings/errors.
  - Refactors in interactors/repositories/view models where thread-safety and isolation are critical.
  - Expected output: concrete code changes + isolation rationale (`@MainActor`, `actor`, `nonisolated`, `Sendable`) + test impact.
- **`swiftui-expert-skill`** — Use for SwiftUI architecture and UI quality work:
  - View composition, state ownership (`@State`/`@Bindable`), navigation patterns, and performance/readability improvements.
  - Liquid Glass styling, `NavigationSplitView`, and component-level SwiftUI best practices.
  - Localization-safe UI updates (prefer `Text("key")` for reactive language changes).
  - Expected output: idiomatic SwiftUI code aligned with this repo’s patterns.
- **When both apply**:
  - Run `swift-concurrency` first for model/view model isolation decisions.
  - Then run `swiftui-expert-skill` to shape final UI/state wiring on top of safe concurrency boundaries.

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

## Test Warnings to Avoid
- **Don't use `is` for type checks**: `#expect(result is [Type])` always returns true because the type is already known. Use other assertions instead.
- **Don't compare non-optionals to nil**: SwiftUI types like `Color` are non-optional. Use `#expect(color != Color.clear)` instead of `#expect(color != nil)`.

## ViewModel State Management in Navigation
- **Preserving state across screens**: When a ViewModel needs to persist its state when navigating between screens (e.g., switching between Playground, History, Settings), create the ViewModel at the parent view level (e.g., `MainView`) and pass it down to child views via initializer.
- **Resetting session/state**: To reset a ViewModel (e.g., "New Chat" button), simply create a new instance: `viewModel = PlaygroundViewModel()`.
  - **IMPORTANT**: When creating a new ViewModel for "New Chat", pass `shouldRestoreLastSession: false` to prevent automatically loading the last saved session:
    ```swift
    playgroundViewModel = PlaygroundViewModel(
        sessionRepository: sessionRepository,
        shouldRestoreLastSession: false
    )
    ```
  - The default `shouldRestoreLastSession: true` is used on app launch so the user returns to their last conversation.
- **Loading a specific session**: Use `PlaygroundViewModel.loadSession(_:)` to load a specific `ConversationSession` (from history, restoration, etc.). This sets `session`, `instructions`, `selectedModelName`, and `aiResponse` from the given session:
  ```swift
  let vm = PlaygroundViewModel(sessionRepository: repo, shouldRestoreLastSession: false)
  vm.loadSession(selectedSession)
  ```
- **Session selection from History → Playground**: The `HistoryView` exposes an `onSelectSession: ((ConversationSession) -> Void)?` closure. In `MainView`, wire it to create a fresh `PlaygroundViewModel` and navigate:
  ```swift
  HistoryView(
      viewModel: historyViewModel,
      onSelectSession: { session in
          playgroundViewModel = PlaygroundViewModel(
              sessionRepository: sessionRepository,
              shouldRestoreLastSession: false
          )
          playgroundViewModel.loadSession(session)
          selectedSection = .playground
      }
  )
  ```
- **Navigation from child views**: Pass navigation state (`@Binding`) and callbacks (e.g., `onNewChat: () -> Void`, `onSelectSession:`) from parent to child views to control navigation from the sidebar or other components.

### Example Pattern
```swift
// MainView.swift - Parent creates and owns the ViewModel
struct MainView: View {
    @State private var selectedSection: NavigationRoute = .playground
    @State private var playgroundViewModel = PlaygroundViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedSection: $selectedSection,
                onNewChat: {
                    playgroundViewModel = PlaygroundViewModel()  // Reset
                    selectedSection = .playground                 // Navigate
                }
            )
        } detail: {
            switch selectedSection {
            case .playground:
                PlaygroundView(viewModel: playgroundViewModel)  // Pass down
            // ...
            }
        }
    }
}

// PlaygroundView.swift - Child receives ViewModel via init
struct PlaygroundView: View {
    @State private var viewModel: PlaygroundViewModel

    init(viewModel: PlaygroundViewModel = PlaygroundViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    // ...
}
```

### Injecting shared dependencies (e.g., SessionRepository)
When a ViewModel needs persistence or other shared services, create those at the `App` level and inject them through `MainView`:
```swift
// FoundationModelsSandboxApp.swift
@main
struct FoundationModelsSandboxApp: App {
    private let sessionRepository: any SessionRepository
    
    init() {
        self.sessionRepository = LiveSessionRepository.makeDefault()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(
                systemLocale: Self.systemLocale,
                sessionRepository: sessionRepository
            )
        }
    }
}
```

## Search Pattern
- **`.searchable` with `@Observable` ViewModel**: Add `searchQuery: String` to the ViewModel and a `filteredSessions` computed property. The view binds `$viewModel.searchQuery` to `.searchable`:
  ```swift
  // ViewModel
  var searchQuery: String = ""
  var isSearching: Bool { !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty }

  var filteredSessions: [ConversationSession] {
      let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
      guard !trimmed.isEmpty else { return sessions }
      return sessions.filter { session in
          session.firstPrompt?.localizedStandardContains(trimmed) == true ||
          session.lastResponsePreview?.localizedStandardContains(trimmed) == true
      }
  }

  // View
  .searchable(text: $viewModel.searchQuery, prompt: Text("Search sessions…"))
  ```
- **Empty search results**: Use `ContentUnavailableView.search(text:)` when `isSearching && filteredSessions.isEmpty`:
  ```swift
  } else if viewModel.isSearching && viewModel.filteredSessions.isEmpty {
      ContentUnavailableView.search(text: viewModel.searchQuery)
  }
  ```
- Keep filtering logic in the ViewModel, not inline in the view body.

## @Bindable vs @State for @Observable ViewModels
- **Owned ViewModel** (view creates it): use `@State private var` — SwiftUI preserves the instance across redraws.
- **Received ViewModel** (passed from parent): use `@Bindable var` — semantically correct, expresses that the view doesn't own the model. If the init has a default value, assign directly:
  ```swift
  struct HistoryView: View {
      @Bindable var viewModel: HistoryViewModel
      let onSelectSession: ((ConversationSession) -> Void)?

      init(viewModel: HistoryViewModel = HistoryViewModel(), ...) {
          self.viewModel = viewModel
          // ...
      }
  }
  ```
