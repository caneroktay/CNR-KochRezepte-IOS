//
//  SettingsView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var recipeStore: RecipeStore
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var showDeleteConfirm = false
    @State private var showDocumentExporter = false
    @State private var showImporter = false
    @State private var exportZipURL: URL?


    var body: some View {
        ZStack(alignment: .bottom) {

            ScrollView {
                VStack(spacing: 0) {

                    // --- ÜST BAŞLIK ---
                    Text("Einstellungen")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                    // --- AYARLAR KARTI ---
                    VStack(spacing: 16) {
                        TextField("Benutzername", text: $settingsStore.userName)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                            .foregroundColor(AppColor.textPrimary)

                        Button {
                            let tempURL = FileManager.default.temporaryDirectory
                                .appendingPathComponent("kochrezepte_backup_\(Int(Date().timeIntervalSince1970)).zip")
                            if BackupManager.exportBackup(to: tempURL) {
                                exportZipURL = tempURL
                                showDocumentExporter = true
                            }
                        } label: {
                            HStack {
                                Text("Daten Exportieren")
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundColor(AppColor.textPrimary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        }

                        Button { showImporter = true } label: {
                            HStack {
                                Text("Daten Importieren")
                                Spacer()
                                Image(systemName: "square.and.arrow.down")
                            }
                            .foregroundColor(AppColor.textPrimary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.textSecondary))
                        }

                        Button { showDeleteConfirm = true } label: {
                            HStack {
                                Text("Alle Daten löschen")
                                Spacer()
                                Image(systemName: "trash")
                            }
                            .foregroundColor(AppColor.dangerRed)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(AppColor.dangerRed))
                        }
                    }
                    .padding(16)
                    .background(AppColor.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    // --- AÇIKLAMA + GELİŞTİRİCİ BİLGİSİ ---
                    VStack(spacing: 12) {
                        Text("Datenhinweis")
                            .font(.headline)
                            .foregroundColor(AppColor.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("""
        • Um Ihre Rezepte zu sichern, tippen Sie einfach auf „Daten Exportieren“ und speichern Sie die ZIP‑Datei auf Ihrem Smartphone.

        • Wenn Sie das Gerät wechseln oder Ihre Rezepte auf ein anderes Handy übertragen möchten, schicken Sie diese ZIP‑Datei an das neue Gerät.

        • Öffnen Sie dort die KochRezepte‑App, wählen Sie „Daten Importieren“ und anschließend die ZIP‑Datei aus.

        • Damit werden alle Rezepte vollständig übernommen.
        """)
                        .font(.system(size: 14))
                        .foregroundColor(AppColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 4) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .opacity(0.8)

                            Text("Entwickelt von Caner Oktay")
                                .foregroundColor(AppColor.textPrimary)
                                .font(.footnote)

                            Text("caneroktay.com")
                                .foregroundColor(AppColor.textSecondary)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                    }
                    .padding(20)
                    .background(AppColor.surfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // ScrollView alt boşluk
                }
            }

            BottomNavBar()
        }
        .background(AppColor.backgroundBlack.ignoresSafeArea())
        .alert("Alle Daten löschen?", isPresented: $showDeleteConfirm) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) { recipeStore.clearAllData() }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .sheet(isPresented: $showDocumentExporter) {
            if let url = exportZipURL {
                DocumentExporter(url: url) { _ in showDocumentExporter = false }
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.zip]
        ) { result in
            if case .success(let url) = result {
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                if BackupManager.importBackup(from: url) {
                    recipeStore.reloadFromDisk()
                }
            }
        }
    }
}
