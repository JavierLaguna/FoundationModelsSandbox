import Testing
@testable import FoundationModelsSandbox

@MainActor
struct ClipboardInteractorTests {

    // MARK: - Copy

    @Test
    func copy_clearsPasteboard() {
        let mockPasteboard = MockPasteboard()
        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)

        interactor.copy("test")

        #expect(mockPasteboard.cleared)
    }

    @Test
    func copy_setsStringToPasteboard() {
        let mockPasteboard = MockPasteboard()
        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)

        interactor.copy("Hello World")

        #expect(mockPasteboard.storedString == "Hello World")
    }

    @Test
    func copy_withEmptyString_setsEmptyString() {
        let mockPasteboard = MockPasteboard()
        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)

        interactor.copy("")

        #expect(mockPasteboard.storedString == "")
    }

    @Test
    func copy_withMultilineString_setsMultilineString() {
        let mockPasteboard = MockPasteboard()
        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)

        let multiline = "Line 1\nLine 2\nLine 3"
        interactor.copy(multiline)

        #expect(mockPasteboard.storedString == multiline)
    }

    @Test
    func copy_overwritesPreviousContent() {
        let mockPasteboard = MockPasteboard()
        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)

        interactor.copy("First")
        interactor.copy("Second")

        #expect(mockPasteboard.storedString == "Second")
    }
}