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
    var body: some View {

        ZStack{
            Color.purpleMainGradient
                .ignoresSafeArea()
            Color.purpleOverlayGradient
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
    @Environment(\.colorScheme) var colorScheme
    var newCardBackground: LinearGradient {
         LinearGradient(
            colors: [
                colorScheme == .light ? Color("CreamyYellow1") : Color(.systemGray6),
                colorScheme == .light ? Color("CreamyYellow2")  : Color(.systemGray6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
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
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(newCardBackground)

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
                        .fill(newCardBackground)

                )
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            }


        }
        .padding(.horizontal)
    }
}

#Preview {
    TimeLessLetterView(reminder: .example)
}
