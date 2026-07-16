//
//  CategoryListView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var recipeStore: RecipeStore

    @State private var searchText = ""
    @State private var showAddDialog = false
    @State private var newCategoryName = ""
    @State private var editingCategory: Category?
    @State private var editCategoryName = ""
    @State private var deletingCategory: Category?

    private var filtered: [Category] {
        let all = recipeStore.database.categories
        if searchText.isEmpty { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(AppColor.surfaceDarkElevated)
                        Image(systemName: "person.fill").foregroundColor(AppColor.textSecondary)
                    }
                    .frame(width: 48, height: 48)

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(AppColor.textSecondary)
                        TextField("Search...", text: $searchText)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Capsule().stroke(AppColor.surfaceDarkElevated, lineWidth: 1))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                HStack {
                    Text("Kategorien")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Button {
                        newCategoryName = ""
                        showAddDialog = true
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
                        ForEach(filtered) { category in
                            let recipeCount = recipeStore.database.recipes.filter { $0.categoryIds.contains(category.id) }.count
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(AppColor.surfaceDarkElevated)
                                    if let url = recipeStore.resolveImageURL(category.imageFileName) {
                                        AsyncImage(url: url) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear }
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "fork.knife.circle").foregroundColor(AppColor.textSecondary)
                                    }
                                }
                                .frame(width: 56, height: 56)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.name)
                                        .foregroundColor(AppColor.textPrimary)
                                        .font(.system(size: 17, weight: .semibold))
                                    Text("\(recipeCount) Rezept(e)")
                                        .foregroundColor(AppColor.hermesOrange)
                                        .font(.system(size: 14))
                                }

                                Spacer()

                                Button {
                                    editingCategory = category
                                    editCategoryName = category.name
                                } label: {
                                    Image(systemName: "pencil").foregroundColor(AppColor.textSecondary)
                                }
                                .frame(width: 36, height: 36)

                                Button {
                                    deletingCategory = category
                                } label: {
                                    Image(systemName: "trash").foregroundColor(AppColor.dangerRed)
                                }
                                .frame(width: 36, height: 36)
                            }
                            .padding(12)
                            .background(AppColor.surfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                router.push(.recipeList(categoryId: category.id))
                            }
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
        .alert("Neue Kategorie", isPresented: $showAddDialog) {
            TextField("Kategorie Name", text: $newCategoryName)
            Button("Abbrechen", role: .cancel) {}
            Button("Speichern") {
                if !newCategoryName.isEmpty {
                    recipeStore.saveCategory(Category(name: newCategoryName))
                }
            }
        }
        .alert("Kategorie bearbeiten", isPresented: Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )) {
            TextField("Kategorie Name", text: $editCategoryName)
            Button("Abbrechen", role: .cancel) { editingCategory = nil }
            Button("Speichern") {
                if let category = editingCategory, !editCategoryName.isEmpty {
                    var updated = category
                    updated.name = editCategoryName
                    recipeStore.saveCategory(updated)
                }
                editingCategory = nil
            }
        }
        .alert("Kategorie löschen?", isPresented: Binding(
            get: { deletingCategory != nil },
            set: { if !$0 { deletingCategory = nil } }
        )) {
            Button("Abbrechen", role: .cancel) { deletingCategory = nil }
            Button("Löschen", role: .destructive) {
                if let category = deletingCategory {
                    recipeStore.deleteCategory(category.id)
                }
                deletingCategory = nil
            }
        } message: {
            Text("Zugeordnete Rezepte bleiben erhalten, verlieren aber diese Kategorie.")
        }
    }
}
