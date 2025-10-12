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

    @EnvironmentObject var color: ColorManager

    @Environment(\.colorScheme) var scheme


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
                    .focused($keyboard)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .frame(maxHeight: .infinity)
                    .padding(12)
                    .foregroundStyle(.primary)
                    .background(
                           RoundedRectangle(cornerRadius: 12)
                               .fill(Color(.systemGray6)) // Automatically adapts
                               .shadow(color: .primary.opacity(0.06), radius: 2, y: 1)
                       )
                       .overlay(
                           RoundedRectangle(cornerRadius: 12)
                               .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                       )
                    .scrollContentBackground(.hidden)
            }

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.cardBackground(scheme))
        )
        .padding(.horizontal, 16)

    }
}

#Preview {
    AddingDescriptionView(text: .constant("abc"), keyboard: FocusState<Bool>().projectedValue)
}
