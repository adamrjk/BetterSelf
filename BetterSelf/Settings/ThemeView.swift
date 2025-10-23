//
//  ThemeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI

//
//  ThemeView.swift
//  BetterSelf
//
//  Created by GPT-5 on 20/10/2025.
//


// MARK: - ThemeMode Addition

enum ThemeMode: String, CaseIterable, Identifiable {
case auto
case light
case dark

var id: String { self.rawValue }

var label: String {
    switch self {
    case .auto: return "Sync Theme"
    case .light: return "Light Mode"
    case .dark: return "Dark Mode"
    }
}

var preferred: ColorScheme? {
    switch self {
    case .auto:
            nil
    case .light:
            .light
    case .dark:
            .dark
    }
}
}

struct ThemeView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject private var color: ColorManager

    // Store mode as string for persistence
    @AppStorage("theme.mode") private var selectedThemeModeRaw: String = ThemeMode.auto.rawValue
    @AppStorage("theme.selection") private var selectedThemeKey: String = Theme.yellowPurple.rawValue

    // For Picker binding
    private var selectedThemeMode: ThemeMode {
        get { ThemeMode(rawValue: selectedThemeModeRaw) ?? .auto }
        set { selectedThemeModeRaw = newValue.rawValue }
    }

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mode Picker row (replacing Auto Dark Mode toggle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Appearance")
                            .font(.headline)
                        Picker(selection: Binding(
                            get: { selectedThemeMode },
                            set: { newValue in selectedThemeModeRaw = newValue.rawValue }
                        )) {
                            ForEach(ThemeMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        } label: {}
                            .pickerStyle(.segmented)
                            .padding(.vertical, 2)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Spacer(minLength: 30)

                    //                // Section title for selecting a theme, visually separated from Picker
                    //                Text("Select a Theme")
                    //                    .font(.title3.weight(.bold))
                    //                    .foregroundStyle(Color.primary)
                    //                    .padding(.top, 16)
                    //                    .padding(.bottom, 4)


                    // Theme cards (stacked)
                    VStack(alignment: .leading, spacing: 14) {
                        themeCard(option: .yellowPurple, isSelected: currentTheme == .yellowPurple, mode: selectedThemeMode)
                        themeCard(option: .blackWhite, isSelected: currentTheme == .blackWhite, mode: selectedThemeMode)
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
        }
        .navigationTitle("Theme")
        .toolbarBackground(color.overlayGradient(effectiveScheme), for: .navigationBar)
        .onChange(of: selectedThemeMode){
            AppearanceController.shared.apply(selectedThemeMode)
            UserDefaults.standard.set(selectedThemeMode.rawValue, forKey: "ThemeMode")
        }
        .onChange(of: selectedThemeKey){
            color.changeTheme(currentTheme)
            UserDefaults.standard.set(selectedThemeKey, forKey: "Theme")
        }
    }

    private var currentTheme: Theme {
        Theme(rawValue: selectedThemeKey) ?? .yellowPurple
    }

    // Compute the effective scheme to use in the UI given user selection
    private var effectiveScheme: ColorScheme {
        switch selectedThemeMode {
        case .auto:
            return scheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    private var backgroundForCurrentSelection: some View {
        Group {
            switch effectiveScheme {
            case .light:
                Color.whiteBackgroundGradient
            case .dark:
                if currentTheme == .yellowPurple { Color.purpleMainGradient } else { Color.blackGradient }
            @unknown default:
                Color.whiteBackgroundGradient
            }
        }
        .ignoresSafeArea()
    }

    // Todoist-style theme card
    @ViewBuilder
    private func themeCard(option: Theme, isSelected: Bool, mode: ThemeMode) -> some View {
        Button {
            selectedThemeKey = option.rawValue
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(option.displayName)
                        .font(.title3.weight(.semibold))
//                        .foregroundStyle(option.titleColor)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(color.itemColor(scheme))
                    }
                }
                // Mini preview area
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(option.cardBackground(scheme, mode))
                    HStack(spacing: 12) {
                        Circle()
                            .fill(option.accentFill(scheme, selectedThemeMode))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(option.lineColor)
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(option.lineColor.opacity(0.7))
                                .frame(height: 8)
                                .frame(maxWidth: 180)
                        }
                        Spacer()
                    }
                    .padding(14)
                }
                .frame(height: 72)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func previewTextColor(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .light: return .black
        case .dark: return .white
        @unknown default: return .primary
        }
    }

    private func previewCardBackground(for scheme: ColorScheme) -> some View {
        Group {
            if scheme == .light {
                Color.whiteCardGradient
            } else {
                Color.tabViewGradient
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func previewButton(title: String, scheme: ColorScheme) -> some View {
        Button(action: {}) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color.text(scheme))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(color.buttonGradient(scheme))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func previewBorderButton(title: String, scheme: ColorScheme) -> some View {
        Button(action: {}) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(previewTextColor(for: scheme))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(previewTextColor(for: scheme).opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

enum Theme: String {
    case yellowPurple = "yellowPurple"
    case blackWhite = "blackWhite"


    var displayName: String {
        switch self {
        case .yellowPurple: return "Yellow & Purple"
        case .blackWhite: return "Black & White"
        }
    }

    // Styling for the Todoist-like cards
    var titleColor: Color {
        switch self {
        case .yellowPurple: return .purple
        case .blackWhite: return .red
        }
    }

    fileprivate func cardBackground(_ scheme: ColorScheme, _ mode: ThemeMode) ->  LinearGradient {
        let yellowColorManager = ColorManager()
        let whiteColorManager = ColorManager(theme: .blackWhite)

        switch self {
        case .yellowPurple:
            switch mode {
            case .auto:
                return yellowColorManager.mainGradient(scheme)
            case .light:
                return Color.creamyYellowGradient
            case .dark:
                return Color.purpleMainGradient
            }

        case .blackWhite:
            switch mode {
            case .auto:
                return whiteColorManager.cardBackground(scheme)
            case .light:
                return Color.systemGrayGradient
            case .dark:
                return Color.blackGradient
            }

        }
    }

    var lineColor: Color {
        switch self {
        case .yellowPurple: return Color.gray.opacity(0.35)
        case .blackWhite: return Color.white.opacity(0.65)
        }
    }

    fileprivate func accentFill(_ scheme: ColorScheme, _ mode: ThemeMode ) -> LinearGradient {
        switch self {
        case .yellowPurple:
            switch mode {
            case .auto:
                return scheme == .light
                ? Color.purpleMainGradient
                : Color.creamyYellowGradient
            case .light:
                return Color.purpleMainGradient
            case .dark:
                return Color.creamyYellowGradient
            }


        case .blackWhite:
            switch mode {
            case .auto:
                return scheme == .light
                ? Color.blackGradient
                : LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
            case .light:
                return Color.blackGradient
            case .dark:
                return LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
            }
        }
    }
}

#Preview {
    ThemeView()
        .environmentObject(ColorManager.shared)
}
