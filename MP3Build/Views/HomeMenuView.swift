import SwiftUI

struct HomeMenuView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(navigation.homeEntries.enumerated()), id: \.offset) { index, entry in
                    FocusRow(
                        title: entry.title,
                        isSelected: index == navigation.selectedHomeIndex
                    )
                }
            }

            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(.black.opacity(0.38))
                    .frame(width: 88, height: 88)
                Circle()
                    .stroke(theme.focus.opacity(0.72), lineWidth: 5)
                    .frame(width: 66, height: 66)
                Text("MP4")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.focus)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FocusRow: View {
    @Environment(\.playerTheme) private var theme
    var title: String
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 7) {
            Text(title)
                .font(.system(size: isSelected ? 26 : 23, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            if isSelected {
                Text(">")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
            }
        }
        .foregroundColor(isSelected ? theme.focus : theme.primaryText)
        .padding(.horizontal, isSelected ? 8 : 0)
        .padding(.vertical, isSelected ? 1 : 0)
        .overlay(alignment: .leading) {
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(theme.focus, lineWidth: 2)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }
}
