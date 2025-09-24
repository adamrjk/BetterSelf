//
//  TimeLessLetterView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct TimeLessLetterView: View {
    @Environment(\.dismiss) var dismiss



    @State var isSheet = false

    @State var reminder: Reminder
    @StateObject var color = ColorManager.shared


    @Environment(\.colorScheme) var scheme

    var body: some View {

        ZStack{
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()

            ScrollView {

                DescriptionView(text: reminder.text)

            }
            .defaultScrollAnchor(.center)
            .toolbar{
                if isSheet {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back"){
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary)
                    }

                }
            }

        }



    }
}

struct DescriptionView: View {
    let text: String
    let isYoutube: Bool
    @StateObject var color = ColorManager.shared
    @Environment(\.colorScheme) var scheme

    var body: some View{
        VStack(spacing: 16) {
            if !text.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(text)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)

                }
                .padding()
                .frame(minWidth: 350)
                .background(
                    RoundedRectangle(cornerRadius: isYoutube ? 30 : 14, style: .continuous)
                        .fill(color.cardBackground(scheme))

                )
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            }
            else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Description Yet")
                        .font(.headline)

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
        .padding(.horizontal, isYoutube ? 0 : 16)
    }
    init(text: String, isYoutube: Bool? = nil) {
        self.text = text
        self.isYoutube = isYoutube ?? false

    }
}

#Preview {
    TimeLessLetterView(reminder: .example)
}
