import SwiftUI

struct HomeMenuView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel
    @State private var iconFloat = false

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(navigation.homeEntries.enumerated()), id: \.offset) { index, entry in
                    FocusRow(
                        title: entry.title,
                        isSelected: index == navigation.selectedHomeIndex,
                        isEnabled: entry.isEnabled
                    )
                }
            }
            .frame(width: 154, alignment: .leading)

            Spacer(minLength: 2)

            if let iconName = selectedIconName {
                Image.themeAsset(iconName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 112, height: 112)
                    .shadow(color: .black.opacity(0.45), radius: 5, y: 4)
                    .offset(y: iconFloat ? -5 : 5)
                    .rotationEffect(.degrees(iconFloat ? -2 : 2))
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    .id(iconName)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeOut(duration: 0.16), value: navigation.selectedHomeIndex)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                iconFloat.toggle()
            }
        }
    }

    private var selectedIconName: String? {
        guard navigation.homeEntries.indices.contains(navigation.selectedHomeIndex) else {
            return nil
        }

        return theme.homeIconName(for: navigation.homeEntries[navigation.selectedHomeIndex].screen)
    }
}

private struct FocusRow: View {
    @Environment(\.playerTheme) private var theme
    var title: String
    var isSelected: Bool
    var isEnabled: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(theme.screenFont(size: 16, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .shadow(color: isSelected ? .clear : .black, radius: 1, x: 1, y: 1)

            Spacer(minLength: 2)

            if isSelected {
                if let arrow = theme.selectedRowArrowImageName {
                    Image(arrow)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 9, height: 13)
                        .padding(.trailing, 5)
                } else {
                    Text(">")
                        .font(theme.screenFont(size: 17, weight: .bold))
                }
            }
        }
        .foregroundColor(rowColor)
        .frame(width: 150, height: 19, alignment: .leading)
        .padding(.horizontal, 2)
        .background {
            if isSelected, let selectedRowImage = theme.selectedRowImageName {
                Image(selectedRowImage)
                    .resizable(capInsets: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4), resizingMode: .stretch)
                    .interpolation(.none)
            } else if isSelected {
                Rectangle().fill(theme.focus)
            }
        }
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }

    private var rowColor: Color {
        if isSelected { return Color(red: 0.18, green: 0.18, blue: 0.18) }
        return isEnabled ? theme.primaryText : theme.primaryText.opacity(0.45)
    }
}
