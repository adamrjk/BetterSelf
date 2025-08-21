//
//  RefuseLoadingView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct RefuseLoadingView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.purpleMainGradient
                .ignoresSafeArea()
            Color.purpleOverlayGradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("You cannot access this Reminder yet")
                    .font(.headline)

                Text("The Video is still loading, wait a few seconds. Wait for the camera icon to appear")
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
    RefuseLoadingView()
}
