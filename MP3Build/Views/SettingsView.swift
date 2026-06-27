import SwiftUI

struct SettingsView: View {
    @Environment(\.playerTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Theme")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(theme.primaryText)
            Text(theme.name)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.focus)
            Text("Local files only")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.secondaryText)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
