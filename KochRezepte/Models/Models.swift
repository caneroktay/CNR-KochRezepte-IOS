//
//  Models.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//


import Foundation

struct Ingredient: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var amount: String = ""
}

struct Category: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var imageFileName: String? = nil
}

struct Recipe: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var categoryIds: [String] = []
    var description: String = ""
    var timeMinutes: Int = 0
    var ingredients: [Ingredient] = []
    var preparation: String = ""
    var note: String = ""
    var links: [String] = []
    var imageFileName: String? = nil
    var imageFileNames: [String] = []
    var isFavorite: Bool = false
    var createdAt: Double = Date().timeIntervalSince1970 * 1000
}

struct RecipeDatabase: Codable, Equatable {
    var categories: [Category] = []
    var recipes: [Recipe] = []
}
