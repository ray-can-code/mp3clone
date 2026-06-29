enum MediaSortMode: String, CaseIterable, Identifiable {
    case title
    case artist
    case album
    case recentlyAdded

    var id: String { rawValue }

    var label: String {
        switch self {
        case .title: return "Title"
        case .artist: return "Artist"
        case .album: return "Album"
        case .recentlyAdded: return "Recent"
        }
    }
}
