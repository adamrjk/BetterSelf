//
//  HighlightButtonStyle.swift
//  BetterSelf
//
//  Created by Adam Damou on 14/09/2025.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(
                    Rectangle()
                        .fill(Color.gray.opacity(configuration.isPressed ? 0.2 : 0))
                        .ignoresSafeArea(.all, edges: .all)
                )
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
}
