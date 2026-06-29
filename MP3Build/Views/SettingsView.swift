import SwiftUI

struct SettingsView: View {
    @Environment(\.playerTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Theme")
                .font(theme.screenFont(size: 22, weight: .bold))
                .foregroundColor(theme.primaryText)
            Text(theme.name)
                .font(theme.screenFont(size: 18, weight: .bold))
                .foregroundColor(theme.focus)
            Text("Local files only")
                .font(theme.screenFont(size: 16, weight: .bold))
                .foregroundColor(theme.secondaryText)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .black, radius: 1, x: 1, y: 1)
    }
}
