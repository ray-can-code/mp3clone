import SwiftUI

struct RootDeviceView: View {
    @StateObject private var library = MediaLibrary()
    @StateObject private var playback = PlaybackController()
    @StateObject private var navigation = PlayerNavigationModel()

    private let theme = PlayerTheme.defaultTheme

    var body: some View {
        GeometryReader { proxy in
            let outerWidth = min(proxy.size.width - 8, 390)
            let outerHeight = min(proxy.size.height - 8, outerWidth * 1.86)
            let screenHeight = min(276, outerHeight * 0.42)
            let wheelSize = min(226, outerWidth * 0.62)

            ZStack {
                Color.black.ignoresSafeArea()

                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.bodyTop, theme.bodyBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.white.opacity(0.72), lineWidth: 4)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(theme.bodyEdge.opacity(0.36), lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.42), radius: 22, y: 12)
                    .frame(width: outerWidth, height: outerHeight)

                VStack(spacing: 28) {
                    DeviceScreenView()
                        .environmentObject(library)
                        .environmentObject(playback)
                        .environmentObject(navigation)
                        .environment(\.playerTheme, theme)
                        .frame(width: outerWidth - 22, height: screenHeight)

                    ClickWheelView(
                        onRotate: rotateWheel,
                        onMenu: navigation.back,
                        onSelect: navigation.select,
                        onPrevious: { playback.seek(by: -10) },
                        onNext: { playback.seek(by: 10) },
                        onPlayPause: playback.togglePlayPause,
                        onPreviousLong: { playback.seek(by: -30) },
                        onNextLong: { playback.seek(by: 30) },
                        onPlayPauseLong: playback.stop
                    )
                    .environment(\.playerTheme, theme)
                    .frame(width: wheelSize, height: wheelSize)
                }
                .padding(.top, 24)
                .frame(width: outerWidth, height: outerHeight, alignment: .top)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func rotateWheel(_ delta: Int) {
        if navigation.currentScreen == .home {
            navigation.moveSelection(delta: delta)
        } else if navigation.currentScreen == .nowPlaying {
            playback.seek(by: TimeInterval(delta * 5))
        }
    }
}

struct RootDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        RootDeviceView()
            .previewDevice("iPhone 8")
    }
}
