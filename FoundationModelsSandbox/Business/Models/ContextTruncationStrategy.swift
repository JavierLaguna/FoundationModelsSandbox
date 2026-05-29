import Foundation

/// Strategies for handling conversation context when the model's token window is full.
enum ContextTruncationStrategy: String, CaseIterable, Codable, Sendable {
    /// Automatically removes the oldest messages from the transcript when context is full.
    case dropOldest

    /// Summarizes old messages to fit within the context window (future implementation).
    case summarize
    
    // Temporarily disabled — case manual
}
