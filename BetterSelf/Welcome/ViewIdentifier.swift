//
//  ViewIdentifier.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

// MARK: - View Identifier Extension
extension View {
    func tutorialIdentifier(_ id: String) -> some View {
        self.accessibilityIdentifier(id)
            .trackView(id: id) // Automatically track view position
            .tutorialHighlight(id: id) // Automatically add highlight capability
    }
}

// MARK: - Tutorial Helper Functions
struct TutorialHelpers {
    
    // Helper function to create tutorial steps with click indicators
    static func createStep(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        position: TutorialStep.TutorialPosition,
        showClickIndicator: Bool = false,
        clickIndicatorPosition: TutorialStep.ClickIndicatorPosition? = nil,
        targetViewId: String? = nil
    ) -> TutorialStep {
        if showClickIndicator {
            return TutorialStep(
                id: id,
                title: title,
                message: message,
                buttonText: buttonText,
                position: position,
                targetViewId: targetViewId,
                showClickIndicator: showClickIndicator,
                clickIndicatorPosition: clickIndicatorPosition
            )
        } else {
            return TutorialStep(
                id: id,
                title: title,
                message: message,
                buttonText: buttonText,
                position: position,
                targetViewId: targetViewId
            )
        }
    }
    
    // Predefined tutorial step creators for common scenarios
    static func welcomeStep(
        title: String = "Welcome!",
        message: String = "Let's get started!",
        buttonText: String = "Let's go!"
    ) -> TutorialStep {
        return createStep(
            id: "welcome",
            title: title,
            message: message,
            buttonText: buttonText,
            position: .center
        )
    }
    
    static func clickHereStep(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        clickPosition: TutorialStep.ClickIndicatorPosition,
        targetViewId: String? = nil
    ) -> TutorialStep {
        return createStep(
            id: id,
            title: title,
            message: message,
            buttonText: buttonText,
            position: .center,
            showClickIndicator: true,
            clickIndicatorPosition: clickPosition,
            targetViewId: targetViewId
        )
    }
    
    static func topBubbleStep(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        showClickIndicator: Bool = false,
        clickPosition: TutorialStep.ClickIndicatorPosition? = nil,
        targetViewId: String? = nil
    ) -> TutorialStep {
        return createStep(
            id: id,
            title: title,
            message: message,
            buttonText: buttonText,
            position: .top,
            showClickIndicator: showClickIndicator,
            clickIndicatorPosition: clickPosition,
            targetViewId: targetViewId
        )
    }
    
    static func bottomBubbleStep(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        showClickIndicator: Bool = false,
        clickPosition: TutorialStep.ClickIndicatorPosition? = nil,
        targetViewId: String? = nil
    ) -> TutorialStep {
        return createStep(
            id: id,
            title: title,
            message: message,
            buttonText: buttonText,
            position: .bottom,
            showClickIndicator: showClickIndicator,
            clickIndicatorPosition: clickPosition,
            targetViewId: targetViewId
        )
    }
}
