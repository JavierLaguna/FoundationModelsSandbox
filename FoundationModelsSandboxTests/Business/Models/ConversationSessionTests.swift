import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct ConversationSessionTests {

    @Test
    func init_withDefaultValues_createsEmptySession() {
        let session = ConversationSession()

        #expect(session.id != UUID())
        #expect(session.messages.isEmpty)
        #expect(session.modelName == "")
        #expect(session.instructions == "")
    }

    @Test
    func init_withCustomValues_setsAllProperties() {
        let customModelName = "custom-model"
        let customInstructions = "You are a helpful assistant."

        let session = ConversationSession(
            modelName: customModelName,
            instructions: customInstructions
        )

        #expect(session.modelName == customModelName)
        #expect(session.instructions == customInstructions)
        #expect(session.messages.isEmpty)
    }

    @Test
    func addMessage_increasesMessageCount() {
        var session = ConversationSession()
        let response = AIResponse(
            content: "Hello!",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        session.addMessage(prompt: "Hi", outcome: .success(response))

        #expect(session.messageCount == 1)
    }

    @Test
    func addMessage_storesCorrectPromptAndResponse() {
        var session = ConversationSession()
        let response = AIResponse(
            content: "Response content",
            duration: 2.5,
            promptTokenCount: 8,
            responseTokenCount: 15,
            contextSize: 128_000
        )

        session.addMessage(prompt: "Test prompt", outcome: .success(response))

        #expect(session.messages.count == 1)
        #expect(session.messages[0].prompt == "Test prompt")
        #expect(session.messages[0].outcome.content == "Response content")

        if case .success(let storedResponse) = session.messages[0].outcome {
            #expect(storedResponse.duration == 2.5)
        }
    }

    @Test
    func addMessage_withError_storesFailure() {
        var session = ConversationSession()

        session.addMessage(prompt: "Test prompt", outcome: .failure("Network error"))

        #expect(session.messages.count == 1)
        #expect(session.messages[0].prompt == "Test prompt")

        if case .failure(let errorMessage) = session.messages[0].outcome {
            #expect(errorMessage == "Network error")
        }
    }

    @Test
    func addMessage_withNoResponse_storesNoResponse() {
        var session = ConversationSession()

        session.addMessage(prompt: "Test prompt", outcome: .noResponse)

        #expect(session.messages.count == 1)
        #expect(session.messages[0].prompt == "Test prompt")

        if case .noResponse = session.messages[0].outcome {
            // Expected
        }
    }

    @Test
    func addMessage_multipleMessages_storesAll() {
        var session = ConversationSession()
        let response1 = AIResponse(content: "Response 1", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)
        let response2 = AIResponse(content: "Response 2", duration: 2.0, promptTokenCount: 10, responseTokenCount: 20, contextSize: nil)

        session.addMessage(prompt: "Prompt 1", outcome: .success(response1))
        session.addMessage(prompt: "Prompt 2", outcome: .success(response2))

        #expect(session.messageCount == 2)
        #expect(session.messages[0].prompt == "Prompt 1")
        #expect(session.messages[1].prompt == "Prompt 2")
    }

    @Test
    func latestResponse_returnsLastMessageOutcome() {
        var session = ConversationSession()
        let response1 = AIResponse(content: "First", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)
        let response2 = AIResponse(content: "Last", duration: 2.0, promptTokenCount: 10, responseTokenCount: 20, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response1))
        session.addMessage(prompt: "P2", outcome: .success(response2))

        let latest = session.latestResponse
        #expect(latest != nil)

        if case .success(let response) = latest {
            #expect(response.content == "Last")
        }
    }

    @Test
    func latestResponse_withEmptySession_returnsNil() {
        let session = ConversationSession()

        #expect(session.latestResponse == nil)
    }

    @Test
    func latestResponse_withError_returnsFailure() {
        var session = ConversationSession()
        let response = AIResponse(content: "First", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))
        session.addMessage(prompt: "P2", outcome: .failure("Error occurred"))

        let latest = session.latestResponse
        #expect(latest != nil)

        if case .failure(let errorMessage) = latest {
            #expect(errorMessage == "Error occurred")
        }
    }

    @Test
    func messageEntry_hasUniqueId() {
        var session = ConversationSession()
        let response = AIResponse(content: "Test", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))
        session.addMessage(prompt: "P2", outcome: .success(response))

        #expect(session.messages[0].id != session.messages[1].id)
    }

    @Test
    func addMessage_returnsMessageId() {
        var session = ConversationSession()
        let response = AIResponse(content: "Test", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        let id = session.addMessage(prompt: "P1", outcome: .success(response))

        #expect(session.messages[0].id == id)
    }

    @Test
    func updateMessage_updatesExistingMessage() {
        var session = ConversationSession()
        let id = session.addMessage(prompt: "P1", outcome: .noResponse)

        session.updateMessage(id: id, outcome: .success(AIResponse(content: "Updated", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)))

        #expect(session.messages[0].outcome.content == "Updated")
    }

    @Test
    func updateMessage_withInvalidId_doesNotModifyMessages() {
        var session = ConversationSession()
        let response = AIResponse(content: "Original", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)
        session.addMessage(prompt: "P1", outcome: .success(response))

        session.updateMessage(id: UUID(), outcome: .noResponse)

        if case .success(let storedResponse) = session.messages[0].outcome {
            #expect(storedResponse.content == "Original")
        }
    }

    // MARK: - Display Helpers

    @Test
    func responseCount_withNoMessages_returnsZero() {
        let session = ConversationSession()

        #expect(session.responseCount == 0)
    }

    @Test
    func responseCount_withMixedOutcomes_returnsCorrectCount() {
        var session = ConversationSession()
        let response = AIResponse(content: "OK", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))
        session.addMessage(prompt: "P2", outcome: .failure("error"))
        session.addMessage(prompt: "P3", outcome: .noResponse)

        #expect(session.responseCount == 1)
    }

    @Test
    func responseCount_withMultipleSuccesses_returnsCorrectCount() {
        var session = ConversationSession()
        let response = AIResponse(content: "OK", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))
        session.addMessage(prompt: "P2", outcome: .success(response))

        #expect(session.responseCount == 2)
    }

    @Test
    func firstPrompt_withMessages_returnsFirst() {
        var session = ConversationSession()
        let response = AIResponse(content: "R1", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "First", outcome: .success(response))
        session.addMessage(prompt: "Second", outcome: .success(response))

        #expect(session.firstPrompt == "First")
    }

    @Test
    func firstPrompt_withEmptySession_returnsNil() {
        let session = ConversationSession()

        #expect(session.firstPrompt == nil)
    }

    @Test
    func lastPrompt_withMessages_returnsLast() {
        var session = ConversationSession()
        let response = AIResponse(content: "R1", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "First", outcome: .success(response))
        session.addMessage(prompt: "Last", outcome: .success(response))

        #expect(session.lastPrompt == "Last")
    }

    @Test
    func lastPrompt_withEmptySession_returnsNil() {
        let session = ConversationSession()

        #expect(session.lastPrompt == nil)
    }

    @Test
    func lastResponseContent_withSuccess_returnsContent() {
        var session = ConversationSession()
        let response = AIResponse(content: "Final answer", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))

        #expect(session.lastResponseContent == "Final answer")
    }

    @Test
    func lastResponseContent_withFailure_returnsNil() {
        var session = ConversationSession()

        session.addMessage(prompt: "P1", outcome: .failure("error"))

        #expect(session.lastResponseContent == nil)
    }

    @Test
    func lastResponseContent_withNoResponse_returnsNil() {
        var session = ConversationSession()

        session.addMessage(prompt: "P1", outcome: .noResponse)

        #expect(session.lastResponseContent == nil)
    }

    @Test
    func lastResponseContent_withEmptySession_returnsNil() {
        let session = ConversationSession()

        #expect(session.lastResponseContent == nil)
    }

    @Test
    func hasResponses_withSuccess_returnsTrue() {
        var session = ConversationSession()
        let response = AIResponse(content: "OK", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))

        #expect(session.hasResponses == true)
    }

    @Test
    func hasResponses_withOnlyFailures_returnsFalse() {
        var session = ConversationSession()

        session.addMessage(prompt: "P1", outcome: .failure("error"))

        #expect(session.hasResponses == false)
    }

    @Test
    func hasResponses_withEmptySession_returnsFalse() {
        let session = ConversationSession()

        #expect(session.hasResponses == false)
    }

    @Test
    func lastResponsePreview_truncatesLongContent() {
        var session = ConversationSession()
        let longContent = String(repeating: "word ", count: 200)
        let response = AIResponse(content: longContent, duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))

        let preview = session.lastResponsePreview
        #expect(preview != nil)
        #expect(preview!.count <= 503)  // 500 + "..."
        #expect(preview!.hasSuffix("..."))
    }

    @Test
    func lastResponsePreview_withShortContent_returnsFull() {
        var session = ConversationSession()
        let response = AIResponse(content: "Short answer.", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))

        #expect(session.lastResponsePreview == "Short answer.")
    }

    @Test
    func lastResponsePreview_withNewlines_preservesLineBreaks() {
        var session = ConversationSession()
        let response = AIResponse(content: "Line1\nLine2\nLine3", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil)

        session.addMessage(prompt: "P1", outcome: .success(response))

        #expect(session.lastResponsePreview == "Line1\nLine2\nLine3")
    }

    @Test
    func lastResponsePreview_withFailure_returnsNil() {
        var session = ConversationSession()

        session.addMessage(prompt: "P1", outcome: .failure("error"))

        #expect(session.lastResponsePreview == nil)
    }
}