//
//  EmptyHomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/11/2025.
//

import SwiftUI

struct EmptyHomeView: View {
    var body: some View {
        VStack {
            Text("Looks like you have no Reminders")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            CleanText("Click the plus on the top right corner to add a new Reminder")
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmptyHomeView()
}
