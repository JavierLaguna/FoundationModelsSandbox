import Foundation
@testable import FoundationModelsSandbox

final class MockDefaultModelInteractor: DefaultModelInteractor, @unchecked Sendable {

    var getDefaultModelNameResult: String = "default"
    var setDefaultModelNameCalls: [String] = []

    func getDefaultModelName() -> String {
        getDefaultModelNameResult
    }

    func setDefaultModelName(_ name: String) {
        setDefaultModelNameCalls.append(name)
    }
}