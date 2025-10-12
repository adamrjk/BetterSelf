//
//  TutorialBubble.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

struct TutorialBubble: View {
    let step: TutorialStep
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onSkip: () -> Void
    let isFirstStep: Bool
    let isLastStep: Bool
    
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top arrow (pointing down)
            if shouldShowTopArrow {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.title2)
                    .foregroundColor(bubbleColor)
                    .offset(y: 5)
            }
            
            // Main bubble
            VStack(spacing: 16) {
                // Title
                Text(step.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(step.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Helper Button (if available)
                if let helperButtonText = step.helperButtonText {
                    Button(helperButtonText) {
                        TutorialManager.shared.showHelperSheet = true
                        TutorialManager.shared.tutorialIsDone()
                    }
                    .font(.caption)
                    .foregroundColor(bubbleColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(bubbleColor.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(bubbleColor.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Buttons
                HStack(spacing: 12) {
                    if !isFirstStep {
                        Button("Previous") {
                            onPrevious()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Button("Skip") {
                        onSkip()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    
                    // Only show Next button if it's NOT a click indicator step and hideNextButton is false
                    if !step.showClickIndicator && !step.hideNextButton {
                        Button(step.buttonText) {
                            onNext()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(bubbleColor)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(bubbleColor.opacity(0.3), lineWidth: 1)
            )
            
            // Bottom arrow (pointing up)
            if shouldShowBottomArrow {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.title2)
                    .foregroundColor(bubbleColor)
                    .offset(y: -5)
            }
        }
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
    
    private var bubbleColor: Color {
        scheme == .light ? .darkPurple : .yellow
    }
    
    // MARK: - Arrow Logic
    private var shouldShowTopArrow: Bool {
        switch step.position {
        case .topHigh, .top, .topMiddle, .topLow, .topLeft, .topRight:
            return true
        default:
            return false
        }
    }
    
    private var shouldShowBottomArrow: Bool {
        switch step.position {
        case .bottomHigh, .bottomMiddle, .bottomLow, .bottom, .bottomLeft, .bottomRight:
            return true
        default:
            return false
        }
    }
}
