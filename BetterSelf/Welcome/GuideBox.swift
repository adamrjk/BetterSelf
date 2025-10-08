//
//  GuideBox.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

struct GuideBox: View {
    let text: String

    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    var body: some View {




        Text(text)
            .bold()
            .padding()
            .background(Color.blueGradient)
            .clipShape(.capsule)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
            )
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
            .padding(.bottom, 8)

    }
}

#Preview {
    GuideBox(text: "Click on All Reminders")
}
