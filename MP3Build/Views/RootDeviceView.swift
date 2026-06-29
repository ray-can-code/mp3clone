import SwiftUI

struct RootDeviceView: View {
    @StateObject private var library = MediaLibrary()
    @StateObject private var playback = PlaybackController()
    @StateObject private var navigation = PlayerNavigationModel()

    private let theme = PlayerTheme.defaultTheme

    var body: some View {
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
                .padding(.horizontal, 20)
                .padding(.vertical, 54)

            VStack(spacing: 18) {
                DeviceScreenView()
                    .environmentObject(library)
                    .environmentObject(playback)
                    .environmentObject(navigation)
                    .environment(\.playerTheme, theme)
                    .frame(maxWidth: 340)
                    .frame(height: 210)

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
            .padding(.vertical, 64)
        }
    }
}

struct RootDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        RootDeviceView()
            .previewDevice("iPhone 8")
    }
}
