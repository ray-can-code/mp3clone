import AVKit
import SwiftUI

struct NowPlayingView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var playback: PlaybackController

    var body: some View {
        VStack(spacing: 8) {
            if let item = playback.currentItem {
                if item.kind == .video, let player = playback.player {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity)
                        .frame(height: 118)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.screenGloss.opacity(0.55))
                        VStack(spacing: 8) {
                            Circle()
                                .stroke(theme.focus, lineWidth: 6)
                                .frame(width: 58, height: 58)
                            Text("AUDIO")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(theme.focus)
                    }
                    .frame(height: 112)
                }

                Text(item.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                    .foregroundColor(theme.primaryText)
            } else {
                Spacer()
                Text("Nothing Playing")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.secondaryText)
                Text("Import local music or MP4")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.secondaryText)
                Spacer()
            }
        }
    }
}
