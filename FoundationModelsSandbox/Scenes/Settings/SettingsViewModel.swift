import Foundation
import SwiftUI

/// ViewModel for the Settings scene.
/// Manages language selection which is persisted via @AppStorage.
@Observable
@MainActor
final class SettingsViewModel: Sendable {

    private let interactor: any AppLanguageInteractor

    var selectedLanguage: AppLanguage {
        didSet {
            interactor.setLanguage(selectedLanguage)
        }
    }

    let availableLanguages: [AppLanguage]

    /// App version from Info.plist
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    init(
        interactor: any AppLanguageInteractor = AppLanguageInteractorDefault()
    ) {
        self.interactor = interactor
        self.selectedLanguage = interactor.getCurrentLanguage()
        self.availableLanguages = interactor.getAvailableLanguages()
    }
}
