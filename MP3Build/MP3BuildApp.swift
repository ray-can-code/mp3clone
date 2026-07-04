import SwiftUI
import UIKit

@main
struct MP3BuildApp: App {
    init() {
        FontRegistry.registerMinecraftFont()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    var body: some Scene {
        WindowGroup {
            RootDeviceView()
        }
    }
}
