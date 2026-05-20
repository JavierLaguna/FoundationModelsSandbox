import Foundation

/// Represents a single message exchange in a conversation
struct MessageEntry: Identifiable, Sendable {
    let id = UUID()
    let prompt: String
    let outcome: SessionOutcome
    let timestamp: Date = Date()
}