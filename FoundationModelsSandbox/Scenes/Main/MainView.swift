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
                isLoading: $viewModel.isLoading
            )
            .frame(minWidth: 380)
        } detail: {
            AIResponseView(
                response: viewModel.sampleResponse,
                code: viewModel.sampleCode,
                footer: viewModel.responseFooter,
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