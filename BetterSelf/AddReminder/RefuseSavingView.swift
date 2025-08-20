//
//  RefuseSavingView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct RefuseSavingView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.purpleMainGradient
                .ignoresSafeArea()
            Color.purpleOverlayGradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Your Reminder is empty")
                    .font(.headline)

                Text("Add a Description, a Photo, a Video or a Link to create your Reminder")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Ok"){
                    dismiss()
                }
                .buttonStyle(.plain)
                .padding()
                .buttonStyle(.borderedProminent)
                .frame(width: 100)
                .background(Color.creamyYellowGradient)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)

                )


            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    RefuseSavingView()
}
