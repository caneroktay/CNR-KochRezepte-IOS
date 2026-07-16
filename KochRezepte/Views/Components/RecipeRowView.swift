//
//  RecipeRowView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct RecipeRowView: View {
    let title: String
    let subtitle: String
    let imageURL: URL?
    var isFavorite: Bool? = nil
    var onToggleFavorite: (() -> Void)? = nil
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(AppColor.surfaceDarkElevated)
                if let imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(Circle())
                } else {
                    Image(systemName: "fork.knife.circle")
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(AppColor.textPrimary)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitle)
                    .foregroundColor(AppColor.hermesOrange)
                    .font(.system(size: 14))
            }

            Spacer()

            if let onToggleFavorite {
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite == true ? "heart.fill" : "heart")
                        .foregroundColor(AppColor.hermesOrange)
                }
                .frame(width: 36, height: 36)
            }

            ZStack {
                Circle().fill(AppColor.surfaceDarkElevated)
                Image(systemName: "play.fill")
                    .foregroundColor(AppColor.hermesOrange)
                    .font(.system(size: 14))
            }
            .frame(width: 44, height: 44)
        }
        .padding(12)
        .background(AppColor.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
