import Foundation
@testable import FoundationModelsSandbox

final class MockClipboardInteractor: ClipboardInteractor, @unchecked Sendable {

    var copiedText: String?
    var callHistory: [String] = []

    func copy(_ text: String) {
        copiedText = text
        callHistory.append(text)
    }
}