import SwiftUI

struct RootDeviceView: View {
    @StateObject private var library = MediaLibrary()
    @StateObject private var playback = PlaybackController()
    @StateObject private var navigation = PlayerNavigationModel()

    private let theme = PlayerTheme.sunburstClassic

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.bodyTop, theme.bodyBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(theme.bodyEdge.opacity(0.28), lineWidth: 8)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)

            VStack(spacing: 22) {
                DeviceScreenView()
                    .environmentObject(library)
                    .environmentObject(playback)
                    .environmentObject(navigation)
                    .environment(\.playerTheme, theme)
                    .frame(maxWidth: 340)
                    .frame(height: 218)

                ClickWheelView(
                    onRotate: navigation.moveSelection,
                    onMenu: navigation.back,
                    onSelect: navigation.select,
                    onPrevious: {},
                    onNext: {},
                    onPlayPause: playback.togglePlayPause
                )
                .environment(\.playerTheme, theme)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 34)
        }
    }
}

struct RootDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        RootDeviceView()
            .previewDevice("iPhone 8")
    }
}
