//
//  ImageStorageManager.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import Foundation
import UIKit

/// Kamera/galeriden gelen resimleri uygulamanın kendi Documents/images
/// klasörüne kaydeder. Bu klasör iOS'ta zaten sandbox'lı ve PRIVATE'tir —
/// Info.plist'te "Application supports iTunes file sharing" veya
/// "Supports opening documents in place" AÇMADIĞIN sürece Fotoğraflar
/// uygulamasında ASLA görünmez (Android'deki filesDir ile birebir aynı mantık).
final class ImageStorageManager {
    static let shared = ImageStorageManager()

    private var imagesDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// UIImage'i kalıcı depoya kaydeder, sadece dosya adını döner.
    func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let fileName = "\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return fileName
        } catch {
            print("Bild konnte nicht gespeichert werden: \(error)")
            return nil
        }
    }

    func imageURL(for fileName: String?) -> URL? {
        guard let fileName, !fileName.isEmpty else { return nil }
        let url = imagesDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func deleteImage(_ fileName: String?) {
        guard let fileName else { return }
        try? FileManager.default.removeItem(at: imagesDirectory.appendingPathComponent(fileName))
    }

    func deleteAllImages() {
        if let files = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) {
            files.forEach { try? FileManager.default.removeItem(at: $0) }
        }
    }
}
