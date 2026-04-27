import SwiftUI

// MARK: - Main View (Apple HIG compliant with NavigationSplitView)
struct MainView: View {
    @State private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $viewModel.selectedSection)
        } content: {
            PromptPanelView(
                systemPrompt: $viewModel.systemPrompt,
                userPrompt: $viewModel.userPrompt,
                selectedModel: $viewModel.selectedModel,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.submitPrompt()
                    }
                }
            )
            .frame(minWidth: 380)
        } detail: {
            AIResponseView(
                response: viewModel.aiResponse,
                code: viewModel.aiCode,
                footer: viewModel.error ?? "Enter a prompt to generate an AI response.",
                isLoading: viewModel.isLoading
            )
            .frame(minWidth: 380)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}