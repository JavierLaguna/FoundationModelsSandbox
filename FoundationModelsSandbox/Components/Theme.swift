import SwiftUI

extension Color {
    static let nexusBackground = Color(hex: "#0D1117")
    static let nexusSidebar = Color(hex: "#0D1117")
    static let nexusSidebarSelected = Color(hex: "#1C2333")
    static let nexusPanel = Color(hex: "#161B27")
    static let nexusCard = Color(hex: "#1C2333")
    static let nexusBorder = Color(hex: "#2D3748")
    static let nexusAccent = Color(hex: "#6C63FF")
    static let nexusAccentLight = Color(hex: "#8B85FF")
    static let nexusText = Color(hex: "#E2E8F0")
    static let nexusTextSecondary = Color(hex: "#8892A4")
    static let nexusTextMuted = Color(hex: "#4A5568")
    static let nexusGreen = Color(hex: "#48BB78")
    static let nexusCodeBg = Color(hex: "#141820")
    static let nexusCodeKeyword = Color(hex: "#79C0FF")
    static let nexusCodeString = Color(hex: "#A5D6FF")
    static let nexusCodeNumber = Color(hex: "#FF9E64")
    static let nexusTagBg = Color(hex: "#1C2333")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

#Preview {
    Color.nexusBackground
        .frame(width: 100, height: 100)
}