import SwiftUI

enum VideoAspectMode: String, CaseIterable, Identifiable {
    case fit
    case fill

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fit: return "Fit"
        case .fill: return "Fill"
        }
    }

    var contentMode: ContentMode {
        switch self {
        case .fit: return .fit
        case .fill: return .fill
        }
    }
}
