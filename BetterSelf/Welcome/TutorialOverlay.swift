//
//  TutorialOverlay.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

struct TutorialOverlay: View {

    @ObservedObject private var tutorialManager = TutorialManager.shared
    @Environment(\.colorScheme) var scheme


    var body: some View {
        ZStack {
        if tutorialManager.isActive && tutorialManager.shouldRender, 
           let currentStep = tutorialManager.currentStep,
           !currentStep.isInvisible {
            ZStack {
                // Only show dimming for NON-click steps AND when not expecting action
                if !currentStep.showClickIndicator && !currentStep.expectsAction {
                    // Regular dimmed background for normal tutorial steps
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                // For click indicator steps or action-expected steps: NO dimming - view stays at full opacity
                
                // Click indicator (if enabled)
                if currentStep.showClickIndicator {
                    ClickIndicator(position: currentStep.clickIndicatorPosition, targetViewId: currentStep.targetViewId)
                        .allowsHitTesting(false)
                }
                
                // Tutorial bubble positioned based on step (INTERACTIVE)
                GeometryReader { geometry in
                    let bubblePosition = calculateBubblePosition(for: currentStep.position, in: geometry, currentStep: currentStep)
                    
                    TutorialBubble(
                        step: currentStep,
                        onNext: tutorialManager.nextStep,
                        onPrevious: tutorialManager.previousStep,
                        onSkip: tutorialManager.tutorialIsDone,
                        isFirstStep: tutorialManager.currentStepIndex == 0,
                        isLastStep: tutorialManager.currentStepIndex == tutorialManager.steps.count - 1
                    )
                    .position(x: bubblePosition.x, y: bubblePosition.y)
                }
                // Tutorial bubble is INTERACTIVE - no allowsHitTesting(false) here
                
                // Progress indicator (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(tutorialManager.currentStepIndex + 1) of \(tutorialManager.steps.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.6))
                            .clipShape(Capsule())
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                    }
                }
                .allowsHitTesting(false)
            }
            .transition(.opacity)
        }
        }
        .onChange(of: TutorialManager.shared.currentViewId){
            TutorialManager.shared.check()
        }
        .sheet(isPresented: $tutorialManager.showHelperSheet) {
            SharingTutorial()
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Position Calculation
    private func calculateBubblePosition(for position: TutorialStep.TutorialPosition, in geometry: GeometryProxy, currentStep: TutorialStep) -> CGPoint {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let safeAreaTop = geometry.safeAreaInsets.top
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        
        // Calculate available height (excluding safe areas)
        let availableHeight = screenHeight - safeAreaTop - safeAreaBottom
        let availableTop = safeAreaTop
        
        // Define position percentages relative to screen size
        let horizontalCenter = screenWidth / 2
        let verticalCenter = availableTop + (availableHeight / 2)
        
        switch position {
            // Top positions
        case .topHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.1))
        case .top:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.2))
        case .topMiddle:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.3))
        case .topLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.4))
            
            // Middle positions
        case .middleHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.4))
        case .center:
            return CGPoint(x: horizontalCenter, y: verticalCenter)
        case .middleLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.6))
            
            // Bottom positions
        case .bottomHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.6))
        case .bottomMiddle:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.7))
        case .bottomLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.8))
        case .bottom:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.9))
            
            // Corner positions
        case .topLeft:
            return CGPoint(x: screenWidth * 0.25, y: availableTop + (availableHeight * 0.2))
        case .topRight:
            return CGPoint(x: screenWidth * 0.75, y: availableTop + (availableHeight * 0.2))
        case .centerLeft:
            return CGPoint(x: screenWidth * 0.25, y: verticalCenter)
        case .centerRight:
            return CGPoint(x: screenWidth * 0.75, y: verticalCenter)
        case .bottomLeft:
            return CGPoint(x: screenWidth * 0.25, y: availableTop + (availableHeight * 0.8))
        case .bottomRight:
            return CGPoint(x: screenWidth * 0.75, y: availableTop + (availableHeight * 0.8))
            
            // Custom position
        case .custom(let x, let y):
            return CGPoint(x: x, y: y)
            
        }
    }
}

// MARK: - Manual Tutorial Overlay (ignores shouldRender flag, used in sheets)
struct ManualTutorialOverlay: View {
    @ObservedObject private var tutorialManager = TutorialManager.shared
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
        if tutorialManager.isActive, 
           let currentStep = tutorialManager.currentStep,
           !currentStep.isInvisible {
            ZStack {
                // Only show dimming for NON-click steps AND when not expecting action
                if !currentStep.showClickIndicator && !currentStep.expectsAction {
                    // Regular dimmed background for normal tutorial steps
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                // For click indicator steps or action-expected steps: NO dimming - view stays at full opacity
                
                // Click indicator (if enabled)
                if currentStep.showClickIndicator {
                    ClickIndicator(position: currentStep.clickIndicatorPosition, targetViewId: currentStep.targetViewId)
                        .allowsHitTesting(false)
                }
                
                // Tutorial bubble positioned based on step (INTERACTIVE)
                GeometryReader { geometry in
                    let bubblePosition = calculateBubblePosition(for: currentStep.position, in: geometry, currentStep: currentStep)
                    
                    TutorialBubble(
                        step: currentStep,
                        onNext: tutorialManager.nextStep,
                        onPrevious: tutorialManager.previousStep,
                        onSkip: tutorialManager.tutorialIsDone,
                        isFirstStep: tutorialManager.currentStepIndex == 0,
                        isLastStep: tutorialManager.currentStepIndex == tutorialManager.steps.count - 1
                    )
                    .position(x: bubblePosition.x, y: bubblePosition.y)
                }
                // Tutorial bubble is INTERACTIVE - no allowsHitTesting(false) here
                
                // Progress indicator (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(tutorialManager.currentStepIndex + 1) of \(tutorialManager.steps.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.6))
                            .clipShape(Capsule())
                            .padding(.bottom, 20)
                            .padding(.trailing, 20)
                    }
                }
                .allowsHitTesting(false)
            }
            .transition(.opacity)
        }
        }
        .onChange(of: TutorialManager.shared.currentViewId){
            TutorialManager.shared.check()
        }
        .sheet(isPresented: $tutorialManager.showHelperSheet) {
            Text("Helper content will go here")
                .padding()
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Position Calculation
    private func calculateBubblePosition(for position: TutorialStep.TutorialPosition, in geometry: GeometryProxy, currentStep: TutorialStep) -> CGPoint {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let safeAreaTop = geometry.safeAreaInsets.top
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        
        // Calculate available height (excluding safe areas)
        let availableHeight = screenHeight - safeAreaTop - safeAreaBottom
        let availableTop = safeAreaTop
        
        // Define position percentages relative to screen size
        let horizontalCenter = screenWidth / 2
        let verticalCenter = availableTop + (availableHeight / 2)
        
        switch position {
            // Top positions
        case .topHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.1))
        case .top:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.2))
        case .topMiddle:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.3))
        case .topLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.4))
            
            // Middle positions
        case .middleHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.4))
        case .center:
            return CGPoint(x: horizontalCenter, y: verticalCenter)
        case .middleLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.6))
            
            // Bottom positions
        case .bottomHigh:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.6))
        case .bottomMiddle:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.7))
        case .bottomLow:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.8))
        case .bottom:
            return CGPoint(x: horizontalCenter, y: availableTop + (availableHeight * 0.9))
            
            // Corner positions
        case .topLeft:
            return CGPoint(x: screenWidth * 0.25, y: availableTop + (availableHeight * 0.2))
        case .topRight:
            return CGPoint(x: screenWidth * 0.75, y: availableTop + (availableHeight * 0.2))
        case .centerLeft:
            return CGPoint(x: screenWidth * 0.25, y: verticalCenter)
        case .centerRight:
            return CGPoint(x: screenWidth * 0.75, y: verticalCenter)
        case .bottomLeft:
            return CGPoint(x: screenWidth * 0.25, y: availableTop + (availableHeight * 0.8))
        case .bottomRight:
            return CGPoint(x: screenWidth * 0.75, y: availableTop + (availableHeight * 0.8))
            
            // Custom position
        case .custom(let x, let y):
            return CGPoint(x: x, y: y)
            
        }
    }
}

//#Preview {
//    TutorialOverlay()
//}
