//
//  FloatingPlusButton.swift
//  BetterSelf
//
//  Created by AI Assistant on 19/11/2025.
//

import SwiftUI

struct FloatingPlusButton: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var color: ColorManager

    let shouldAppear: Bool
    let action: () -> Void

    var body: some View {
        if shouldAppear {
            VStack {
                Spacer()
                HStack {
                    Spacer()


                    Button(action: action) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(scheme == .light ? .white : .black)
                            .padding(20)
                    }
                    .tutorialIdentifier("PlusButton")
                    .adaptiveTranslucent(color.plusButton(scheme))
                    .clipShape(.circle)




                }
                .padding(.trailing, 10)
            }
        }
    }
}

extension View {
    func floatingPlusButton(_ shouldAppear: Bool, action: @escaping () -> Void) -> some View {
        overlay(
            FloatingPlusButton(shouldAppear: shouldAppear, action: action)
        )
    }
}


