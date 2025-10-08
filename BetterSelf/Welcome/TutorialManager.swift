//
//  TutorialManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

// MARK: - Tutorial Step Model
struct TutorialStep {
    let id: String
    let title: String
    let message: String
    let buttonText: String
    let position: TutorialPosition
    let targetViewId: String? // Optional: to highlight specific views
    let showClickIndicator: Bool // Whether to show animated click indicator
    let clickIndicatorPosition: ClickIndicatorPosition? // Position of the click indicator
    let expectsAction: Bool // If true, keeps background at full brightness for user actions



    // MARK: - Initializers
    
    // Basic initializer without click indicator
    init(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        position: TutorialPosition,
        targetViewId: String? = nil,
        expectsAction: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.position = position
        self.targetViewId = targetViewId
        self.showClickIndicator = false
        self.clickIndicatorPosition = nil
        self.expectsAction = expectsAction
    }
    
    // Full initializer with click indicator
    init(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        position: TutorialPosition,
        targetViewId: String? = nil,
        showClickIndicator: Bool,
        clickIndicatorPosition: ClickIndicatorPosition? = nil,
        expectsAction: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.position = position
        self.targetViewId = targetViewId
        self.showClickIndicator = showClickIndicator
        self.clickIndicatorPosition = clickIndicatorPosition
        self.expectsAction = expectsAction
    }
    
    /// Tutorial bubble positioning options that are relative to device screen size
    /// All positions automatically adapt to different device sizes and safe areas
    enum TutorialPosition {
        // Top positions (10% to 40% from top of safe area)
        case topHigh          // 10% from top - closest to top edge
        case top              // 20% from top - standard top position
        case topMiddle        // 30% from top - between top and center
        case topLow           // 40% from top - closer to center
        
        // Middle positions (40% to 60% from top of safe area)
        case middleHigh       // 40% from top - higher than center
        case center           // 50% from top - exact center
        case middleLow        // 60% from top - lower than center
        
        // Bottom positions (60% to 90% from top of safe area)
        case bottomHigh       // 60% from top - closer to center
        case bottomMiddle     // 70% from top - between center and bottom
        case bottomLow        // 80% from top - closer to bottom
        case bottom           // 90% from top - standard bottom position
        
        // Corner positions (combines horizontal and vertical positioning)
        case topLeft          // Top-left corner (25% width, 20% height)
        case topRight         // Top-right corner (75% width, 20% height)
        case centerLeft       // Center-left (25% width, 50% height)
        case centerRight      // Center-right (75% width, 50% height)
        case bottomLeft       // Bottom-left corner (25% width, 80% height)
        case bottomRight      // Bottom-right corner (75% width, 80% height)
        
        // Custom position (absolute coordinates)
        case custom(x: CGFloat, y: CGFloat)
    }
    
    enum ClickIndicatorPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center
        case custom(x: CGFloat, y: CGFloat)
    }
}

// MARK: - Tutorial Manager
class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    
    @Published var isActive = false
    @Published var shouldRender = true // Controls whether tutorial renders as a view
    @Published var currentStepIndex = 0
    @Published var steps: [TutorialStep] = []

    @Published var homeViewStep = 0


    private init() {}
    
    func startTutorial(_ tutorialSteps: [TutorialStep]) {
        self.steps = tutorialSteps
        self.currentStepIndex = 0
        self.isActive = true
        self.shouldRender = true
    }
    
    // Returns the tutorial view itself for manual overlay
    func tutorialView() -> some View {
        ManualTutorialOverlay()
    }
    
    // Initialize tutorial for sheet but don't render it automatically
    func startTutorialForSheet(_ tutorialSteps: [TutorialStep]) {
        self.steps = tutorialSteps
        self.currentStepIndex = 0
        self.isActive = true // Tutorial is active and running
        self.shouldRender = false // But don't render as a view
    }
    
    // Manually show/hide the tutorial
    func showTutorial() {
        self.isActive = true
    }
    
    func hideTutorial() {
        self.isActive = false
    }
    
    func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            endTutorial()
        }
    }
    
    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    func endTutorial() {
        isActive = false
        currentStepIndex = 0
        steps = []
    }
    
    // Static method for views to call when they're clicked
    static func notifyViewClicked(viewId: String) {
        shared.handleTargetViewClick(viewId: viewId)
    }
    
    func handleTargetViewClick(viewId: String) {
        // Check if current step is a click indicator step and matches the clicked view
        guard let currentStep = currentStep,
              currentStep.showClickIndicator,
              currentStep.targetViewId == viewId else {
            return
        }
        
        // Auto-advance to next step
        nextStep()
    }
    
    
    var currentStep: TutorialStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(steps.count)
    }
}
