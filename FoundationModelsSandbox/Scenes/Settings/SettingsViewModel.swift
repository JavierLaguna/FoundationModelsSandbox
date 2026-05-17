import Foundation
import FoundationModels
import SwiftUI

/// ViewModel for the Settings scene.
/// Manages language selection which is persisted via @AppStorage.
@Observable
@MainActor
final class SettingsViewModel: Sendable {

    private let languageInteractor: any AppLanguageInteractor
    private let modelInteractor: any DefaultModelInteractor

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

    let availableLanguages: [AppLanguage]
    let availableModels: [SystemLanguageModel]

    /// App version from Info.plist
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    init(
        languageInteractor: any AppLanguageInteractor = AppLanguageInteractorDefault(),
        modelInteractor: any DefaultModelInteractor = DefaultModelInteractorDefault()
    ) {
        self.languageInteractor = languageInteractor
        self.modelInteractor = modelInteractor
        self.selectedLanguage = languageInteractor.getCurrentLanguage()
        self.availableLanguages = languageInteractor.getAvailableLanguages()
        self.selectedModelName = modelInteractor.getDefaultModelName()
        self.availableModels = modelInteractor.getAvailableModels()
    }
}
