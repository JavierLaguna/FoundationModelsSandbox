import Testing
import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

@MainActor
struct PlaygroundViewModelTests {

    // MARK: - Phase 1: Computed Properties

    // MARK: canSubmitPrompt

    @Test
    func canSubmitPrompt_emptyUserPrompt_returnsFalse() {
        let sut = Self.makeSUT()

        sut.userPrompt = ""
        sut.isLoading = false
        sut.selectedModelName = "default"

        #expect(sut.canSubmitPrompt == false)
    }

    @Test
    func canSubmitPrompt_whitespaceOnlyUserPrompt_returnsFalse() {
        let sut = Self.makeSUT()

        sut.userPrompt = "   "
        sut.isLoading = false
        sut.selectedModelName = "default"

        #expect(sut.canSubmitPrompt == false)
    }

    @Test
    func canSubmitPrompt_loading_returnsFalse() {
        let sut = Self.makeSUT()

        sut.userPrompt = "hello"
        sut.isLoading = true
        sut.selectedModelName = "default"

        #expect(sut.canSubmitPrompt == false)
    }

    @Test
    func canSubmitPrompt_emptyModelName_returnsFalse() {
        let sut = Self.makeSUT()

        sut.userPrompt = "hello"
        sut.isLoading = false
        sut.selectedModelName = ""

        #expect(sut.canSubmitPrompt == false)
    }

    @Test
    func canSubmitPrompt_allConditionsMet_returnsTrue() {
        let sut = Self.makeSUT()

        sut.userPrompt = "hello"
        sut.isLoading = false
        sut.selectedModelName = "default"

        #expect(sut.canSubmitPrompt == true)
    }

    // MARK: hasResponse

    @Test
    func hasResponse_nilResponse_returnsFalse() {
        let sut = Self.makeSUT()

        #expect(sut.hasResponse == false)
    }

    @Test
    func hasResponse_emptyContent_returnsFalse() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.emptyResponse

        #expect(sut.hasResponse == false)
    }

    @Test
    func hasResponse_nonEmptyContent_returnsTrue() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.successResponse

        #expect(sut.hasResponse == true)
    }

    // MARK: responseContent

    @Test
    func responseContent_nilResponse_returnsEmpty() {
        let sut = Self.makeSUT()

        #expect(sut.responseContent == "")
    }

    @Test
    func responseContent_withResponse_returnsContent() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.successResponse

        #expect(sut.responseContent == Self.successResponse.content)
    }

    // MARK: responseCode

    @Test
    func responseCode_nilResponse_returnsEmpty() {
        let sut = Self.makeSUT()

        #expect(sut.responseCode == "")
    }

    @Test
    func responseCode_withMarkdownCodeBlock_extractsCode() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.successResponse

        #expect(sut.responseCode == "let x = 1")
    }

    @Test
    func responseCode_noCodeBlock_returnsEmpty() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.plainTextResponse

        #expect(sut.responseCode == "")
    }

    @Test
    func responseCode_multipleCodeBlocks_extractsFirst() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.multiCodeBlockResponse

        #expect(sut.responseCode == "let a = 1")
    }

    @Test
    func responseCode_emptyContent_returnsEmpty() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.emptyResponse

        #expect(sut.responseCode == "")
    }

    // MARK: metricsFooter

    @Test
    func metricsFooter_nilResponse_returnsEmpty() {
        let sut = Self.makeSUT()

        #expect(sut.metricsFooter == "")
    }

    @Test
    func metricsFooter_withResponse_returnsFormattedString() {
        let sut = Self.makeSUT()

        sut.aiResponse = Self.successResponse

        #expect(sut.metricsFooter == "1.50s • 10 → 20 (30 total, 0.0% context)")
    }

    // MARK: - Phase 2: Initialization

    @Test
    func init_withAvailableModels_setsAvailableModelsAndNames() {
        let modelsLister = MockListAvailableModelsInteractor()
        modelsLister.executeResult = [Self.sampleModel]

        let defaultModelInteractor = MockDefaultModelInteractor()
        defaultModelInteractor.getDefaultModelNameResult = "default"

        let sut = PlaygroundViewModel(
            interactor: MockFoundationModelsInteractor(),
            availabilityChecker: MockCheckFoundationModelsAvailabilityInteractor(),
            modelsLister: modelsLister,
            clipboard: MockClipboardInteractor(),
            defaultModelInteractor: defaultModelInteractor
        )

        #expect(sut.availableModels.count == 1)
        #expect(sut.availableModelNames == ["default"])
    }

    @Test
    func init_withEmptyModelList_setsEmptyArrays() {
        let modelsLister = MockListAvailableModelsInteractor()
        modelsLister.executeResult = []

        let sut = PlaygroundViewModel(
            interactor: MockFoundationModelsInteractor(),
            availabilityChecker: MockCheckFoundationModelsAvailabilityInteractor(),
            modelsLister: modelsLister,
            clipboard: MockClipboardInteractor(),
            defaultModelInteractor: MockDefaultModelInteractor()
        )

        #expect(sut.availableModels.isEmpty)
        #expect(sut.availableModelNames.isEmpty)
    }

    @Test
    func init_withSavedDefaultModel_usesStoredPreference() {
        let modelsLister = MockListAvailableModelsInteractor()
        modelsLister.executeResult = [Self.sampleModel]

        let defaultModelInteractor = MockDefaultModelInteractor()
        defaultModelInteractor.getDefaultModelNameResult = "default"

        let sut = PlaygroundViewModel(
            interactor: MockFoundationModelsInteractor(),
            availabilityChecker: MockCheckFoundationModelsAvailabilityInteractor(),
            modelsLister: modelsLister,
            clipboard: MockClipboardInteractor(),
            defaultModelInteractor: defaultModelInteractor
        )

        #expect(sut.selectedModelName == "default")
    }

    @Test
    func init_withNoSavedPreference_fallsBackToFirstModel() {
        let modelsLister = MockListAvailableModelsInteractor()
        modelsLister.executeResult = [Self.sampleModel]

        let defaultModelInteractor = MockDefaultModelInteractor()
        defaultModelInteractor.getDefaultModelNameResult = ""

        let sut = PlaygroundViewModel(
            interactor: MockFoundationModelsInteractor(),
            availabilityChecker: MockCheckFoundationModelsAvailabilityInteractor(),
            modelsLister: modelsLister,
            clipboard: MockClipboardInteractor(),
            defaultModelInteractor: defaultModelInteractor
        )

        #expect(sut.selectedModelName == "default")
    }

    // MARK: - Phase 3: submitPrompt

    @Test
    func submitPrompt_success_setsResponseAndClearsPrompt() async {
        let mockInteractor = MockFoundationModelsInteractor()
        mockInteractor.executeResult = Self.successResponse

        let sut = Self.makeSUT(interactor: mockInteractor)

        sut.userPrompt = "test prompt"
        sut.selectedModelName = "default"

        await sut.submitPrompt()

        #expect(sut.aiResponse?.content == Self.successResponse.content)
        #expect(sut.userPrompt == "")
        #expect(sut.isLoading == false)
    }

    @Test
    func submitPrompt_error_setsErrorMessage() async {
        let mockInteractor = MockFoundationModelsInteractor()
        mockInteractor.executeError = AppleIntelligenceNotAvailableError.deviceNotEligible

        let sut = Self.makeSUT(interactor: mockInteractor)

        sut.userPrompt = "test prompt"
        sut.selectedModelName = "default"

        await sut.submitPrompt()

        #expect(sut.error != nil)
        #expect(sut.aiResponse == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func submitPrompt_emptyUserPrompt_doesNothing() async {
        let mockInteractor = MockFoundationModelsInteractor()
        mockInteractor.executeResult = Self.successResponse

        let sut = Self.makeSUT(interactor: mockInteractor)

        sut.userPrompt = ""
        sut.selectedModelName = "default"

        await sut.submitPrompt()

        #expect(sut.aiResponse == nil)
    }

    @Test
    func submitPrompt_alreadyLoading_doesNothing() async {
        let mockInteractor = MockFoundationModelsInteractor()
        mockInteractor.executeResult = Self.successResponse

        let sut = Self.makeSUT(interactor: mockInteractor)

        sut.userPrompt = "test prompt"
        sut.selectedModelName = "default"
        sut.isLoading = true

        await sut.submitPrompt()

        #expect(sut.aiResponse == nil)
    }

    // MARK: - Phase 4: Other Actions

    @Test
    func clearPrompts_resetsAllState() {
        let sut = Self.makeSUT()

        sut.instructions = "instructions"
        sut.userPrompt = "prompt"
        sut.aiResponse = Self.successResponse
        sut.error = "some error"

        sut.clearPrompts()

        #expect(sut.instructions == "")
        #expect(sut.userPrompt == "")
        #expect(sut.aiResponse == nil)
        #expect(sut.error == nil)
    }

    @Test
    func copyResponseToClipboard_emptyContent_doesNothing() {
        let mockClipboard = MockClipboardInteractor()

        let sut = Self.makeSUT(clipboard: mockClipboard)

        sut.aiResponse = nil

        sut.copyResponseToClipboard()

        #expect(mockClipboard.copiedText == nil)
    }

    @Test
    func copyResponseToClipboard_withContent_copiesAndSetsIsCopied() {
        let mockClipboard = MockClipboardInteractor()

        let sut = Self.makeSUT(clipboard: mockClipboard)

        sut.aiResponse = Self.successResponse

        sut.copyResponseToClipboard()

        #expect(mockClipboard.copiedText == Self.successResponse.content)
        #expect(sut.isCopied == true)
    }

    @Test
    func modelSelectionChanged_updatesModelAndRechecksAvailability() {
        let availabilityChecker = MockCheckFoundationModelsAvailabilityInteractor()
        availabilityChecker.executeResult = .unavailable(.deviceNotEligible)

        let modelsLister = MockListAvailableModelsInteractor()
        modelsLister.executeResult = [Self.sampleModel]

        let sut = PlaygroundViewModel(
            interactor: MockFoundationModelsInteractor(),
            availabilityChecker: availabilityChecker,
            modelsLister: modelsLister,
            clipboard: MockClipboardInteractor(),
            defaultModelInteractor: MockDefaultModelInteractor()
        )

        availabilityChecker.executeResult = .available

        sut.modelSelectionChanged(to: "default")

        #expect(sut.selectedModelName == "default")
        #expect(sut.selectedModel != nil)
    }

    // MARK: - Phase 5: extractCodeBlock (via responseCode)

    @Test
    func extractCodeBlock_markdownSwiftBlock_extractedCorrectly() {
        let sut = Self.makeSUT()

        sut.aiResponse = AIResponse(
            content: "Some text\n```swift\nlet x = 42\nlet y = 100\n```\nMore text",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        #expect(sut.responseCode == "let x = 42\nlet y = 100")
    }

    @Test
    func extractCodeBlock_noCodeBlock_returnsEmpty() {
        let sut = Self.makeSUT()

        sut.aiResponse = AIResponse(
            content: "Plain text without any code fences",
            duration: 0.5,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        #expect(sut.responseCode == "")
    }

    @Test
    func extractCodeBlock_emptyString_returnsEmpty() {
        let sut = Self.makeSUT()

        sut.aiResponse = AIResponse(
            content: "",
            duration: 0.1,
            promptTokenCount: 0,
            responseTokenCount: 0,
            contextSize: nil
        )

        #expect(sut.responseCode == "")
    }

    @Test
    func extractCodeBlock_multipleCodeBlocks_extractsFirst() {
        let sut = Self.makeSUT()

        sut.aiResponse = AIResponse(
            content: "```swift\nfirst block\n```\n```python\nsecond block\n```",
            duration: 2.0,
            promptTokenCount: 10,
            responseTokenCount: 20,
            contextSize: nil
        )

        #expect(sut.responseCode == "first block")
    }

    @Test
    func extractCodeBlock_codeBlockNoLanguage_extractedCorrectly() {
        let sut = Self.makeSUT()

        sut.aiResponse = AIResponse(
            content: "```\ncode without language\n```",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        #expect(sut.responseCode == "code without language")
    }

    // MARK: - Test Fixtures

    private static func makeSUT(
        interactor: FoundationModelsInteractor = MockFoundationModelsInteractor(),
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = MockCheckFoundationModelsAvailabilityInteractor(),
        modelsLister: ListAvailableModelsInteractor = MockListAvailableModelsInteractor(),
        clipboard: ClipboardInteractor = MockClipboardInteractor(),
        defaultModelInteractor: DefaultModelInteractor = MockDefaultModelInteractor()
    ) -> PlaygroundViewModel {
        PlaygroundViewModel(
            interactor: interactor,
            availabilityChecker: availabilityChecker,
            modelsLister: modelsLister,
            clipboard: clipboard,
            defaultModelInteractor: defaultModelInteractor
        )
    }

    private static var successResponse: AIResponse {
        AIResponse(
            content: "Here's code:\n```swift\nlet x = 1\n```",
            duration: 1.5,
            promptTokenCount: 10,
            responseTokenCount: 20,
            contextSize: 128_000
        )
    }

    private static var emptyResponse: AIResponse {
        AIResponse(
            content: "",
            duration: 0.5,
            promptTokenCount: 5,
            responseTokenCount: 5,
            contextSize: nil
        )
    }

    private static var plainTextResponse: AIResponse {
        AIResponse(
            content: "This is plain text without any code blocks.",
            duration: 0.8,
            promptTokenCount: 15,
            responseTokenCount: 25,
            contextSize: 128_000
        )
    }

    private static var multiCodeBlockResponse: AIResponse {
        AIResponse(
            content: "First block:\n```swift\nlet a = 1\n```\nSecond block:\n```python\nprint('hello')\n```",
            duration: 2.0,
            promptTokenCount: 20,
            responseTokenCount: 40,
            contextSize: 128_000
        )
    }

    private static var sampleModel: SystemLanguageModel {
        SystemLanguageModel.default
    }
}