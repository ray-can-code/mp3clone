import SwiftUI

struct SettingsView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Theme")
                .font(theme.screenFont(size: 22, weight: .bold))
                .foregroundColor(theme.primaryText)
            Text(theme.name)
                .font(theme.screenFont(size: 18, weight: .bold))
                .foregroundColor(theme.focus)

            stat("Music", library.audioItems.count)
            stat("Videos", library.videoItems.count)
            stat("Photos", library.photoItems.count)
            stat("Favs", library.favoriteItemIDs.count)
            stat("Lists", library.playlists.count)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .black, radius: 1, x: 1, y: 1)
    }

    private func stat(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
        }
        .font(theme.screenFont(size: 14, weight: .bold))
        .foregroundColor(theme.secondaryText)
    }
}
