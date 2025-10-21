//
//  ColorManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 23/09/2025.
//

import SwiftUI


class ColorManager: ObservableObject {

    static let shared = ColorManager()

    @Published var theme: Theme


    init(){
        self.theme = .yellowPurple
    }

    init(theme: Theme){
        self.theme = theme
    }

    func changeTheme(_ theme: Theme){
        self.theme = theme
    }






    func mainGradient(_ scheme: ColorScheme) -> LinearGradient {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? Color.creamyYellowGradient
            : Color.purpleMainGradient
        case .blackWhite:
            return scheme == .light
            ? Color.whiteBackgroundGradient
            : Color.blackGradient
        }
    }

    func overlayGradient(_ scheme: ColorScheme) -> RadialGradient {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? Color.overlayCreamyYellowGradient
            : Color.purpleOverlayGradient
        case .blackWhite:
            return scheme == .light
            ? Color.whiteOverlayGradient
            : Color.blackOverlayGradient
        }
    }

    func cardBackground(_ scheme: ColorScheme) ->  LinearGradient {

        switch theme {
        case .yellowPurple:
            scheme == .light
            ? Color.whiteBackgroundGradient
            : Color.systemGrayGradient
        case .blackWhite:
            scheme == .light
            ? Color.systemGrayGradient
            : Color.blackGradient

        }

    }

    func itemColor(_ scheme: ColorScheme) -> LinearGradient {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? Color.darkPurpleMainGradient
            : Color.creamyYellowGradient
        case .blackWhite:
            return scheme == .light
            ? Color.blackGradient
            : Color.creamyYellowGradient
        }
    }

    func itemShadow(_ scheme: ColorScheme) -> Color {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? .darkPurple
            : .creamyYellow
        case .blackWhite:
            return scheme == .light
            ? .gray.opacity(0.25)
            : .white.opacity(0.3)
        }
    }

    func buttonGradient(_ scheme: ColorScheme) -> LinearGradient {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? Color.blackGradient
            : Color.creamyYellowGradient
        case .blackWhite:
            return scheme == .light
            ? Color.grayButtonGradient          // Custom for blackWhite theme
            : Color.whiteButtonGradient         // Custom for blackWhite theme
        }
    }

    func shadow(_ scheme: ColorScheme) -> Color {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? .black
            : .purple
        case .blackWhite:
            return scheme == .light
            ? .black
            : .white
        }
    }

    func button(_ scheme: ColorScheme) -> Color {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? .black
            : .creamyYellow
        case .blackWhite:
            return scheme == .light
            ? .black
            : .white
        }
    }

    func text(_ scheme: ColorScheme) -> Color {
        switch theme {
        case .yellowPurple:
            return scheme == .light
            ? .white
            : .black
        case .blackWhite:
            return scheme == .light
            ? .white
            : .black
        }
    }
}
