//
//  SettingsStore.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Keys.userName) }
    }
    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: Keys.language) }
    }

    private enum Keys {
        static let userName = "kochrezepte.userName"
        static let language = "kochrezepte.language"
    }

    init() {
        userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        language = UserDefaults.standard.string(forKey: Keys.language) ?? "de"
    }
}
