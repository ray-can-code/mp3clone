import CoreText
import Foundation

enum FontRegistry {
    static func registerMinecraftFont() {
        registerFont(resourceName: "minecraft", fileExtension: "ttf")
    }

    private static func registerFont(resourceName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            return
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
