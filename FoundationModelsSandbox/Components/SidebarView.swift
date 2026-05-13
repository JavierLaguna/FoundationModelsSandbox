import SwiftUI

// MARK: - Native Sidebar (Apple HIG compliant)
struct SidebarView: View {
    
    @Binding var selectedSection: String
    
    private let navItems: [(icon: String, label: String)] = [
        ("sparkles", "Playground"),
        ("clock.arrow.circlepath", "History"),
    ]
    
    var body: some View {
        List(selection: $selectedSection) {
            Section {
                ForEach(navItems, id: \.label) { item in
                    Label(item.label, systemImage: item.icon)
                        .tag(item.label)
                }
            } header: {
                Text("Navigation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Label("Settings", systemImage: "gearshape")
                    .tag("Settings")
            } header: {
                Text("System")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // New chat action
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
    SidebarView(selectedSection: .constant("Playground"))
        .frame(width: 280)
}
