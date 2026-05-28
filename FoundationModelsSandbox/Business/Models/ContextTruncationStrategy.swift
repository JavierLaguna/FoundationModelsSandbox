import Foundation

/// Strategies for handling conversation context when the model's token window is full.
enum ContextTruncationStrategy: String, Codable, Sendable, CaseIterable {
    /// Automatically removes the oldest messages from the transcript when context is full.
    case dropOldest
    /// The user manually decides which messages to keep (future implementation).
    case manual
    /// Summarizes old messages to fit within the context window (future implementation).
    case summarize
}
