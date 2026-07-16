//
//  OnboardingView.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//

import SwiftUI

struct OnboardingView: View {
    var onDiscover: () -> Void

    var body: some View {
        ZStack {
            AppColor.backgroundBlack.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                // TODO: Logo görselini Assets.xcassets'e ekleyip
                // Image("AppLogo") ile burada gösterebilirsin.
           
                // RoundedRectangle(cornerRadius: 48)
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                

                Text("KochRezepte")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(AppColor.hermesOrange)
                    .padding(.top, 32)

                Text("Dein digitales Kochbuch.")
                    .font(.system(size: 18))
                    .foregroundColor(AppColor.hermesOrangeLight)
                    .padding(.top, 8)

                Spacer()

                Text("Ihre Rezepte und Bilder werden nur lokal auf Ihrem Gerät gespeichert – keine Cloud-Übertragung.")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)

                Text("Die App funktioniert komplett offline.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColor.hermesOrangeLight)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                Spacer()

                Button(action: onDiscover) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Entdecken").fontWeight(.semibold)
                    }
                    .foregroundColor(AppColor.hermesOrange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColor.surfaceDarkElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 32)
        }
    }
}
