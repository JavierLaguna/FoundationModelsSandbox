import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct FoundationModelsInteractorTests {

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: - startConversation — unavailable paths

    @Test
    func startConversation_whenDeviceNotEligible_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.deviceNotEligible))

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(MockAIModelSession())

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionProvider: mockProvider
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.deviceNotEligible) {
            try await sut.startConversation(
                model: SystemLanguageModel.default,
                instructions: "",
                truncationStrategy: .dropOldest
            )
        }

        #expect(sut.hasActiveConversation == false)
    }

    @Test
    func startConversation_whenAppleIntelligenceNotEnabled_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.appleIntelligenceNotEnabled))

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(MockAIModelSession())

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionProvider: mockProvider
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.appleIntelligenceNotEnabled) {
            try await sut.startConversation(
                model: SystemLanguageModel.default,
                instructions: "",
                truncationStrategy: .dropOldest
            )
        }
    }

    @Test
    func startConversation_whenModelNotReady_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.modelNotReady))

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(MockAIModelSession())

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionProvider: mockProvider
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.modelNotReady) {
            try await sut.startConversation(
                model: SystemLanguageModel.default,
                instructions: "",
                truncationStrategy: .dropOldest
            )
        }
    }

    // MARK: - startConversation — available path

    @Test
    func startConversation_whenAvailable_setsHasActiveConversation() async throws {
        let session = MockAIModelSession()
        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        #expect(sut.hasActiveConversation == false)

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "Be helpful",
            truncationStrategy: .dropOldest
        )

        #expect(sut.hasActiveConversation == true)
    }

    // MARK: - sendMessage — active conversation

    @Test
    func sendMessage_withActiveSession_returnsContent() async throws {
        let session = MockAIModelSession()
        let expectedResponse = SessionResponse(
            content: "Hello from AI!",
            duration: 0.5,
            promptTokenCount: 10,
            responseTokenCount: 20
        )
        given(session).respond(to: .any, options: .any).willReturn(expectedResponse)

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "",
            truncationStrategy: .dropOldest
        )

        let result = try await sut.sendMessage("Hi")

        #expect(result.content == "Hello from AI!")
        #expect(result.duration == 0.5)
        #expect(result.promptTokenCount == 10)
        #expect(result.responseTokenCount == 20)
        #expect(result.contextSize == 4096)
    }

    @Test
    func sendMessage_noActiveSession_throws() async {
        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker()
        )

        await #expect(throws: FoundationModelsInteractorError.noActiveConversation) {
            try await sut.sendMessage("Hi")
        }
    }

    @Test
    func sendMessage_usesSessionRespond() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "",
            truncationStrategy: .dropOldest
        )

        _ = try await sut.sendMessage("test prompt")

        verify(session).respond(to: .any, options: .any).called(.once)
    }

    @Test
    func sendMessage_reusesSameSessionAcrossCalls() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "",
            truncationStrategy: .dropOldest
        )

        _ = try await sut.sendMessage("first")
        _ = try await sut.sendMessage("second")

        // Same session should be used (not recreated), so respond is called twice
        verify(session).respond(to: .any, options: .any).called(.exactly(2))
    }

    // MARK: - endConversation

    @Test
    func endConversation_clearsActiveSession() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "",
            truncationStrategy: .dropOldest
        )

        #expect(sut.hasActiveConversation == true)

        sut.endConversation()

        #expect(sut.hasActiveConversation == false)
    }

    // MARK: - contextSize

    @Test
    func contextSize_returnsModelContextSize() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let mockProvider = MockSessionProvider()
        given(mockProvider).makeSession(model: .any, instructions: .any).willReturn(session)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionProvider: mockProvider
        )

        try await sut.startConversation(
            model: SystemLanguageModel.default,
            instructions: "",
            truncationStrategy: .dropOldest
        )

        #expect(sut.contextSize == 4096)
    }

    // MARK: - Test Fixtures

    private static func makeAvailableChecker() -> CheckFoundationModelsAvailabilityInteractor {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.available)
        return checker
    }
}
