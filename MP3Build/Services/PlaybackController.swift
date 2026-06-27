import AVFoundation
import Combine
import Foundation

@MainActor
final class PlaybackController: ObservableObject {
    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
        case failed(String)
    }

    @Published private(set) var currentItem: MediaItem?
    @Published private(set) var state: PlaybackState = .stopped
    @Published private(set) var player: AVPlayer?

    func play(item: MediaItem, fileURL: URL) {
        currentItem = item
        player = AVPlayer(url: fileURL)
        player?.play()
        state = .playing
    }

    func togglePlayPause() {
        switch state {
        case .playing:
            player?.pause()
            state = .paused
        case .paused:
            player?.play()
            state = .playing
        case .stopped:
            guard currentItem != nil else { return }
            player?.play()
            state = .playing
        case .failed:
            break
        }
    }

    func stop() {
        player?.pause()
        player = nil
        state = .stopped
    }
}
