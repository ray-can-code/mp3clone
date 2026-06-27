import Foundation

enum MediaKind: String, Codable, Equatable {
    case audio
    case video

    static func kind(forExtension fileExtension: String) -> MediaKind? {
        switch fileExtension.lowercased() {
        case "mp3", "m4a", "aac", "wav", "aiff", "aif", "flac":
            return .audio
        case "mp4", "m4v", "mov":
            return .video
        default:
            return nil
        }
    }
}

struct MediaItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var artist: String?
    var album: String?
    var filename: String
    var kind: MediaKind
    var duration: TimeInterval?

    init(
        id: UUID = UUID(),
        title: String,
        artist: String? = nil,
        album: String? = nil,
        filename: String,
        kind: MediaKind,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.filename = filename
        self.kind = kind
        self.duration = duration
    }
}
