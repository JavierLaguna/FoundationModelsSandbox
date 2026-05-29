import Foundation
import Mockable

/// Handles default truncation strategy preference persistence.
@Mockable
protocol DefaultTruncationStrategyInteractor: Sendable {
    func getDefaultTruncationStrategy() -> ContextTruncationStrategy
    func setDefaultTruncationStrategy(_ strategy: ContextTruncationStrategy)
}

final class DefaultTruncationStrategyInteractorDefault: DefaultTruncationStrategyInteractor {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getDefaultTruncationStrategy() -> ContextTruncationStrategy {
        guard let rawValue = userDefaults.string(forKey: UserDefaultsKeys.defaultTruncationStrategyPreference),
              let strategy = ContextTruncationStrategy(rawValue: rawValue) else {
            return .dropOldest
        }
        return strategy
    }

    func setDefaultTruncationStrategy(_ strategy: ContextTruncationStrategy) {
        userDefaults.set(strategy.rawValue, forKey: UserDefaultsKeys.defaultTruncationStrategyPreference)
    }
}
