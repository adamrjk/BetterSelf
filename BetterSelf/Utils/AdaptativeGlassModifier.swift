//
//  AdaptativeGlassModifier.swift
//  BetterSelf
//
//  Created by Adam Damou on 25/09/2025.
//

import SwiftUI




struct AdaptiveGlassModifier: ViewModifier {
    @EnvironmentObject var color: ColorManager
    let scheme: ColorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .padding()
                .clipShape(.capsule)
                .glassEffect(.regular, in: .buttonBorder)

        } else {
            content
                .padding()
                .background(.regularMaterial)
                .clipShape(.capsule)


        }
    }
}

extension View {
    func adaptiveGlass(_ scheme: ColorScheme) -> some View {
        self.modifier(AdaptiveGlassModifier(scheme: scheme))
    }
}




struct AdaptiveTranslucentModifier: ViewModifier {
    @EnvironmentObject var color: ColorManager
//    let scheme: ColorScheme
    let background: Color

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.tint(background.opacity(0.9)).interactive())
        } else {
            content
                .background(background)
        }
    }
}

extension View {
    func adaptiveTranslucent(_ a: Color) -> some View {
        self.modifier(AdaptiveTranslucentModifier(background: a))
    }
}
