//
//  CleanText.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

struct CleanText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    init(_ text: String) {
        self.text = text
    }
}

#Preview {
    CleanText("Hello World!")
}
