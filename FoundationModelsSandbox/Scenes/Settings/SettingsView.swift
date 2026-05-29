import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section("General") {
                Picker("Language", selection: $viewModel.selectedLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings-language-picker")

                Text("Choose the language for the app interface")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Divider()

                Picker("Theme", selection: $viewModel.selectedTheme) {
                    ForEach(viewModel.availableThemes, id: \.self) { theme in
                        Text(theme.displayName)
                            .tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings-theme-picker")

                Text("Choose the appearance for the app interface")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Section("Playground") {
                Picker("Default Model", selection: $viewModel.selectedModelName) {
                    ForEach(viewModel.availableModelNames, id: \.self) { name in
                        Text(name)
                            .tag(name)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings-default-model-picker")

                Text("Model selected by default in Playground")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Divider()

                Picker("Default truncation strategy", selection: $viewModel.selectedTruncationStrategy) {
                    ForEach(ContextTruncationStrategy.allCases, id: \.self) { strategy in
                        Text(strategy.displayName)
                            .tag(strategy)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings-truncation-strategy-picker")

                Text("Strategy used by default for new conversations")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            
            Section("About") {
                LabeledContent("Version", value: viewModel.appVersion)
                LabeledContent("Platform") {
                    Text("macOS")
                }
            }
        }
        .navigationTitle("Settings")
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView()
}
