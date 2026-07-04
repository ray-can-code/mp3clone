import SwiftUI
import UIKit

enum MediaListMode {
    case standard
    case audiobooks

    var importTitle: String {
        switch self {
        case .standard: return "Import"
        case .audiobooks: return "Import Book"
        }
    }
}

struct MediaListView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary
    @EnvironmentObject private var playback: PlaybackController
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var kind: MediaKind
    var mode: MediaListMode = .standard

    @State private var showingImporter = false
    @State private var message: String?
    @State private var sortMode: MediaSortMode = .title
    @State private var filterMode: MediaFilterMode = .all
    @State private var searchText = ""
    @State private var messageVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Button("+") {
                    showingImporter = true
                }
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)

                Text(importTitle)
                    .foregroundColor(theme.secondaryText)
                    .font(theme.screenFont(size: 13, weight: .bold))
                    .lineLimit(1)

                Spacer()

                Button(filterMode.label) {
                    cycleFilterMode()
                }
                .font(theme.screenFont(size: 12, weight: .bold))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)

                Button(sortMode.label) {
                    cycleSortMode()
                }
                .font(theme.screenFont(size: 12, weight: .bold))
                .buttonStyle(.plain)
                .foregroundColor(theme.focus)
            }

            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(theme.screenFont(size: 12, weight: .bold))
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            if items.isEmpty {
                Spacer()
                Text(emptyTitle)
                    .font(theme.screenFont(size: 18, weight: .bold))
                    .foregroundColor(theme.secondaryText)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(items) { item in
                            mediaRow(item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let message {
                Text(message)
                    .font(theme.screenFont(size: 11, weight: .bold))
                    .foregroundColor(theme.focus)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(messageVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: messageVisible)
            }
        }
        .sheet(isPresented: $showingImporter) {
            ImportButton { url in
                do {
                    try library.importFile(from: url)
                    showMessage("Imported \(shortName(url.lastPathComponent))")
                } catch MediaLibrary.LibraryError.unsupportedFile {
                    showMessage("Unsupported file")
                } catch {
                    showMessage("Could not import")
                }
            }
        }
    }

    @ViewBuilder
    private func mediaRow(_ item: MediaItem) -> some View {
        HStack(spacing: 7) {
            thumbnail(for: item)

            Button {
                open(item)
            } label: {
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title)
                        .font(theme.screenFont(size: 15, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                    Text(detail(for: item))
                        .font(theme.screenFont(size: 10))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .foregroundColor(theme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(theme.primaryText)
            }
            .buttonStyle(.plain)

            Button(library.isFavorite(item) ? "*" : "+") {
                toggleFavorite(item)
            }
            .font(theme.screenFont(size: 14, weight: .bold))
            .buttonStyle(.plain)
            .foregroundColor(theme.focus)

            Button("M") {
                addToMix(item)
            }
            .font(theme.screenFont(size: 12, weight: .bold))
            .buttonStyle(.plain)
            .foregroundColor(theme.secondaryText)

            Button("X") {
                delete(item)
            }
            .font(theme.screenFont(size: 11, weight: .bold))
            .buttonStyle(.plain)
            .foregroundColor(theme.secondaryText)
        }
    }

    @ViewBuilder
    private func thumbnail(for item: MediaItem) -> some View {
        if item.kind == .photo, let image = UIImage(contentsOfFile: library.fileURL(for: item).path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        } else if let artworkURL = library.artworkURL(for: item),
                  let image = UIImage(contentsOfFile: artworkURL.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(theme.screenGloss.opacity(0.58))
                .overlay {
                    Text(item.kind.shortLabel)
                        .font(theme.screenFont(size: 9, weight: .bold))
                        .foregroundColor(theme.focus)
                }
                .frame(width: 28, height: 28)
        }
    }

    private var items: [MediaItem] {
        var base = library.items(kind: kind, sortedBy: mode == .audiobooks ? .recentlyAdded : sortMode)
        if mode == .audiobooks {
            base = base.filter { ($0.duration ?? 0) >= 900 || $0.album?.localizedCaseInsensitiveContains("book") == true }
            if base.isEmpty {
                base = library.items(kind: kind, sortedBy: sortMode)
            }
        }

        switch filterMode {
        case .all:
            break
        case .favorites:
            base = base.filter { library.isFavorite($0) }
        case .mix:
            if let playlist = library.playlists.first(where: { $0.name == "Wheel Mix" }) {
                let ids = Set(playlist.itemIDs)
                base = base.filter { ids.contains($0.id) }
            } else {
                base = []
            }
        case .artist:
            base = base.sorted { ($0.artist ?? $0.title).localizedCaseInsensitiveCompare($1.artist ?? $1.title) == .orderedAscending }
        case .album:
            base = base.sorted { ($0.album ?? $0.title).localizedCaseInsensitiveCompare($1.album ?? $1.title) == .orderedAscending }
        }

        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || ($0.artist?.localizedCaseInsensitiveContains(searchText) ?? false)
                || ($0.album?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private var importTitle: String {
        if mode == .audiobooks { return "Import Book" }
        switch kind {
        case .audio: return "Import Music"
        case .video: return "Import Video"
        case .photo: return "Import Photo"
        }
    }

    private var emptyTitle: String {
        if mode == .audiobooks { return "No books yet" }
        switch kind {
        case .audio: return "No songs yet"
        case .video: return "No videos yet"
        case .photo: return "No photos yet"
        }
    }

    private func detail(for item: MediaItem) -> String {
        let creator = item.artist ?? item.album ?? item.filename
        if item.kind == .video, library.resumePosition(for: item) > 1 {
            return "\(creator) - resume \(format(library.resumePosition(for: item)))"
        }
        if item.kind == .photo {
            return item.filename
        }
        return creator
    }

    private func cycleSortMode() {
        let all = MediaSortMode.allCases
        guard let index = all.firstIndex(of: sortMode) else {
            sortMode = .title
            return
        }
        sortMode = all[(index + 1) % all.count]
    }

    private func cycleFilterMode() {
        let all = MediaFilterMode.allCases
        guard let index = all.firstIndex(of: filterMode) else {
            filterMode = .all
            return
        }
        filterMode = all[(index + 1) % all.count]
    }

    private func open(_ item: MediaItem) {
        guard item.kind != .photo else {
            showMessage("Saved photo: \(shortName(item.title))")
            return
        }

        playback.play(
            item: item,
            fileURL: library.fileURL(for: item),
            resumeAt: library.resumePosition(for: item),
            queue: playableQueue
        )
        navigation.home()
        navigation.select()
    }

    private func toggleFavorite(_ item: MediaItem) {
        do {
            try library.toggleFavorite(item)
            showMessage(library.isFavorite(item) ? "Favorite saved" : "Favorite removed")
        } catch {
            showMessage("Could not favorite")
        }
    }

    private func addToMix(_ item: MediaItem) {
        do {
            try library.add(item, toPlaylistNamed: "Wheel Mix")
            showMessage("Added \(shortName(item.title)) to Wheel Mix")
        } catch {
            showMessage("Could not add")
        }
    }

    private func delete(_ item: MediaItem) {
        do {
            try library.delete(item)
            showMessage("Deleted \(shortName(item.title))")
        } catch {
            showMessage("Could not delete")
        }
    }

    private var playableQueue: [(MediaItem, URL)] {
        items
            .filter { $0.kind != .photo }
            .map { ($0, library.fileURL(for: $0)) }
    }

    private func showMessage(_ text: String) {
        message = text
        messageVisible = true
        let current = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard message == current else { return }
            messageVisible = false
        }
    }

    private func shortName(_ text: String) -> String {
        if text.count <= 22 { return text }
        return "\(text.prefix(19))..."
    }

    private func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}

private enum MediaFilterMode: CaseIterable {
    case all
    case favorites
    case mix
    case artist
    case album

    var label: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Fav"
        case .mix: return "Mix"
        case .artist: return "Artist"
        case .album: return "Album"
        }
    }
}
