//
//  AdaptativeGlassModifier.swift
//  BetterSelf
//
//  Created by Adam Damou on 25/09/2025.
//

import SwiftUI

struct AdaptiveGlassModifier: ViewModifier {
    @StateObject var color = ColorManager.shared
    let scheme: ColorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .buttonBorder)
        } else {
            content
                .padding()
                .background(color.cardBackground(scheme))
                .clipShape(.capsule)
        }
    }
}

extension View {
    func adaptiveGlass(_ scheme: ColorScheme) -> some View {
        self.modifier(AdaptiveGlassModifier(scheme: scheme))
    }
}
//#Preview {
//    AdaptativeGlassModifier()
//}


struct ToolBarButtonModifier: ViewModifier{
    @StateObject var color = ColorManager.shared
    let scheme: ColorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content

        } else {
            content
//                .padding()
                .background(color.itemColor(scheme))
//                .clipShape(.capsule)
                .buttonStyle(.plain)
        }
    }

}
extension View {
    func toolbarButton(_ scheme: ColorScheme) -> some View {
        self.modifier(ToolBarButtonModifier(scheme: scheme))
    }
}
