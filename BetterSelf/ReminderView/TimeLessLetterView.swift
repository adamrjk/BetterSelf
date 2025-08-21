//
//  TimeLessLetterView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct TimeLessLetterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var calendarCardText: Color {
        colorScheme == .light
        ? .purple.opacity(0.7)
        : .creamyYellow
    }

    @State var isSheet = false

    @State var reminder: Reminder
    var body: some View {

        ZStack{
            Color.purpleMainGradient
                .ignoresSafeArea()
            Color.purpleOverlayGradient
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 16) {
                    if !reminder.text.isEmpty {
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
                                .fill(Color.cardBackground)

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
                                .fill(Color.cardBackground)

                        )
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    }


                }
                .padding(.horizontal)

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

                    ToolbarItem(placement: .bottomBar){
                        // Date indicator at bottom right
                        HStack {
                            Spacer()

                            HStack {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundStyle(calendarCardText)

                                Text(reminder.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(calendarCardText)

                            }
                            .padding(3)
                            .background(Color.cardBackground)
                            .clipShape(.capsule)
                        }

                    }
                }
            }

        }



    }
}

#Preview {
    TimeLessLetterView(reminder: .example)
}
