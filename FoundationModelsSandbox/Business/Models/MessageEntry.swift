import Foundation

/// Represents a single message exchange in a conversation
struct MessageEntry: Identifiable, Sendable, Equatable {
    let id: UUID
    let prompt: String
    var outcome: SessionOutcome
    let timestamp: Date = Date()

    init(id: UUID = UUID(), prompt: String, outcome: SessionOutcome) {
        self.id = id
        self.prompt = prompt
        self.outcome = outcome
    }
}