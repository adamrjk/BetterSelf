//
//  ElementIndicatorView.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import SwiftUI

struct ElementIndicatorView: View {
    @State var systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.caption)
            .foregroundColor(.purple.opacity(0.5))
            .fontWeight(.medium)
            .padding(1)
    }
}

#Preview {
    ElementIndicatorView(systemName: "text.quote")
}
