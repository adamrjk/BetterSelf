//
//  AddingDescriptionView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftUI



struct AddingDescriptionView: View {

    @Binding var text: String
    @FocusState.Binding var keyboard: Bool


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CleanText("Description")
                .foregroundColor(.primary)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.whiteFieldGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )

                TextEditor(text: $text)

                    .toolbar{
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done"){
                                keyboard = false
                            }
                        }
                    }
                    .focused($keyboard)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .padding(12)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.creamyYellowGradient)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .padding(.horizontal, 16)

    }
}

#Preview {
    AddingDescriptionView(text: .constant("abc"), keyboard: FocusState<Bool>().projectedValue)
}
