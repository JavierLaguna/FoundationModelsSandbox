import Foundation
import AppKit

// MARK: - Clipboard Interactor Protocol
protocol ClipboardInteractor: Sendable {
    func copy(_ text: String)
}

// MARK: - Default Implementation
struct ClipboardInteractorDefault: ClipboardInteractor {
    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}