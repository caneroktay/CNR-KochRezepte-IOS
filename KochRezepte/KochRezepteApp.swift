//
//  KochRezepteApp.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

@main
struct kochrezepteApp: App {
    @StateObject private var recipeStore = RecipeStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(recipeStore)
                .environmentObject(settingsStore)
                .preferredColorScheme(.dark)
                .dynamicTypeSize(.large)
        }
    }
}


