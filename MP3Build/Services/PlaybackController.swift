import AVFoundation
import Combine
import Foundation
import MediaPlayer

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
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var videoAspectMode: VideoAspectMode = .fit

    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var queue: [(item: MediaItem, fileURL: URL)] = []
    private var queueIndex: Int = 0

    func play(
        item: MediaItem,
        fileURL: URL,
        resumeAt: TimeInterval = 0,
        queue: [(MediaItem, URL)] = []
    ) {
        let resolvedQueue = queue.isEmpty ? [(item, fileURL)] : queue
        self.queue = resolvedQueue.map { (item: $0.0, fileURL: $0.1) }
        self.queueIndex = self.queue.firstIndex(where: { $0.item.id == item.id }) ?? 0
        playCurrentQueueItem(resumeAt: resumeAt)
    }

    private func playCurrentQueueItem(resumeAt: TimeInterval = 0) {
        guard queue.indices.contains(queueIndex) else { return }
        let entry = queue[queueIndex]
        configureAudioSession()
        removeTimeObserver()
        removeEndObserver()
        currentItem = entry.item
        player = AVPlayer(url: entry.fileURL)
        duration = player?.currentItem?.asset.duration.seconds.finiteOrZero ?? 0
        currentTime = max(0, resumeAt)
        addTimeObserver()
        addEndObserver()
        if resumeAt > 0 {
            player?.seek(to: CMTime(seconds: resumeAt, preferredTimescale: 600))
        }
        player?.play()
        state = .playing
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        switch state {
        case .playing:
            player?.pause()
            state = .paused
            updateNowPlayingInfo()
        case .paused:
            player?.play()
            state = .playing
            updateNowPlayingInfo()
        case .stopped:
            guard currentItem != nil else { return }
            player?.play()
            state = .playing
            updateNowPlayingInfo()
        case .failed:
            break
        }
    }

    func seek(by seconds: TimeInterval) {
        seek(to: currentTime + seconds)
    }

    func seek(to seconds: TimeInterval) {
        let clamped = max(0, min(seconds, duration > 0 ? duration : seconds))
        let time = CMTime(seconds: clamped, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = clamped
        updateNowPlayingInfo()
    }

    func toggleVideoAspectMode() {
        videoAspectMode = videoAspectMode == .fit ? .fill : .fit
    }

    func stop() {
        player?.pause()
        removeTimeObserver()
        removeEndObserver()
        player = nil
        currentItem = nil
        currentTime = 0
        duration = 0
        queue = []
        queueIndex = 0
        state = .stopped
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            state = .failed("Audio session failed")
        }
    }

    private func addEndObserver() {
        guard let item = player?.currentItem else { return }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.playNextFromQueue()
            }
        }
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
    }

    private func playNextFromQueue() {
        guard queueIndex + 1 < queue.count else {
            state = .stopped
            player?.seek(to: .zero)
            player?.pause()
            currentTime = 0
            updateNowPlayingInfo()
            return
        }

        queueIndex += 1
        playCurrentQueueItem()
    }

    private func addTimeObserver() {
        guard let player else { return }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds.finiteOrZero
                self?.duration = player.currentItem?.duration.seconds.finiteOrZero ?? self?.duration ?? 0
                self?.updateNowPlayingInfo()
            }
        }
    }

    private func removeTimeObserver() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
    }

    private func updateNowPlayingInfo() {
        guard let currentItem else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: currentItem.title,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0
        ]
        if let artist = currentItem.artist {
            info[MPMediaItemPropertyArtist] = artist
        }
        if let album = currentItem.album {
            info[MPMediaItemPropertyAlbumTitle] = album
        }
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

private extension Double {
    var finiteOrZero: Double {
        isFinite ? self : 0
    }
}
