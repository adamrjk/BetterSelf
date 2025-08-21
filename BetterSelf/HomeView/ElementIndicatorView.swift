//
//  ElementIndicatorView.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import SwiftUI

struct ElementIndicatorView: View {
    @Environment(\.colorScheme) var colorScheme

    var itemColor: LinearGradient {
                colorScheme == .light
        ? Color.purpleMainGradient
        : Color.creamyYellowGradient
    }


    @State var systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.caption)
            .foregroundStyle(itemColor)
            .fontWeight(.medium)
            .padding(1)
    }
}

#Preview {
    ElementIndicatorView(systemName: "text.quote")
}
