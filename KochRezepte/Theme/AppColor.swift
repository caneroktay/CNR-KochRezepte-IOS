//
//  AppColor.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

enum AppColor {
    // Hermes Orange tonları
    static let hermesOrange = Color(red: 0xD9 / 255, green: 0x72 / 255, blue: 0x0D / 255)
    static let hermesOrangeLight = Color(red: 0xE8 / 255, green: 0x94 / 255, blue: 0x4A / 255)

    // Arka plan / yüzey tonları (koyu tema)
    static let backgroundBlack = Color(red: 0x0A / 255, green: 0x0A / 255, blue: 0x0A / 255)
    static let surfaceDark = Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1E / 255)
    static let surfaceDarkElevated = Color(red: 0x2A / 255, green: 0x2A / 255, blue: 0x2C / 255)

    // Metin renkleri
    static let textPrimary = Color(red: 0xF5 / 255, green: 0xF5 / 255, blue: 0xF5 / 255)
    static let textSecondary = Color(red: 0xB3 / 255, green: 0xB3 / 255, blue: 0xB3 / 255)
    static let textOnOrange = Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255)

    // Durum renkleri
    static let dangerRed = Color(red: 0xE3 / 255, green: 0x3A / 255, blue: 0x3A / 255)
    static let successGreen = Color(red: 0x3D / 255, green: 0xBE / 255, blue: 0x5A / 255)
}
