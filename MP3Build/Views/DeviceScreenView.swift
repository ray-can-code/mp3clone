import AVFoundation
import SwiftUI

struct DeviceScreenView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            screenBackground

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(theme.screenFont(size: 20, weight: .bold))
                    Spacer()
                    if let batteryImageName = theme.batteryImageName {
                        Image(batteryImageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 27, height: 14)
                            .accessibilityHidden(true)
                    }
                    Text("100%")
                        .font(theme.screenFont(size: 15, weight: .bold))
                }
                .foregroundColor(theme.primaryText)
                .shadow(color: .black, radius: 1, x: 1, y: 1)

                screenBody
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(Color.black.opacity(0.72), lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.16), radius: 12, y: 6)
    }

    @ViewBuilder
    private var screenBackground: some View {
        ZStack {
            if let wallpaper = theme.screenWallpaperName {
                Image(wallpaper)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFill()
            } else {
                theme.screenBackground
            }

            theme.screenBackground.opacity(0.34)
            LinearGradient(
                colors: [.black.opacity(0.20), .clear, .black.opacity(0.36)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var title: String {
        switch navigation.currentScreen {
        case .home: return "Home"
        case .nowPlaying: return "Now Playing"
        case .music: return "Music"
        case .videos: return "Videos"
        case .audiobooks: return "Audiobooks"
        case .photos: return "Photos"
        case .fmRadio: return "FM Radio"
        case .bluetooth: return "Bluetooth"
        case .settings: return "Settings"
        }
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
        case .audiobooks:
            MediaListView(kind: .audio, mode: .audiobooks)
        case .photos:
            MediaListView(kind: .photo)
        case .fmRadio:
            DeviceStatusFeatureView(
                title: "FM Radio",
                lines: [
                    "No FM tuner in iPhone",
                    "Use imported MP3/MP4",
                    "Local playback only"
                ]
            )
        case .bluetooth:
            BluetoothFeatureView()
        case .settings:
            SettingsView()
        }
    }
}

private struct DeviceStatusFeatureView: View {
    @Environment(\.playerTheme) private var theme
    var title: String
    var lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Spacer()
            Text(title)
                .font(theme.screenFont(size: 23, weight: .bold))
                .foregroundColor(theme.primaryText)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(theme.screenFont(size: 14, weight: .bold))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .black, radius: 1, x: 1, y: 1)
    }
}

private struct BluetoothFeatureView: View {
    @Environment(\.playerTheme) private var theme
    @State private var routeName = "iPhone Speaker"

    var body: some View {
        DeviceStatusFeatureView(
            title: "Bluetooth",
            lines: [
                "Output: \(routeName)",
                "Pair in iOS Settings",
                "Wheel controls still work"
            ]
        )
        .onAppear {
            routeName = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "iPhone Speaker"
        }
    }
}
