//
//  Router.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//
import SwiftUI
import Combine

enum Route: Hashable {
    case recipeList(categoryId: String?)
    case recipeForm(recipeId: String?)
    case recipeDetail(recipeId: String)
}

enum Tab: CaseIterable {
    case home, recipes, categories, settings
}

@MainActor
final class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Tab = .home

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func selectTab(_ tab: Tab) {
        selectedTab = tab
        popToRoot()
    }
}
