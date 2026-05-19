import SwiftUI

// MARK: - Native Sidebar (Apple HIG compliant)
struct SidebarView: View {
    
    @Binding var selectedSection: NavigationRoute
    var onNewChat: () -> Void
    
    var body: some View {
        List(selection: $selectedSection) {
            Section {
                ForEach(NavigationRoute.allCases, id: \.self) { route in
                    Label(route.label, systemImage: route.icon)
                        .tag(route)
                }
            } header: {
                Text("Sections")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onNewChat()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Nexus AI")
    }
}

#Preview {
    SidebarView(selectedSection: .constant(.playground), onNewChat: {})
        .frame(width: 280)
}
