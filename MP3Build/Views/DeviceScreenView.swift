import SwiftUI

struct DeviceScreenView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.screenBackground)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(theme.screenGloss.opacity(0.72))
                        .frame(width: 196, height: 196)
                        .offset(x: 42, y: -92)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 120, style: .continuous)
                        .fill(theme.screenGloss.opacity(0.34))
                        .frame(width: 260, height: 90)
                        .rotationEffect(.degrees(-24))
                        .offset(x: -58, y: 28)
                }

            VStack(spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Text(statusText)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                }
                .foregroundColor(theme.primaryText)

                screenBody
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.50), lineWidth: 8)
        }
        .shadow(color: .black.opacity(0.16), radius: 12, y: 6)
    }

    private var title: String {
        switch navigation.currentScreen {
        case .home: return "Home"
        case .nowPlaying: return "Now Playing"
        case .music: return "Music"
        case .videos: return "Videos"
        case .settings: return "Settings"
        }
    }

    private var statusText: String {
        "II  AUDIO  BAT"
    }

    @ViewBuilder
    private var screenBody: some View {
        switch navigation.currentScreen {
        case .home:
            HomeMenuView()
        case .nowPlaying:
            NowPlayingView()
        case .music:
            MediaListView(kind: .audio)
        case .videos:
            MediaListView(kind: .video)
        case .settings:
            SettingsView()
        }
    }
}
