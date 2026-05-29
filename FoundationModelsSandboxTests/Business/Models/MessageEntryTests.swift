import Testing
import Foundation
@testable import FoundationModelsSandbox

@MainActor
struct MessageEntryTests {

    // MARK: - Init

    @Test
    func init_withPromptAndOutcome_createsEntry() {
        let outcome = SessionOutcome.success(
            AIResponse(content: "Hello!", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10, contextSize: 4096)
        )
        let entry = MessageEntry(prompt: "Hi", outcome: outcome)

        #expect(entry.prompt == "Hi")
        #expect(entry.outcome == outcome)
    }

    @Test
    func init_generatesUniqueId() {
        let entry1 = MessageEntry(prompt: "A", outcome: .noResponse)
        let entry2 = MessageEntry(prompt: "B", outcome: .noResponse)
        #expect(entry1.id != entry2.id)
    }

    @Test
    func init_defaultTimestamp_isCurrentTime() {
        let before = Date()
        let entry = MessageEntry(prompt: "Test", outcome: .noResponse)
        let after = Date()
        #expect(entry.timestamp >= before && entry.timestamp <= after)
    }

    @Test
    func init_withCustomTimestamp_usesProvidedValue() {
        let customDate = Date(timeIntervalSince1970: 1_234_567_890)
        let entry = MessageEntry(
            prompt: "Test",
            outcome: .noResponse,
            timestamp: customDate
        )
        #expect(entry.timestamp == customDate)
    }

    // MARK: - Equatable

    @Test
    func entriesWithSameId_areEqual() {
        let id = UUID()
        let timestamp = Date()
        let entry1 = MessageEntry(id: id, prompt: "Hello", outcome: .noResponse, timestamp: timestamp)
        let entry2 = MessageEntry(id: id, prompt: "Hello", outcome: .noResponse, timestamp: timestamp)
        #expect(entry1 == entry2)
    }

    @Test
    func entriesWithDifferentIds_areNotEqual() {
        let entry1 = MessageEntry(prompt: "A", outcome: .noResponse)
        let entry2 = MessageEntry(prompt: "A", outcome: .noResponse)
        #expect(entry1 != entry2)
    }

    // MARK: - Outcome mutation

    @Test
    mutating func outcome_canBeMutated() {
        let successOutcome = SessionOutcome.success(
            AIResponse(content: "OK", duration: 0.1, promptTokenCount: 1, responseTokenCount: 1, contextSize: nil)
        )
        var entry = MessageEntry(prompt: "Hi", outcome: .noResponse)
        entry.outcome = successOutcome
        #expect(entry.outcome == successOutcome)
    }

    // MARK: - Codable

    @Test
    func roundTripCodable() throws {
        let original = MessageEntry(
            prompt: "What is Swift?",
            outcome: .success(
                AIResponse(content: "A language", duration: 0.3, promptTokenCount: 5, responseTokenCount: 10, contextSize: 4096)
            )
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MessageEntry.self, from: data)
        #expect(decoded == original)
        #expect(decoded.prompt == original.prompt)
        #expect(decoded.outcome == original.outcome)
    }

    @Test
    func roundTripCodable_withFailureOutcome() throws {
        let original = MessageEntry(
            prompt: "Hello",
            outcome: .failure("Something went wrong")
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MessageEntry.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func roundTripCodable_withNoResponseOutcome() throws {
        let original = MessageEntry(
            prompt: "Hi",
            outcome: .noResponse
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MessageEntry.self, from: data)
        #expect(decoded == original)
    }
}
