import SwiftUI

@main
struct MP3BuildApp: App {
    init() {
        FontRegistry.registerMinecraftFont()
    }

    var body: some Scene {
        WindowGroup {
            RootDeviceView()
        }
    }
}
