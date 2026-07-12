import UIKit

/// Stores card photos as files in Application Support. SwiftData models only
/// keep the filename, which keeps the store small and images cheap to load.
enum ImageStore {
    private static let folderName = "CardImages"

    static var directoryURL: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let directory = base.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        return directory
    }

    /// Writes image data to disk and returns the generated filename,
    /// or `nil` if the write failed.
    static func save(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = directoryURL.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    static func loadImage(named filename: String?) -> UIImage? {
        guard let filename, !filename.isEmpty else { return nil }
        let url = directoryURL.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(_ filename: String?) {
        guard let filename, !filename.isEmpty else { return }
        let url = directoryURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    /// Removes every image referenced by a card. Call before deleting the model.
    static func deleteImages(of card: Card) {
        delete(card.frontImageFilename)
        delete(card.backImageFilename)
    }
}
