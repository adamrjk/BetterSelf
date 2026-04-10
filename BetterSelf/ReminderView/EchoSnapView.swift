//
//  EchoSnapView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct EchoSnapView: View {
    @State var reminder: Reminder

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let isInFeed: Bool

    var body: some View {
        ZStack {
            if isInFeed {
                VStack(spacing: 16) {
                    photoSection
                    Spacer().frame(height: 20)
                    if !reminder.text.isEmpty { descriptionSection }
                }
                .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        photoSection
                        Spacer().frame(height: 20)
                        if !reminder.text.isEmpty { descriptionSection }
                    }
                    .padding(.horizontal)
                }
                .defaultScrollAnchor(.center)
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        if let urlString = reminder.photoURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                photoCard(image)
            } placeholder: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.cardBackground(scheme))
                    .frame(minHeight: 200)
                    .overlay(ProgressView())
            }
        }
    }

    @ViewBuilder
    private func photoCard(_ image: Image) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            image
                .resizable()
                .scaledToFit()
                .clipped()
                .cornerRadius(14)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.cardBackground(scheme))
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(reminder.text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(minWidth: 350)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.cardBackground(scheme))
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
