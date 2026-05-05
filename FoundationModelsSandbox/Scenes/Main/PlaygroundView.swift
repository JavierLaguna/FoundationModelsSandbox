import FoundationModels
import SwiftUI

// MARK: - Playground View
struct PlaygroundView: View {
    
    @State private var viewModel = PlaygroundViewModel()
    
    @ViewBuilder
    private var detailView: some View {
        if viewModel.isFoundationModelsAvailable {
            AIResponseView(
                response: viewModel.aiResponse,
                code: viewModel.aiCode,
                footer: viewModel.error ?? "Enter a prompt to generate an AI response.",
                isLoading: viewModel.isLoading
            )
            
        } else {
            FoundationModelsNotAvailableView(
                availabilityReason: viewModel.availabilityReason
            )
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $viewModel.selectedSection)
        } content: {
            PromptPanelView(
                instructions: $viewModel.instructions,
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
            detailView
                .frame(minWidth: 380)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    PlaygroundView()
        .frame(width: 1200, height: 800)
}