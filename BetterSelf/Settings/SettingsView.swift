//
//  SettingsView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    var body: some View {
        ZStack {
            color.mainGradient(scheme).ignoresSafeArea()
            color.overlayGradient(scheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Image("AlternateIconSet1")
                            .resizable()
                            .frame(width: 72, height: 72)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

                        Text("BetterSelf")
                            .font(.title2.weight(.bold))

                        if let name = UserDefaults().value(forKey: "UserName") as? String, !name.isEmpty {
                            Text("Hey, \(name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 16)

                    // MARK: - Customise
                    SettingsSection(title: "Customise") {
                        NavigationLink(destination: ThemeView()) {
                            SettingsRow(
                                icon: "paintpalette.fill",
                                iconColor: .purple,
                                title: "Theme"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 56)

                        NavigationLink(destination: AppIconView()) {
                            SettingsRow(
                                icon: "app.badge.fill",
                                iconColor: color.button(scheme),
                                title: "App Icon"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: - App info
                    SettingsSection(title: "About") {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "Version",
                            value: appVersion
                        )
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(color.overlayGradient(scheme), for: .navigationBar)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Reusable components

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.cardBackground(scheme))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.body)

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ColorManager.shared)
    }
}
