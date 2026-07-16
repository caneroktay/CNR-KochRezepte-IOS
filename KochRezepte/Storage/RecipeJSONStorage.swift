//
//  RecipeJSONStorage.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import Foundation

final class RecipeJSONStorage {
    static let shared = RecipeJSONStorage()

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("recipes_database.json")
    }

    func load() -> RecipeDatabase {
        guard let data = try? Data(contentsOf: fileURL) else { return RecipeDatabase() }
        return (try? JSONDecoder().decode(RecipeDatabase.self, from: data)) ?? RecipeDatabase()
    }

    func save(_ database: RecipeDatabase) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(database) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
    
    func exists() -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }
}
