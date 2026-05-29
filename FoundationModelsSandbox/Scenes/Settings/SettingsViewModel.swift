import Foundation
import FoundationModels
import SwiftUI

/// ViewModel for the Settings scene.
/// Manages language selection which is persisted via @AppStorage.
@Observable
@MainActor
final class SettingsViewModel {

    private let languageInteractor: any AppLanguageInteractor
    private let modelInteractor: any DefaultModelInteractor
    private let truncationStrategyInteractor: any DefaultTruncationStrategyInteractor
    private let modelsLister: any ListAvailableModelsInteractor
    private let userDefaults: UserDefaults

    var selectedLanguage: AppLanguage {
        didSet {
            languageInteractor.setLanguage(selectedLanguage)
        }
    }

    var selectedModelName: String {
        didSet {
            modelInteractor.setDefaultModelName(selectedModelName)
        }
    }

    var selectedTheme: AppTheme {
        didSet {
            userDefaults.set(selectedTheme.rawValue, forKey: UserDefaultsKeys.appThemePreference)
        }
    }

    var selectedTruncationStrategy: ContextTruncationStrategy {
        didSet {
            truncationStrategyInteractor.setDefaultTruncationStrategy(selectedTruncationStrategy)
        }
    }

    let availableLanguages: [AppLanguage]
    let availableThemes: [AppTheme] = AppTheme.allCases
    let availableModels: [SystemLanguageModel]
    let availableModelNames: [String]

    /// App version from Info.plist
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    init(
        languageInteractor: any AppLanguageInteractor = AppLanguageInteractorDefault(),
        modelInteractor: any DefaultModelInteractor = DefaultModelInteractorDefault(),
        truncationStrategyInteractor: any DefaultTruncationStrategyInteractor = DefaultTruncationStrategyInteractorDefault(),
        modelsLister: any ListAvailableModelsInteractor = ListAvailableModelsInteractorDefault(),
        userDefaults: UserDefaults = .standard
    ) {
        self.languageInteractor = languageInteractor
        self.modelInteractor = modelInteractor
        self.truncationStrategyInteractor = truncationStrategyInteractor
        self.modelsLister = modelsLister
        self.userDefaults = userDefaults
        self.selectedLanguage = languageInteractor.getCurrentLanguage()
        self.availableLanguages = languageInteractor.getAvailableLanguages()
        self.selectedModelName = modelInteractor.getDefaultModelName()
        let storedTheme = userDefaults.string(forKey: UserDefaultsKeys.appThemePreference)
            ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: storedTheme) ?? .system
        self.selectedTruncationStrategy = truncationStrategyInteractor.getDefaultTruncationStrategy()
        let models = modelsLister.execute()
        self.availableModels = models
        self.availableModelNames = models.isEmpty ? [] : ["default"]
    }
}
