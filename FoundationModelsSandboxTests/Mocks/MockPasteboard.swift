import AppKit
@testable import FoundationModelsSandbox

// MARK: - Mock Pasteboard
final class MockPasteboard: PasteboardProtocol {
    
    var cleared = false
    var storedString: String?
    var callHistory: [String] = []

    func clearContents() -> Int {
        cleared = true
        storedString = nil
        callHistory.append("clearContents")
        return 1
    }

    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool {
        storedString = string
        callHistory.append("setString")
        return true
    }
}
