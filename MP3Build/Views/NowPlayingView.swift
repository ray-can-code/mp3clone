import AVKit
import SwiftUI
import UIKit

struct NowPlayingView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary
    @EnvironmentObject private var playback: PlaybackController

    @State private var expandedVideo = false
    @State private var showingFullScreenVideo = false

    var body: some View {
        VStack(spacing: 7) {
            if let item = playback.currentItem {
                mediaPreview(for: item)

                Text(item.title)
                    .font(theme.screenFont(size: 16, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                    .foregroundColor(theme.primaryText)

                if let artist = item.artist, !artist.isEmpty {
                    Text(artist)
                        .font(theme.screenFont(size: 12))
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                        .foregroundColor(theme.secondaryText)
                }

                progressControls(for: item)
            } else {
                Spacer()
                Text("Nothing Playing")
                    .font(theme.screenFont(size: 20, weight: .bold))
                    .foregroundColor(theme.secondaryText)
                Text("Import local music or MP4")
                    .font(theme.screenFont(size: 13))
                    .foregroundColor(theme.secondaryText)
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingFullScreenVideo) {
            if let player = playback.player {
                FullScreenVideoPlayer(player: player)
            }
        }
        .onDisappear {
            saveResumePositionIfNeeded()
        }
    }

    @ViewBuilder
    private func mediaPreview(for item: MediaItem) -> some View {
        if item.kind == .video, let player = playback.player {
            ZStack {
                Color.black
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: playback.videoAspectMode.contentMode)
            }
            .frame(maxWidth: .infinity)
            .frame(height: expandedVideo ? 144 : 102)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .onTapGesture {
                showingFullScreenVideo = true
            }
        } else {
            ZStack {
                if let artworkURL = library.artworkURL(for: item),
                   let image = UIImage(contentsOfFile: artworkURL.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(theme.screenGloss.opacity(0.55))
                    VStack(spacing: 7) {
                        Circle()
                            .stroke(theme.focus, lineWidth: 6)
                            .frame(width: 48, height: 48)
                        Text("AUDIO")
                            .font(theme.screenFont(size: 14, weight: .bold))
                    }
                    .foregroundColor(theme.focus)
                }
            }
            .frame(height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func progressControls(for item: MediaItem) -> some View {
        VStack(spacing: 5) {
            Slider(
                value: Binding(
                    get: { playback.currentTime },
                    set: { playback.seek(to: $0) }
                ),
                in: 0...max(playback.duration, 1)
            )
            .tint(theme.focus)

            HStack {
                Text(format(playback.currentTime))
                Spacer()
                Text(format(playback.duration))
            }
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(theme.secondaryText)

            HStack(spacing: 10) {
                Button("-10") {
                    playback.seek(by: -10)
                }

                Button("+10") {
                    playback.seek(by: 10)
                }

                Button(playback.videoAspectMode.label) {
                    playback.toggleVideoAspectMode()
                }
                .disabled(item.kind != .video)

                Button(expandedVideo ? "Small" : "Full") {
                    if item.kind == .video {
                        showingFullScreenVideo = true
                    } else {
                        expandedVideo.toggle()
                    }
                }
                .disabled(item.kind != .video)

                Button("Stop") {
                    saveResumePositionIfNeeded()
                    playback.stop()
                }
            }
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .buttonStyle(.plain)
            .foregroundColor(theme.focus)
        }
    }

    private func saveResumePositionIfNeeded() {
        guard let item = playback.currentItem, item.kind == .video else { return }
        try? library.setResumePosition(playback.currentTime, for: item)
    }

    private func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}

private struct FullScreenVideoPlayer: View {
    @Environment(\.dismiss) private var dismiss
    let player: AVPlayer

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            VideoPlayer(player: player)
                .ignoresSafeArea()
            Button("Done") {
                dismiss()
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .padding(12)
            .background(Color.black.opacity(0.62))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding()
        }
    }
}
