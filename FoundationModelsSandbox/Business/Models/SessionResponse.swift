import Foundation

/// Lightweight response type that wraps the data extracted from a `LanguageModelSession.Response`.
/// It is fully constructable in tests, unlike the system framework's response type.
struct SessionResponse: Sendable, Equatable {
    let content: String
    let duration: Double
    let promptTokenCount: Int
    let responseTokenCount: Int
}
