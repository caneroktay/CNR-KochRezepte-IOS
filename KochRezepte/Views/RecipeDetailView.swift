//
//  RecipeDetailView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var recipeStore: RecipeStore

    var recipeId: String

    @State private var showDeleteConfirm = false
    @State private var fullscreenIndex: Int?

    private var recipe: Recipe? {
        recipeStore.database.recipes.first(where: { $0.id == recipeId })
    }

    private var imageURLs: [URL] {
        guard let recipe else { return [] }
        let fileNames = recipe.imageFileNames.isEmpty ? [recipe.imageFileName].compactMap { $0 } : recipe.imageFileNames
        return fileNames.compactMap { recipeStore.resolveImageURL($0) }
    }

    private var categoryNames: [String] {
        guard let recipe else { return [] }
        return recipe.categoryIds.compactMap { id in
            recipeStore.database.categories.first(where: { $0.id == id })?.name
        }
    }

    var body: some View {
        Group {
            if let recipe {
                content(recipe)
            } else {
                Color.clear.onAppear { router.pop() }
            }
        }
    }

    @ViewBuilder
    private func content(_ recipe: Recipe) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    router.pop()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .foregroundColor(AppColor.textPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if imageURLs.isEmpty {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppColor.surfaceDark)
                            .frame(height: 220)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                                    AsyncImage(url: url) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear }
                                        .frame(width: 260, height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .background(AppColor.surfaceDark)
                                        .contentShape(Rectangle())
                                        .onTapGesture { fullscreenIndex = index }
                                }
                            }
                        }
                    }

                    HStack {
                        Text(recipe.title)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                        Spacer()
                        Button {
                            recipeStore.toggleFavorite(recipe.id)
                        } label: {
                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(AppColor.hermesOrange)
                        }
                    }

                    if !categoryNames.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(categoryNames, id: \.self) { name in
                                Text(name)
                                    .foregroundColor(AppColor.hermesOrange)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(AppColor.surfaceDarkElevated))
                            }
                        }
                    }

                    if recipe.timeMinutes > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "clock").foregroundColor(AppColor.textSecondary)
                            Text("\(recipe.timeMinutes) Min.").foregroundColor(AppColor.textSecondary)
                        }
                    }

                    if !recipe.description.isEmpty {
                        Text(recipe.description).foregroundColor(AppColor.textPrimary)
                    }

                    if !recipe.ingredients.isEmpty {
                        Text("Zutaten").font(.headline).foregroundColor(AppColor.textPrimary)
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name).foregroundColor(AppColor.textPrimary)
                                Spacer()
                                if !ingredient.amount.isEmpty {
                                    Text(ingredient.amount).foregroundColor(AppColor.textSecondary)
                                }
                            }
                        }
                    }

                    if !recipe.preparation.isEmpty {
                        Text("Zubereitung").font(.headline).foregroundColor(AppColor.textPrimary)
                        Text(recipe.preparation).foregroundColor(AppColor.textPrimary)
                    }

                    if !recipe.note.isEmpty {
                        Text("Notiz").font(.headline).foregroundColor(AppColor.textPrimary)
                        Text(recipe.note).foregroundColor(AppColor.textSecondary)
                    }

                    if !recipe.links.isEmpty {
                        Text("Links").font(.headline).foregroundColor(AppColor.textPrimary)
                        ForEach(recipe.links, id: \.self) { link in
                            Button {
                                if let url = URL(string: link) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "link").foregroundColor(AppColor.hermesOrange)
                                    Text(link)
                                        .foregroundColor(AppColor.hermesOrange)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 16).fill(AppColor.surfaceDark))
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        Button {
                            router.push(.recipeForm(recipeId: recipe.id))
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Bearbeiten")
                            }
                            .foregroundColor(AppColor.textOnOrange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppColor.hermesOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            showDeleteConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Löschen")
                            }
                            .foregroundColor(AppColor.dangerRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.dangerRed))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Rezept löschen?", isPresented: $showDeleteConfirm) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                recipeStore.deleteRecipe(recipe.id)
                router.pop()
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .fullScreenCover(isPresented: Binding(
            get: { fullscreenIndex != nil },
            set: { if !$0 { fullscreenIndex = nil } }
        )) {
            if let startIndex = fullscreenIndex {
                FullscreenImageViewer(urls: imageURLs, startIndex: startIndex) {
                    fullscreenIndex = nil
                }
            }
        }
    }
}

private struct FullscreenImageViewer: View {
    let urls: [URL]
    let startIndex: Int
    var onClose: () -> Void

    @State private var currentIndex: Int

    init(urls: [URL], startIndex: Int, onClose: @escaping () -> Void) {
        self.urls = urls
        self.startIndex = startIndex
        self.onClose = onClose
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }
                Spacer()
                if urls.count > 1 {
                    Text("\(currentIndex + 1) / \(urls.count)")
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                }
            }
        }
    }
}
