import SwiftUI

struct SidebarView: View {
    @Binding var selectedSection: String

    let navItems: [(icon: String, label: String)] = [
        ("wand.and.stars", "Playground"),
        ("clock.arrow.circlepath", "History"),
        ("cpu", "Models"),
        ("key", "API Keys"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.nexusAccent)
                        .frame(width: 34, height: 34)
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Nexus AI")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.nexusAccent)
                    Text("DEVELOPER WORKSPACE")
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(Color.nexusTextSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)

            // New Chat Button
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text("New Chat")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.nexusAccent)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            // Nav Items
            VStack(spacing: 2) {
                ForEach(navItems, id: \.label) { item in
                    SidebarNavItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: selectedSection == item.label
                    ) {
                        selectedSection = item.label
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            Divider().background(Color.nexusBorder).padding(.horizontal, 16)

            // Settings + User
            SidebarNavItem(icon: "gearshape", label: "Settings", isSelected: false) {}
                .padding(.horizontal, 8)

            HStack(spacing: 10) {
                Circle()
                    .fill(Color.nexusAccent.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("D")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.nexusAccent)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text("dev_alpha_01")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.nexusText)
                    Text("Pro Plan")
                        .font(.system(size: 10))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.nexusSidebar)
    }
}

struct SidebarNavItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? Color.nexusAccent : Color.nexusTextSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.nexusText : Color.nexusTextSecondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected ? Color.nexusSidebarSelected : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SidebarView(selectedSection: .constant("Playground"))
        .frame(width: 250, height: 600)
}