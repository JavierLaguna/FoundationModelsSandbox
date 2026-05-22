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
        let id = session.addMessage(prompt: "P1", outcome: .success(response))

        session.updateMessage(id: UUID(), outcome: .noResponse)

        if case .success(let storedResponse) = session.messages[0].outcome {
            #expect(storedResponse.content == "Original")
        }
    }
}