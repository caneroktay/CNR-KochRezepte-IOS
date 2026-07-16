//
//  HomeView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var recipeStore: RecipeStore
    @EnvironmentObject var settingsStore: SettingsStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var favorites: [Recipe] {
        recipeStore.database.recipes.filter { $0.isFavorite }
    }

    var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(AppColor.surfaceDarkElevated)
                                Image(systemName: "person.fill").foregroundColor(AppColor.textSecondary)
                            }
                            .frame(width: 48, height: 48)

                            Text(settingsStore.userName.isEmpty ? "KochRezepte" : "\(settingsStore.userName) Lists")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(AppColor.textPrimary)
                        }

                        Text("Meine Kategorien")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(recipeStore.database.categories) { category in
                                ZStack {
                                    if let url = recipeStore.resolveImageURL(category.imageFileName) {
                                        AsyncImage(url: url) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear }
                                    } else {
                                        AppColor.surfaceDark
                                    }
                                    Text(category.name)
                                        .foregroundColor(AppColor.textPrimary)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    router.push(.recipeList(categoryId: category.id))
                                }
                            }
                        }

                        Text("Meine Lieblingsrezepte…")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)

                        VStack(spacing: 10) {
                            ForEach(favorites) { recipe in
                                RecipeRowView(
                                    title: recipe.title,
                                    subtitle: "Favorit",
                                    imageURL: recipeStore.resolveImageURL(recipe.imageFileName),
                                    isFavorite: recipe.isFavorite,
                                    onToggleFavorite: { recipeStore.toggleFavorite(recipe.id) },
                                    onTap: { router.push(.recipeDetail(recipeId: recipe.id)) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }

                BottomNavBar()
            }
            .background(AppColor.backgroundBlack.ignoresSafeArea())
        }
}

