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

                Text("Choose the language for the app interface")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Divider()

                Picker("Default Model", selection: $viewModel.selectedModelName) {
                    ForEach(viewModel.availableModelNames, id: \.self) { name in
                        Text(name)
                            .tag(name)
                    }
                }
                .pickerStyle(.menu)

                Text("Model selected by default in Playground")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Section("About") {
                LabeledContent("Version", value: viewModel.appVersion)
                LabeledContent("Platform", value: "macOS")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView()
}