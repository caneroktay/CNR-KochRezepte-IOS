//
//  RecipeFormView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI
import PhotosUI

private struct PickedImage: Identifiable {
    let id = UUID()
    enum Source {
        case existing(String)
        case new(UIImage)
    }
    var source: Source
}

struct RecipeFormView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var recipeStore: RecipeStore

    var recipeId: String?

    private var existing: Recipe? {
        recipeStore.database.recipes.first(where: { $0.id == recipeId })
    }
    private var isNew: Bool { existing == nil }

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var timeMinutes = 30
    @State private var preparation = ""
    @State private var note = ""
    @State private var links: [String] = []
    @State private var selectedCategoryIds: [String] = []
    @State private var ingredients: [Ingredient] = []
    @State private var images: [PickedImage] = []

    @State private var showImageSourceDialog = false
    @State private var showCamera = false
    @State private var showGalleryPicker = false
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    router.pop()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("List...")
                    }
                }
                .foregroundColor(AppColor.textPrimary)

                Spacer()

                if !isNew {
                    Button {
                        if let id = existing?.id {
                            recipeStore.deleteRecipe(id)
                        }
                        router.pop()
                    } label: {
                        Text("Löschen").foregroundColor(AppColor.dangerRed)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 40)
                    .background(AppColor.surfaceDarkElevated)
                    .clipShape(Capsule())
                    .padding(.trailing, 8)
                }

                Button {
                    handleSave()
                } label: {
                    Text(isSaving ? "Speichert..." : "Speichern")
                        .foregroundColor(.black)
                }
                .disabled(isSaving)
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(AppColor.successGreen)
                .clipShape(Capsule())
            }
            .padding(16)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(isNew ? "Neu Rezept..." : "Rezept bearbeiten")
                        .foregroundColor(AppColor.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(images) { item in
                                ZStack(alignment: .topTrailing) {
                                    imageView(for: item)
                                        .frame(width: 110, height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .background(AppColor.surfaceDark)

                                    Button {
                                        images.removeAll { $0.id == item.id }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                    }
                                    .padding(4)
                                }
                            }

                            Button {
                                showImageSourceDialog = true
                            } label: {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.surfaceDark)
                                    .frame(width: 110, height: 110)
                                    .overlay(Image(systemName: "camera.fill.badge.plus").foregroundColor(AppColor.hermesOrange))
                            }
                        }
                    }

                    TextField("Rezept Title", text: $title)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        .foregroundColor(AppColor.textPrimary)

                    Menu {
                        ForEach(recipeStore.database.categories) { category in
                            Button {
                                if selectedCategoryIds.contains(category.id) {
                                    selectedCategoryIds.removeAll { $0 == category.id }
                                } else {
                                    selectedCategoryIds.append(category.id)
                                }
                            } label: {
                                HStack {
                                    Text(category.name)
                                    if selectedCategoryIds.contains(category.id) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(categorySummary)
                            Spacer()
                        }
                        .foregroundColor(AppColor.textPrimary)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                    }

                    TextEditor(text: $descriptionText)
                        .frame(height: 120)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        .foregroundColor(AppColor.textPrimary)
                        .scrollContentBackground(.hidden)

                    HStack {
                        Text("Zeit (Min.)").foregroundColor(AppColor.textPrimary)
                        Spacer()
                        HStack(spacing: 18) {
                            Button {
                                timeMinutes = max(0, timeMinutes - 5)
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundColor(AppColor.hermesOrange)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(AppColor.surfaceDarkElevated))
                            }
                            Text("\(timeMinutes)")
                                .foregroundColor(AppColor.textPrimary)
                                .font(.title3)
                                .frame(minWidth: 40)
                                .multilineTextAlignment(.center)
                            Button {
                                timeMinutes += 5
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(AppColor.textOnOrange)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(AppColor.hermesOrange))
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(AppColor.surfaceDark))

                    HStack {
                        Text("Zutaten").foregroundColor(AppColor.textPrimary).font(.headline)
                        Spacer()
                        Button {
                            ingredients.append(Ingredient(name: ""))
                        } label: {
                            Image(systemName: "plus").foregroundColor(AppColor.hermesOrange)
                        }
                    }

                    ForEach($ingredients) { $ingredient in
                        HStack(spacing: 8) {
                            TextField("Menge", text: $ingredient.amount)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(AppColor.textSecondary))
                                .foregroundColor(AppColor.textPrimary)
                                .frame(width: 100)
                            TextField("Zutat", text: $ingredient.name)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(AppColor.textSecondary))
                                .foregroundColor(AppColor.textPrimary)
                            Button {
                                ingredients.removeAll { $0.id == ingredient.id }
                            } label: {
                                Image(systemName: "xmark").foregroundColor(AppColor.dangerRed)
                            }
                        }
                    }

                    TextEditor(text: $preparation)
                        .frame(height: 160)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        .foregroundColor(AppColor.textPrimary)
                        .scrollContentBackground(.hidden)

                    TextField("Note", text: $note)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        .foregroundColor(AppColor.textPrimary)

                    HStack {
                        Text("Links").foregroundColor(AppColor.textPrimary).font(.headline)
                        Spacer()
                        Button {
                            links.append("")
                        } label: {
                            Image(systemName: "plus").foregroundColor(AppColor.hermesOrange)
                        }
                    }

                    ForEach(links.indices, id: \.self) { index in
                        HStack(spacing: 8) {
                            TextField("z. B. https://youtube.com/...", text: $links[index])
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(AppColor.textSecondary))
                                .foregroundColor(AppColor.textPrimary)
                            Button {
                                links.remove(at: index)
                            } label: {
                                Image(systemName: "xmark").foregroundColor(AppColor.dangerRed)
                            }
                        }
                    }

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 20)
            }
        }
        
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: loadInitialState)
        .confirmationDialog("Foto hinzufügen", isPresented: $showImageSourceDialog, titleVisibility: .visible) {
            Button("Kamera") { showCamera = true }
            Button("Galerie") { showGalleryPicker = true }
            Button("Abbrechen", role: .cancel) {}
        }
        .photosPicker(isPresented: $showGalleryPicker, selection: $photoPickerItems, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                images.append(PickedImage(source: .new(image)))
            }
            .ignoresSafeArea()
        }
        .onChange(of: photoPickerItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(PickedImage(source: .new(uiImage)))
                    }
                }
                photoPickerItems = []
            }
        }
    }

    private var categorySummary: String {
        if selectedCategoryIds.isEmpty { return "Kategorien" }
        let names = recipeStore.database.categories
            .filter { selectedCategoryIds.contains($0.id) }
            .map { $0.name }
        return names.joined(separator: ", ")
    }

    @ViewBuilder
    private func imageView(for item: PickedImage) -> some View {
        switch item.source {
        case .existing(let fileName):
            if let url = recipeStore.resolveImageURL(fileName) {
                AsyncImage(url: url) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear }
            } else {
                Color.clear
            }
        case .new(let uiImage):
            Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
        }
    }

    private func loadInitialState() {
        guard let recipe = existing else { return }
        title = recipe.title
        descriptionText = recipe.description
        timeMinutes = recipe.timeMinutes
        preparation = recipe.preparation
        note = recipe.note
        links = recipe.links
        selectedCategoryIds = recipe.categoryIds
        ingredients = recipe.ingredients
        let fileNames = recipe.imageFileNames.isEmpty ? [recipe.imageFileName].compactMap { $0 } : recipe.imageFileNames
        images = fileNames.map { PickedImage(source: .existing($0)) }
    }

    private func handleSave() {
        guard !isSaving else { return }
        isSaving = true

        var finalFileNames: [String] = []
        for item in images {
            switch item.source {
            case .existing(let fileName):
                finalFileNames.append(fileName)
            case .new(let uiImage):
                if let fileName = recipeStore.saveImage(uiImage) {
                    finalFileNames.append(fileName)
                }
            }
        }

        var recipe = existing ?? Recipe(title: title)
        recipe.title = title
        recipe.categoryIds = selectedCategoryIds
        recipe.description = descriptionText
        recipe.timeMinutes = timeMinutes
        recipe.ingredients = ingredients
        recipe.preparation = preparation
        recipe.note = note
        recipe.links = links.filter { !$0.isEmpty }
        recipe.imageFileNames = finalFileNames
        recipe.imageFileName = finalFileNames.first

        recipeStore.saveRecipe(recipe)
        isSaving = false
        router.pop()
    }
}
