import Combine
import Foundation

@MainActor
final class PlayerNavigationModel: ObservableObject {
    struct HomeEntry: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let screen: PlayerScreen
    }

    @Published private(set) var stack: [PlayerScreen] = [.home]
    @Published var selectedHomeIndex: Int = 0

    let homeEntries: [HomeEntry] = [
        HomeEntry(title: "Now Playing", screen: .nowPlaying),
        HomeEntry(title: "Music", screen: .music),
        HomeEntry(title: "Videos", screen: .videos),
        HomeEntry(title: "Settings", screen: .settings)
    ]

    var currentScreen: PlayerScreen {
        stack.last ?? .home
    }

    func moveSelection(delta: Int) {
        guard currentScreen == .home else { return }
        let count = homeEntries.count
        selectedHomeIndex = (selectedHomeIndex + delta + count) % count
    }

    func select() {
        guard currentScreen == .home else { return }
        stack.append(homeEntries[selectedHomeIndex].screen)
    }

    func back() {
        if stack.count > 1 {
            stack.removeLast()
        } else {
            selectedHomeIndex = 0
        }
    }

    func home() {
        stack = [.home]
        selectedHomeIndex = 0
    }
}
