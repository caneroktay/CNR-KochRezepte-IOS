//
//  BottomNavBar.swift
//  KochRezepte
//
//  Created by Caner Oktay on 16.07.26.
//
import SwiftUI

struct BottomNavBar: View {
    @EnvironmentObject var router: Router

    var body: some View {
        HStack(spacing: -4) {
            tabButton(.home, systemImage: "house.fill")
            tabButton(.recipes, systemImage: "fork.knife")
            tabButton(.categories, systemImage: "list.bullet")
            tabButton(.settings, systemImage: "gearshape.fill")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Capsule().fill(AppColor.surfaceDarkElevated.opacity(0.75)))
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab, systemImage: String) -> some View {
        let isSelected = router.selectedTab == tab
        Button {
            router.selectTab(tab)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 28))
                .foregroundColor(isSelected ? AppColor.textOnOrange : AppColor.textSecondary)
                .frame(width: 50, height: 50)
                .background(Circle().fill(isSelected ? AppColor.hermesOrange : Color.clear))
        }
        .frame(maxWidth: .infinity)
    }
}
