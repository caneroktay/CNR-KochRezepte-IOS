//
//  BackupManager.swift
//  KochRezepte
//
//  Created by Caner Oktay on 22.07.26.
//

import Foundation
import ZIPFoundation

enum BackupManager {

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private static var dbFileURL: URL { documentsDirectory.appendingPathComponent("recipes_database.json") }
    private static var imagesDirectory: URL { documentsDirectory.appendingPathComponent("images", isDirectory: true) }

    static func exportBackup(to destinationURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            guard let archive = Archive(url: destinationURL, accessMode: .create) else { return false }

            if FileManager.default.fileExists(atPath: dbFileURL.path) {
                try archive.addEntry(with: "recipes_database.json", relativeTo: documentsDirectory)
            }

            if let files = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) {
                for file in files {
                    let entryName = "images/\(file.lastPathComponent)"
                    try archive.addEntry(with: entryName, relativeTo: documentsDirectory, compressionMethod: .deflate)
                }
            }
            return true
        } catch {
            print("Export fehlgeschlagen: \(error)")
            return false
        }
    }

    static func importBackup(from sourceURL: URL) -> Bool {
        do {
            if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
                try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
            }
            guard let archive = Archive(url: sourceURL, accessMode: .read) else { return false }

            for entry in archive {
                if entry.path == "recipes_database.json" {
                    if FileManager.default.fileExists(atPath: dbFileURL.path) {
                        try? FileManager.default.removeItem(at: dbFileURL)
                    }
                    _ = try archive.extract(entry, to: dbFileURL)
                } else if entry.path.hasPrefix("images/") {
                    let fileName = String(entry.path.dropFirst("images/".count))
                    guard !fileName.isEmpty else { continue }
                    let dest = imagesDirectory.appendingPathComponent(fileName)
                    if FileManager.default.fileExists(atPath: dest.path) {
                        try? FileManager.default.removeItem(at: dest)
                    }
                    _ = try archive.extract(entry, to: dest)
                }
            }
            return true
        } catch {
            print("Import fehlgeschlagen: \(error)")
            return false
        }
    }
    static func importFromBundle(resourceName: String) -> Bool {
        guard let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: "zip") else {
            print("Bundle-Datei nicht gefunden: \(resourceName).zip")
            return false
        }
        return importBackup(from: bundleURL)
    }
}
