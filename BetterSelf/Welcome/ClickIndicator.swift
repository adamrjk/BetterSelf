//
//  ClickIndicator.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

struct ClickIndicator: View {
    let position: TutorialStep.ClickIndicatorPosition?
    let targetViewId: String?
    
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    @StateObject private var viewFinder = ViewFinder.shared
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var arrowOffset: CGFloat = 0
    @State private var indicatorPosition: CGPoint = .zero
    @State private var indicatorDirection: ClickIndicatorDirection = .down
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pulsing circle background
                Circle()
                    .fill(indicatorColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseScale)
                    .opacity(isAnimating ? 0.3 : 0.1)
                
                // Main click indicator
                VStack(spacing: 8) {
                    // Hand pointing in the right direction
                    Image(systemName: handIcon)
                        .font(.title)
                        .foregroundColor(indicatorColor)
                        .offset(x: 0, y: arrowOffset)
                        .rotationEffect(rotationAngle)
                    
                    // "Tap here" text
                    Text("Tap here")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(indicatorColor)
                        )
                }
            }
            .position(indicatorPosition)
            .onAppear {
                if targetViewId == "SaveRemindersButton"{
                    startAnimations()
                }
                else {
                    updatePosition(in: geometry)
                    startAnimations()
                }

            }
            .onChange(of: geometry.size) {
                if targetViewId != "SaveRemindersButton"{
                    updatePosition(in: geometry)
                }
            }
            .onReceive(viewFinder.$viewPositions) { _ in
                if targetViewId != "SaveRemindersButton"{
                    updatePosition(in: geometry)
                }
            }
        }
    }
    
    private var indicatorColor: Color {
        scheme == .light ? .blue : .yellow
    }
    
    private var handIcon: String {
        switch indicatorDirection {
        case .up: return "hand.point.up.fill"
        case .down: return "hand.point.down.fill"
        case .left: return "hand.point.left.fill"
        case .right: return "hand.point.right.fill"
        }
    }
    
    private var rotationAngle: Angle {
        switch indicatorDirection {
        case .up: return .degrees(0)
        case .down: return .degrees(0)
        case .left: return .degrees(0)
        case .right: return .degrees(0)
        }
    }
    
    private func updatePosition(in geometry: GeometryProxy) {
        if let targetId = targetViewId {
            // Special handling for SaveReminderButton - use same reliable positioning as tutorial bubbles
            if targetId == "SaveReminderButton" {
                // Use the same coordinate system that works for tutorial bubbles
                let safeAreaTop = geometry.safeAreaInsets.top
                let availableHeight = geometry.size.height - safeAreaTop - geometry.safeAreaInsets.bottom
//                let horizontalCenter = geometry.size.width / 2
                
                // Position at toolbar level (same as .highest tutorial position)
                let x = geometry.size.width - 20 - 25 // Right margin + half button width
                let y = safeAreaTop + (availableHeight * 0.05) // Same as .highest position
                
                indicatorPosition = CGPoint(x: x, y: y)
                indicatorDirection = .down
            } else if targetId == "CameraIconButton" {
                // Special handling for CameraIconButton - it's in the center of screen in a card
                let safeAreaTop = geometry.safeAreaInsets.top
                let availableHeight = geometry.size.height - safeAreaTop - geometry.safeAreaInsets.bottom
                let horizontalCenter = geometry.size.width / 2
                
                // Position at center of the card area (around 35-40% from top)
                let x = horizontalCenter
                let y = safeAreaTop + (availableHeight * 0.66) // Center of the main content card
                
                indicatorPosition = CGPoint(x: x, y: y)
                indicatorDirection = .down
            } else if let targetPosition = viewFinder.getViewPosition(for: targetId) {
                // Use ViewFinder for other buttons (works perfectly in regular views)
                indicatorPosition = targetPosition.center
                indicatorDirection = .down
            } else {
                // Fallback to previous behavior if view not yet tracked
                let fallback = CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                indicatorPosition = fallback
                indicatorDirection = .down
            }
        } else if let manualPosition = position {
            // Fallback to manual positioning
            indicatorPosition = calculateManualPosition(manualPosition, in: geometry)
            indicatorDirection = .down
        } else {
            // Default to center
            indicatorPosition = CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            indicatorDirection = .down
        }
    }
    
    private func calculateManualPosition(_ position: TutorialStep.ClickIndicatorPosition, in geometry: GeometryProxy) -> CGPoint {
        let size = geometry.size
        
        switch position {
        case .topLeft:
            return CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        case .topRight:
            return CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        case .bottomLeft:
            return CGPoint(x: size.width * 0.25, y: size.height * 0.75)
        case .bottomRight:
            return CGPoint(x: size.width * 0.75, y: size.height * 0.75)
        case .center:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        case .custom(let x, let y):
            return CGPoint(x: x, y: y)
        }
    }
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }
        
        // Arrow bounce animation
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            arrowOffset = 5
        }
        
        // Fade in/out animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
}

// MARK: - Arrow Indicator (Alternative style)
struct ArrowIndicator: View {
    let position: TutorialStep.ClickIndicatorPosition
    let direction: ArrowDirection
    
    @Environment(\.colorScheme) var scheme
    @State private var isAnimating = false
    @State private var arrowScale: CGFloat = 1.0
    
    enum ArrowDirection {
        case up, down, left, right
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Glowing background
                Circle()
                    .fill(arrowColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.0 : 0.6)
                
                // Arrow
                Image(systemName: arrowIcon)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(arrowColor)
                    .scaleEffect(arrowScale)
                    .shadow(color: arrowColor, radius: 4)
            }
            .position(calculatePosition(in: geometry))
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private var arrowColor: Color {
        scheme == .light ? .blue : .yellow
    }
    
    private var arrowIcon: String {
        switch direction {
        case .up: return "arrowtriangle.up.fill"
        case .down: return "arrowtriangle.down.fill"
        case .left: return "arrowtriangle.left.fill"
        case .right: return "arrowtriangle.right.fill"
        }
    }
    
    private func calculatePosition(in geometry: GeometryProxy) -> CGPoint {
        let size = geometry.size
        
        switch position {
        case .topLeft:
            return CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        case .topRight:
            return CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        case .bottomLeft:
            return CGPoint(x: size.width * 0.25, y: size.height * 0.75)
        case .bottomRight:
            return CGPoint(x: size.width * 0.75, y: size.height * 0.75)
        case .center:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        case .custom(let x, let y):
            return CGPoint(x: x, y: y)
        }
    }
    
    private func startAnimations() {
        // Scale animation
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            arrowScale = 1.2
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        ClickIndicator(position: .center, targetViewId: nil)
    }
}
