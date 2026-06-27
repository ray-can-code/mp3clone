import SwiftUI

struct MediaListView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary
    @EnvironmentObject private var playback: PlaybackController
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var kind: MediaKind

    @State private var showingImporter = false
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button("+") {
                    showingImporter = true
                }
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)

                Text(kind == .audio ? "Import Music" : "Import Video")
                    .foregroundColor(theme.secondaryText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }

            if items.isEmpty {
                Spacer()
                Text(kind == .audio ? "No songs yet" : "No videos yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.secondaryText)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(items) { item in
                            Button {
                                playback.play(item: item, fileURL: library.fileURL(for: item))
                                navigation.home()
                                navigation.select()
                            } label: {
                                HStack {
                                    Text(item.title)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.70)
                                    Spacer()
                                    Text(item.kind == .video ? "MP4" : "AUD")
                                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                                }
                                .foregroundColor(theme.primaryText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let message {
                Text(message)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.focus)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
        }
        .sheet(isPresented: $showingImporter) {
            ImportButton { url in
                do {
                    try library.importFile(from: url)
                    message = "Imported \(url.lastPathComponent)"
                } catch MediaLibrary.LibraryError.unsupportedFile {
                    message = "Unsupported file"
                } catch {
                    message = "Could not import"
                }
            }
        }
    }

    private var items: [MediaItem] {
        kind == .audio ? library.audioItems : library.videoItems
    }
}
