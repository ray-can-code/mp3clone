import SwiftUI

struct MediaListView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary
    @EnvironmentObject private var playback: PlaybackController
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var kind: MediaKind

    @State private var showingImporter = false
    @State private var message: String?
    @State private var sortMode: MediaSortMode = .title
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button("+") {
                    showingImporter = true
                }
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)

                Text(kind == .audio ? "Import Music" : "Import Video")
                    .foregroundColor(theme.secondaryText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)

                Spacer()

                Button(sortMode.label) {
                    cycleSortMode()
                }
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)
            }

            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            if items.isEmpty {
                Spacer()
                Text(kind == .audio ? "No songs yet" : "No videos yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.secondaryText)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(items) { item in
                            HStack(spacing: 8) {
                                Button {
                                    playback.play(item: item, fileURL: library.fileURL(for: item))
                                    if item.kind == .video {
                                        playback.seek(to: library.resumePosition(for: item))
                                    }
                                    navigation.home()
                                    navigation.select()
                                } label: {
                                    HStack {
                                        Text(item.title)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.70)
                                        Spacer()
                                        Text(item.kind == .video ? "MP4" : "AUD")
                                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    }
                                    .foregroundColor(theme.primaryText)
                                }
                                .buttonStyle(.plain)

                                Button("X") {
                                    delete(item)
                                }
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .buttonStyle(.plain)
                                .foregroundColor(theme.secondaryText)
                            }
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
        let base = library.items(kind: kind, sortedBy: sortMode)
        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || ($0.artist?.localizedCaseInsensitiveContains(searchText) ?? false)
                || ($0.album?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private func cycleSortMode() {
        let all = MediaSortMode.allCases
        guard let index = all.firstIndex(of: sortMode) else {
            sortMode = .title
            return
        }
        sortMode = all[(index + 1) % all.count]
    }

    private func delete(_ item: MediaItem) {
        do {
            try library.delete(item)
            message = "Deleted \(item.title)"
        } catch {
            message = "Could not delete"
        }
    }
}
