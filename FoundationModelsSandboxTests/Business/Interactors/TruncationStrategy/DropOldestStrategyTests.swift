import Testing
import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

struct DropOldestStrategyTests {

    private let sut = DropOldestStrategy()
    private let anyModel = SystemLanguageModel.default

    // MARK: - Happy path

    @Test
    func truncate_withMultipleExchanges_dropsOldestHalf() async throws {
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [
                ("Hello", "Hi!"),
                ("How are you?", "Great!"),
                ("What is Swift?", "A language."),
                ("What is SwiftUI?", "A framework.")
            ]
        )

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: FakeSessionProvider()
        )

        let entries = Array(result)
        // Instructions entry + 4 kept entries (last half of 8 = 4)
        #expect(entries.count == 5)

        // The first entry should still be instructions
        if case .instructions = entries[0] { } else {
            Issue.record("Expected first entry to be instructions")
        }

        // The last kept entries should be the most recent ones
        if case .response(let response) = entries[entries.count - 1] {
            let text = extractText(from: response)
            #expect(text == "A framework.")
        } else {
            Issue.record("Expected last entry to be the most recent response")
        }
    }

    // MARK: - Edge cases

    @Test
    func truncate_withOnlyInstructions_returnsJustInstructions() async throws {
        let transcript = makeTranscript(instructions: "Be helpful.", exchanges: [])

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: FakeSessionProvider()
        )

        let entries = Array(result)
        #expect(entries.count == 1)

        if case .instructions = entries[0] { } else {
            Issue.record("Expected entry to be instructions")
        }
    }

    @Test
    func truncate_withOddExchanges_dropsOldestHalf() async throws {
        // 3 exchanges = 6 non-instruction entries, half = 3, keep = 3
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [
                ("A", "1"),
                ("B", "2"),
                ("C", "3")
            ]
        )

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: FakeSessionProvider()
        )

        let entries = Array(result)
        // Instructions + 3 kept entries
        #expect(entries.count == 4)
    }

    @Test
    func truncate_withSingleExchange_keepsHalf() async throws {
        // 1 exchange = 2 entries, half = 1, keep = 1
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [("Only", "One")]
        )

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: FakeSessionProvider()
        )

        let entries = Array(result)
        // Instructions + 1 kept entry
        #expect(entries.count == 2)

        // The kept entry should be the response
        if case .response(let response) = entries[1] {
            let text = extractText(from: response)
            #expect(text == "One")
        } else {
            Issue.record("Expected second entry to be the response")
        }
    }

    @Test
    func truncate_withEmptyTranscript_returnsEmpty() async throws {
        let transcript = Transcript(entries: [])

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: FakeSessionProvider()
        )

        #expect(Array(result).isEmpty)
    }
}

// MARK: - Test Helpers

private extension DropOldestStrategyTests {

    /// Builds a `Transcript` with an instructions entry followed by prompt/response pairs.
    func makeTranscript(
        instructions: String,
        exchanges: [(String, String)]
    ) -> Transcript {
        let instructionsEntry = Transcript.Entry.instructions(
            Transcript.Instructions(
                segments: [.text(Transcript.TextSegment(content: instructions))],
                toolDefinitions: []
            )
        )

        var entries: [Transcript.Entry] = [instructionsEntry]
        for (prompt, response) in exchanges {
            entries.append(
                .prompt(
                    Transcript.Prompt(
                        segments: [.text(Transcript.TextSegment(content: prompt))],
                        options: GenerationOptions()
                    )
                )
            )
            entries.append(
                .response(
                    Transcript.Response(
                        assetIDs: [],
                        segments: [.text(Transcript.TextSegment(content: response))]
                    )
                )
            )
        }

        return Transcript(entries: entries)
    }

    func extractText(from response: Transcript.Response) -> String {
        response.segments.compactMap { segment in
            if case .text(let textSegment) = segment {
                return textSegment.content
            }
            return nil
        }.joined()
    }
}

// MARK: - Fake

/// Minimal `SessionProvider` that can be passed to strategies that don't use it.
private struct FakeSessionProvider: SessionProvider {
    func makeSession(model: SystemLanguageModel, instructions: String) -> AIModelSession {
        fatalError("Not expected to be called")
    }

    func makeSession(model: SystemLanguageModel, transcript: Transcript) -> AIModelSession {
        fatalError("Not expected to be called")
    }
}
