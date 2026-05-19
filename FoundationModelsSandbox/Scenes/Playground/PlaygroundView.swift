import FoundationModels
import SwiftUI

// MARK: - Playground View
struct PlaygroundView: View {
    
    @State private var viewModel: PlaygroundViewModel
    
    init(viewModel: PlaygroundViewModel = PlaygroundViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    @ViewBuilder
    private var detailView: some View {
        if viewModel.isFoundationModelsAvailable {
            AIResponseView(
                response: viewModel.responseContent,
                code: viewModel.responseCode,
                metrics: viewModel.aiResponse,
                error: viewModel.error,
                isLoading: viewModel.isLoading,
                isCopied: viewModel.isCopied,
                onCopy: { viewModel.copyResponseToClipboard() }
            )
            
        } else {
            FoundationModelsNotAvailableView(
                availabilityReason: viewModel.availabilityReason
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    PlaygroundView()
        .frame(width: 1200, height: 800)
}
