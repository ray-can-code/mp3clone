import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ImportButton: UIViewControllerRepresentable {
    var onImport: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types = [
            UTType.audio,
            UTType.movie,
            UTType.mpeg4Movie,
            UTType.quickTimeMovie,
            UTType(filenameExtension: "mp3"),
            UTType(filenameExtension: "flac")
        ].compactMap { $0 }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImport: onImport)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onImport: (URL) -> Void

        init(onImport: @escaping (URL) -> Void) {
            self.onImport = onImport
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            urls.forEach(onImport)
        }
    }
}
