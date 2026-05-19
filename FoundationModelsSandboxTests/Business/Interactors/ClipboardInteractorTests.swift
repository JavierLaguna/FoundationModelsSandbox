import Testing
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct ClipboardInteractorTests {

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: - Copy

    @Test
    func copy_clearsPasteboard() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        interactor.copy("test")

        verify(mockPasteboard).clearContents().called(.once)
    }

    @Test
    func copy_setsStringToPasteboard() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        interactor.copy("Hello World")

        verify(mockPasteboard).setString(.value("Hello World"), forType: .any).called(.once)
    }

    @Test
    func copy_withEmptyString_setsEmptyString() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        interactor.copy("")

        verify(mockPasteboard).setString(.value(""), forType: .any).called(.once)
    }

    @Test
    func copy_withMultilineString_setsMultilineString() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        let multiline = "Line 1\nLine 2\nLine 3"
        interactor.copy(multiline)

        verify(mockPasteboard).setString(.value(multiline), forType: .any).called(.once)
    }

    @Test
    func copy_overwritesPreviousContent() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        interactor.copy("First")
        interactor.copy("Second")

        verify(mockPasteboard).setString(.value("First"), forType: .any).called(.once)
        verify(mockPasteboard).setString(.value("Second"), forType: .any).called(.once)
    }

    @Test
    func copy_clearsBeforeSettingString() {
        let mockPasteboard = MockPasteboardProtocol()
        given(mockPasteboard).clearContents().willReturn(1)
        given(mockPasteboard).setString(.any, forType: .any).willReturn(true)

        var callOrder: [String] = []
        when(mockPasteboard).clearContents().perform {
            callOrder.append("clearContents")
        }
        when(mockPasteboard).setString(.any, forType: .any).perform {
            callOrder.append("setString")
        }

        let interactor = ClipboardInteractorDefault(pasteboard: mockPasteboard)
        interactor.copy("test")

        #expect(callOrder == ["clearContents", "setString"])
    }
}
