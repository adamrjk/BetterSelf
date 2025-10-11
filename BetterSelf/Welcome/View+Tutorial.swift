//
//  View+Tutorial.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

extension View {
    func tutorialOverlay() -> some View {
        self.overlay(
            TutorialOverlay()
                .ignoresSafeArea()

        )
    }
    
    func tutorialClickable(id: String) -> some View {
        self.onTapGesture {
            TutorialManager.shared.handleTargetViewClick(target: id)
        }
    }
}
