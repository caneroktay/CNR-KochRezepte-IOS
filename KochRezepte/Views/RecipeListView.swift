//
//  RecipeListView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var recipeStore: RecipeStore

    var filterCategoryId: String?

    @State private var searchText = ""
    @State private var selectedCategoryId: String?

    init(filterCategoryId: String?) {
        self.filterCategoryId = filterCategoryId
        _selectedCategoryId = State(initialValue: filterCategoryId)
    }

    private var filtered: [Recipe] {
        recipeStore.database.recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty || recipe.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategoryId == nil || recipe.categoryIds.contains(selectedCategoryId!)
            return matchesSearch && matchesCategory
        }
    }

    private var screenTitle: String {
        if let id = selectedCategoryId, let category = recipeStore.database.categories.first(where: { $0.id == id }) {
            return category.name
        }
        return "Meine KochRezepte"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(AppColor.surfaceDarkElevated)
                        Image(systemName: "person.fill").foregroundColor(AppColor.textSecondary)
                    }
                    .frame(width: 44, height: 44)

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(AppColor.textSecondary)
                        TextField("Search...", text: $searchText)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Capsule().stroke(AppColor.surfaceDarkElevated, lineWidth: 1))

                    Menu {
                        Button("Alle") { selectedCategoryId = nil }
                        ForEach(recipeStore.database.categories) { category in
                            Button(category.name) { selectedCategoryId = category.id }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.down")
                            Text("Kategorien")
                        }
                        .foregroundColor(AppColor.hermesOrange)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Capsule().stroke(AppColor.surfaceDarkElevated, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                HStack {
                    Text(screenTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Button {
                        router.push(.recipeForm(recipeId: nil))
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Neu")
                        }
                        .foregroundColor(AppColor.hermesOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(filtered) { recipe in
                            let categoryName = recipe.categoryIds.first.flatMap { id in
                                recipeStore.database.categories.first(where: { $0.id == id })?.name
                            } ?? "Rezept"
                            RecipeRowView(
                                title: recipe.title,
                                subtitle: categoryName,
                                imageURL: recipeStore.resolveImageURL(recipe.imageFileName),
                                isFavorite: recipe.isFavorite,
                                onToggleFavorite: { recipeStore.toggleFavorite(recipe.id) },
                                onTap: { router.push(.recipeDetail(recipeId: recipe.id)) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                }
            }

            BottomNavBar()
        }
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
