import Foundation
import AppKit
import Mockable

// MARK: - Clipboard Interactor Protocol
@Mockable
protocol ClipboardInteractor: Sendable {
    func copy(_ text: String)
}

// MARK: - Pasteboard Protocol (for testability)
@Mockable
protocol PasteboardProtocol {
    @discardableResult
    func clearContents() -> Int
    @discardableResult
    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool
}

// MARK: - NSPasteboard Conformance
extension NSPasteboard: PasteboardProtocol {}

// MARK: - Default Implementation
struct ClipboardInteractorDefault: ClipboardInteractor {

    private let pasteboard: any PasteboardProtocol

    init(pasteboard: any PasteboardProtocol = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }

    func copy(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
