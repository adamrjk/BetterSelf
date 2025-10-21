//
//  AppIconView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI

struct AppIconView: View {
    let appIcons = [
        ("BetterSelf", "AlternateIconSet1"),
        ("Dark", "AlternateIconSet2")
    ]

    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared

    @State private var currentAppIcon = ""

    var body: some View {

        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()

            ScrollView {
                ForEach(appIcons, id: \.1) { appIcon in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentAppIcon = appIcon.1
                            changeAppIcon(to: appIcon.1)
                        }
                    } label: {
                        HStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(currentAppIcon == appIcon.1 ? Color.white.opacity(0.14) : Color.white.opacity(0.08))
                                    .frame(width: 72, height: 72)
                                    .shadow(radius: currentAppIcon == appIcon.1 ? 12 : 6, y: 2)
                                Image(appIcon.1)
                                    .resizable()
                                    .cornerRadius(16)
                                    .frame(width: 56, height: 56)
                                    .scaledToFit()
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(appIcon.0)
                                    .font(.title3.weight(.semibold))
                            }

                            Spacer()

                            if currentAppIcon == appIcon.1 {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(Color.green)
                                    .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(color.cardBackground(scheme))
                        )
                        .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                        .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Spacer()

            }
            .defaultScrollAnchor(.center)
        }
        .onAppear {
            if let icon = UserDefaults.standard.value(forKey: "CurrentAppIcon") as? String {
                currentAppIcon = icon
            } else {
                currentAppIcon = "AlternateIconSet1"
            }
        }
        .onChange(of: currentAppIcon) {
            UserDefaults.standard.setValue(currentAppIcon, forKey: "CurrentAppIcon")
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }

    func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternate icons are not supported.")
            return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change app icon: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AppIconView()
}
