//
//  RefuseSavingView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct RefuseView: View {

    @Environment(\.colorScheme) var scheme
    @Environment(\.dismiss) var dismiss

    let title: String
    let description: String
    @StateObject var color = ColorManager.shared

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text(title)
                    .font(.headline)

                Text(description)
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
                .background(color.cardBackground(scheme))
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)

                )


            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    RefuseView(title: "Your Reminder is empty", description: "Add a Description, a Photo, a Video or a Link to create your Reminder")
}
