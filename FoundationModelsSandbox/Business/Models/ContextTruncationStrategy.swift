import Foundation

/// Strategies for handling conversation context when the model's token window is full.
enum ContextTruncationStrategy: String, CaseIterable, Codable, Sendable {
    /// Automatically removes the oldest messages from the transcript when context is full.
    case dropOldest

    /// Summarizes old messages to fit within the context window (future implementation).
    case summarize

    // Temporarily disabled — case manual

    /// Localized display name for the strategy.
    var displayName: String {
        switch self {
        case .dropOldest:
            NSLocalizedString("Auto-truncate", comment: "Auto-truncate strategy option")
        case .summarize:
            NSLocalizedString("Summarize", comment: "Summarize strategy option")
        }
    }
}
