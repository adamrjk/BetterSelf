//
//  ColorManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 23/09/2025.
//

import SwiftUI


class ColorManager: ObservableObject {

    static let shared = ColorManager()

    func mainGradient(_ scheme: ColorScheme) ->  LinearGradient {
        scheme == .light
        ? Color.creamyYellowGradient
        : Color.purpleMainGradient
    }

    func overlayGradient(_ scheme: ColorScheme) -> RadialGradient {
        scheme == .light
        ? Color.overlayCreamyYellowGradient
        : Color.purpleOverlayGradient

    }
    func itemColor(_ scheme: ColorScheme) -> LinearGradient {
        scheme == .light
        ? Color.purpleMainGradient
        : Color.creamyYellowGradient
    }


    func cardBackground(_ scheme: ColorScheme) ->  LinearGradient {
         LinearGradient(
            colors: [
                scheme == .light ? Color("CreamyYellow1") : Color(.systemGray6),
                scheme == .light ? Color("CreamyYellow2")  : Color(.systemGray6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

}
