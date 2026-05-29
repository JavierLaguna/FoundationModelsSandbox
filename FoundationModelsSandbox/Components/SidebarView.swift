import SwiftUI

// MARK: - Native Sidebar (Apple HIG compliant)
struct SidebarView: View {
    
    @Binding var selectedSection: NavigationRoute
    var onNewChat: () -> Void
    var favoriteSessions: [ConversationSession] = []
    var onSelectFavorite: ((ConversationSession) -> Void)?
    
    var body: some View {
        List(selection: $selectedSection) {
            Section {
                ForEach(NavigationRoute.allCases, id: \.self) { route in
                    Label(route.label, systemImage: route.icon)
                        .tag(route)
                        .accessibilityIdentifier("sidebar-route-\(route.rawValue)")
                }
            } header: {
                Text("Sections")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !favoriteSessions.isEmpty {
                Section {
                    ForEach(favoriteSessions, id: \.id) { session in
                        Button {
                            onSelectFavorite?(session)
                        } label: {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(session.firstPrompt ?? String(localized: "Empty session"))
                                    .lineLimit(1)

                                Text(session.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("sidebar-favorite-\(session.id)")
                    }
                } header: {
                    Text("Favourites")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
                .accessibilityIdentifier("sidebar-new-chat")
            }
        }
        .navigationTitle("Nexus AI")
    }
}

#Preview {
    SidebarView(
        selectedSection: .constant(.playground),
        onNewChat: {},
        favoriteSessions: [
            ConversationSession(id: UUID(), modelName: "gpt-4"),
            ConversationSession(id: UUID(), modelName: "claude-3")
        ],
        onSelectFavorite: { _ in }
    )
    .frame(width: 280)
}
