import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct SummarizeStrategyTests {

    private let sut = SummarizeStrategy()
    private let anyModel = SystemLanguageModel.default

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: - Happy path

    @Test
    func truncate_withMultipleExchanges_summarizesOldestHalf() async throws {
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [
                ("Hello", "Hi there!"),
                ("How are you?", "I'm great!"),
                ("What is Swift?", "A language."),
                ("Tell me more", "Sure thing!")
            ]
        )

        let summarySession = MockAIModelSession()
        given(summarySession).respond(to: .any, options: .any).willReturn(
            SessionResponse(
                content: "User greeted and asked about Swift. Assistant responded.",
                duration: 0.2,
                promptTokenCount: 20,
                responseTokenCount: 15
            )
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(summarySession)

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: mockProvider
        )

        let entries = Array(result)
        // instructions + 1 summary entry + 4 kept entries (last half of 8)
        #expect(entries.count == 6)

        // First entry is instructions
        if case .instructions = entries[0] { } else {
            Issue.record("Expected first entry to be instructions")
        }

        // Second entry is the summary response
        if case .response(let response) = entries[1] {
            let text = extractText(from: response)
            #expect(text == "User greeted and asked about Swift. Assistant responded.")
        } else {
            Issue.record("Expected second entry to be the summary response")
        }

        // Last entry is the most recent response
        if case .response(let response) = entries[entries.count - 1] {
            let text = extractText(from: response)
            #expect(text == "Sure thing!")
        } else {
            Issue.record("Expected last entry to be the most recent response")
        }

        // Verify the summary session was used
        verify(summarySession).respond(to: .any, options: .any).called(.once)
    }

    // MARK: - Edge cases

    @Test
    func truncate_withOnlyInstructions_returnsJustInstructions() async throws {
        let transcript = makeTranscript(instructions: "Be helpful.", exchanges: [])

        let mockProvider = MockSessionProvider()

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: mockProvider
        )

        let entries = Array(result)
        #expect(entries.count == 1)

        if case .instructions = entries[0] { } else {
            Issue.record("Expected entry to be instructions")
        }

        // No session should be created when there's nothing to summarize
        verify(mockProvider).makeSession(model: .any, instructions: .any).called(.never)
    }

    @Test
    func truncate_withSingleExchange_summarizesPromptKeepsResponse() async throws {
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [("Hi there", "Hello!")]
        )

        let summarySession = MockAIModelSession()
        given(summarySession).respond(to: .any, options: .any).willReturn(
            SessionResponse(
                content: "User greeted.",
                duration: 0.1,
                promptTokenCount: 5,
                responseTokenCount: 3
            )
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(summarySession)

        let result = try await sut.truncateTranscript(
            transcript,
            model: anyModel,
            sessionProvider: mockProvider
        )

        let entries = Array(result)
        // instructions + 1 summary entry + 1 kept entry (the response from the single exchange)
        #expect(entries.count == 3)

        // The kept entry should be the response
        if case .response(let response) = entries[2] {
            let text = extractText(from: response)
            #expect(text == "Hello!")
        } else {
            Issue.record("Expected third entry to be the response")
        }
    }

    @Test
    func truncate_whenSummarizationFails_throwsError() async throws {
        let transcript = makeTranscript(
            instructions: "Be helpful.",
            exchanges: [("Question", "Answer")]
        )

        let summarySession = MockAIModelSession()
        given(summarySession).respond(to: .any, options: .any).willThrow(
            LanguageModelSession.GenerationError.rateLimited(
                LanguageModelSession.GenerationError.Context(debugDescription: "Rate limited")
            )
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(summarySession)

        await #expect(throws: LanguageModelSession.GenerationError.self) {
            try await sut.truncateTranscript(
                transcript,
                model: anyModel,
                sessionProvider: mockProvider
            )
        }
    }
}

// MARK: - Test Helpers

private extension SummarizeStrategyTests {

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
