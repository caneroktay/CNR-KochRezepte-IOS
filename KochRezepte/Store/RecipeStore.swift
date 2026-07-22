//
//  RecipeStore.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class RecipeStore: ObservableObject {
    @Published private(set) var database = RecipeDatabase()
    
    private let storage = RecipeJSONStorage.shared
    private let images = ImageStorageManager.shared
    
    init() {
        if !storage.exists() {
            _ = BackupManager.importFromBundle(resourceName: "default_data")
        }
        database = storage.load()
    }
    
    func resolveImageURL(_ fileName: String?) -> URL? {
        images.imageURL(for: fileName)
    }
    
    func saveImage(_ image: UIImage) -> String? {
        images.saveImage(image)
    }
    
    func saveRecipe(_ recipe: Recipe) {
        let previous = database.recipes.first { $0.id == recipe.id }
        for old in previous?.imageFileNames ?? [] where !recipe.imageFileNames.contains(old) {
            images.deleteImage(old)
        }
        
        var db = database
        if let index = db.recipes.firstIndex(where: { $0.id == recipe.id }) {
            db.recipes[index] = recipe
        } else {
            db.recipes.append(recipe)
        }
        database = db
        storage.save(db)
    }
    
    func deleteRecipe(_ id: String) {
        var db = database
        if let recipe = db.recipes.first(where: { $0.id == id }) {
            let files = recipe.imageFileNames.isEmpty
            ? [recipe.imageFileName].compactMap { $0 }
            : recipe.imageFileNames
            files.forEach { images.deleteImage($0) }
        }
        db.recipes.removeAll { $0.id == id }
        database = db
        storage.save(db)
    }
    
    func toggleFavorite(_ id: String) {
        guard var recipe = database.recipes.first(where: { $0.id == id }) else { return }
        recipe.isFavorite.toggle()
        saveRecipe(recipe)
    }
    
    func saveCategory(_ category: Category) {
        var db = database
        if let index = db.categories.firstIndex(where: { $0.id == category.id }) {
            db.categories[index] = category
        } else {
            db.categories.append(category)
        }
        database = db
        storage.save(db)
    }
    
    func deleteCategory(_ id: String) {
        var db = database
        db.categories.removeAll { $0.id == id }
        db.recipes = db.recipes.map { recipe in
            var r = recipe
            r.categoryIds.removeAll { $0 == id }
            return r
        }
        database = db
        storage.save(db)
    }
    
    func clearAllData() {
        database = RecipeDatabase()
        storage.save(database)
        images.deleteAllImages()
    }
    
    
    func importDatabase(_ newDatabase: RecipeDatabase) {
        database = newDatabase
        storage.save(newDatabase)
    }
    
    func reloadFromDisk() {
            database = storage.load()
        }
}
