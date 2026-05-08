import SwiftUI

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    @State private var selectedSection: String = "Playground"
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case "Playground":
            PlaygroundView()
        default:
            Text("Select a section from the sidebar")
                .foregroundStyle(.secondary)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}
