import AppKit
@testable import FoundationModelsSandbox

// MARK: - Mock Pasteboard
final class MockPasteboard: PasteboardProtocol {
    var cleared = false
    var storedString: String?

    func clearContents() -> Int {
        cleared = true
        storedString = nil
        return 1
    }

    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool {
        storedString = string
        return true
    }
}