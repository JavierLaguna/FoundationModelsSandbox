import Foundation

/// Represents a single message exchange in a conversation
struct MessageEntry: Identifiable, Sendable, Equatable, Codable {
    let id: UUID
    let prompt: String
    var outcome: SessionOutcome
    let timestamp: Date

    init(
        id: UUID = UUID(),
        prompt: String,
        outcome: SessionOutcome,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.prompt = prompt
        self.outcome = outcome
        self.timestamp = timestamp
    }
}
