import SwiftUI

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    @State private var selectedSection: NavigationRoute = .playground
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            selectedSection.destination
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}
