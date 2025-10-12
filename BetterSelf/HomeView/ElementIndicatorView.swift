//
//  ElementIndicatorView.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import SwiftUI

struct ElementIndicatorView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @State var systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.caption)
            .foregroundStyle(color.itemColor(scheme))
            .fontWeight(.medium)
            .padding(1)
    }
}

#Preview {
    ElementIndicatorView(systemName: "text.quote")
}
