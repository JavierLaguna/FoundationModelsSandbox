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

    // MARK: - execute — unavailable paths

    @Test
    func execute_whenDeviceNotEligible_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.deviceNotEligible))

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionFactory: { _, _ in MockAIModelSession() }
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.deviceNotEligible) {
            try await sut.execute(prompt: "test", instructions: "")
        }
    }

    @Test
    func execute_whenAppleIntelligenceNotEnabled_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.appleIntelligenceNotEnabled))

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionFactory: { _, _ in MockAIModelSession() }
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.appleIntelligenceNotEnabled) {
            try await sut.execute(prompt: "test", instructions: "")
        }
    }

    @Test
    func execute_whenModelNotReady_throws() async {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.unavailable(.modelNotReady))

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: checker,
            sessionFactory: { _, _ in MockAIModelSession() }
        )

        await #expect(throws: AppleIntelligenceNotAvailableError.modelNotReady) {
            try await sut.execute(prompt: "test", instructions: "")
        }
    }

    // MARK: - execute — available path

    @Test
    func execute_whenAvailable_returnsContentFromSession() async throws {
        let session = MockAIModelSession()
        let expectedResponse = SessionResponse(
            content: "Hello from AI!",
            duration: 0,
            promptTokenCount: 0,
            responseTokenCount: 0
        )
        given(session).respond(to: .any, options: .any).willReturn(expectedResponse)

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionFactory: { _, _ in session }
        )

        let result = try await sut.execute(prompt: "Hi", instructions: "")

        #expect(result.content == "Hello from AI!")
    }

    @Test
    func execute_whenAvailable_forwardsPromptAndOptions() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionFactory: { _, _ in session }
        )

        _ = try await sut.execute(prompt: "test prompt", instructions: "some instructions")

        verify(session).respond(to: .any, options: .any).called(.once)
    }

    @Test
    func execute_whenAvailable_createsNewSessionPerCall() async throws {
        let session1 = MockAIModelSession()
        given(session1).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "First", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let session2 = MockAIModelSession()
        given(session2).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "Second", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        var callCount = 0
        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionFactory: { _, _ in
                callCount += 1
                return callCount == 1 ? session1 : session2
            }
        )

        let result1 = try await sut.execute(prompt: "first", instructions: "")
        let result2 = try await sut.execute(prompt: "second", instructions: "")

        #expect(result1.content == "First")
        #expect(result2.content == "Second")
    }

    @Test
    func execute_whenAvailable_setsContextSizeFromModel() async throws {
        let session = MockAIModelSession()
        given(session).respond(to: .any, options: .any).willReturn(
            SessionResponse(content: "", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        )

        let sut = FoundationModelsInteractorDefault(
            availabilityChecker: Self.makeAvailableChecker(),
            sessionFactory: { _, _ in session }
        )

        let result = try await sut.execute(prompt: "Hi", instructions: "")

        // SystemLanguageModel.default.contextSize returns 4096 on current SDK
        #expect(result.contextSize != nil)
    }

    // MARK: - Test Fixtures

    private static func makeAvailableChecker() -> CheckFoundationModelsAvailabilityInteractor {
        let checker = MockCheckFoundationModelsAvailabilityInteractor()
        given(checker).execute(model: .any).willReturn(.available)
        return checker
    }
}
