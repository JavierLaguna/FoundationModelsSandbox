import FoundationModels
import SwiftUI

// MARK: - Playground Content View
struct PlaygroundContentView: View {
    
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
        HSplitView {
            PromptPanelView(
                instructions: $viewModel.instructions,
                userPrompt: $viewModel.userPrompt,
                selectedModelName: $viewModel.selectedModelName,
                availableModelNames: viewModel.availableModelNames,
                isLoading: viewModel.isLoading,
                onSubmit: {
                    Task {
                        await viewModel.submitPrompt()
                    }
                },
                onModelChanged: { modelName in
                    viewModel.modelSelectionChanged(to: modelName)
                }
            )
            .frame(minWidth: 380, maxHeight: .infinity)
            
            detailView
                .frame(minWidth: 380, maxHeight: .infinity)
        }
    }
}

#Preview {
    PlaygroundContentView()
        .frame(width: 1200, height: 800)
}