//
//  RootView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = Router()
    @State private var showOnboarding = true

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView { showOnboarding = false }
            } else {
                NavigationStack(path: $router.path) {
                    MainTabContent()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .recipeList(let categoryId):
                                RecipeListView(filterCategoryId: categoryId)
                            case .recipeForm(let recipeId):
                                RecipeFormView(recipeId: recipeId)
                            case .recipeDetail(let recipeId):
                                RecipeDetailView(recipeId: recipeId)
                            }
                        }
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
        }
        .environmentObject(router)
    }
}

private struct MainTabContent: View {
    @EnvironmentObject var router: Router

    var body: some View {
        switch router.selectedTab {
        case .home: HomeView()
        case .recipes: RecipeListView(filterCategoryId: nil)
        case .categories: CategoryListView()
        case .settings: SettingsView()
        }
    }
}
