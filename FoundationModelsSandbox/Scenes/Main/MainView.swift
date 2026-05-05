import SwiftUI

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    @State private var selectedSection: String = "Playground"
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case "Playground":
            PlaygroundContentView()
        default:
            Text("Select a section from the sidebar")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}
