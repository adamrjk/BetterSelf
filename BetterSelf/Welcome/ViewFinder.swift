//
//  ViewFinder.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

// MARK: - View Position Data
struct ViewPosition {
    let id: String
    let frame: CGRect
    let center: CGPoint
    let isVisible: Bool
}

// MARK: - View Finder Manager
class ViewFinder: ObservableObject {
    static let shared = ViewFinder()
    
    @Published var viewPositions: [String: ViewPosition] = [:]
    
    private init() {}
    
    func updateViewPosition(id: String, frame: CGRect, isVisible: Bool = true) {
        let position = ViewPosition(
            id: id,
            frame: frame,
            center: CGPoint(x: frame.midX, y: frame.midY),
            isVisible: isVisible
        )
        viewPositions[id] = position
    }
    
    func getViewPosition(for id: String) -> ViewPosition? {
        return viewPositions[id]
    }
    
    func calculateOptimalIndicatorPosition(for targetId: String, in screenSize: CGSize) -> CGPoint {
        guard let targetPosition = getViewPosition(for: targetId) else {
            // Fallback to center if view not found
            return CGPoint(x: screenSize.width * 0.5, y: screenSize.height * 0.5)
        }
        
        let targetFrame = targetPosition.frame
        let targetCenter = targetPosition.center
        
        // Calculate available space around the target
        let topSpace = targetFrame.minY
        let bottomSpace = screenSize.height - targetFrame.maxY
        let leftSpace = targetFrame.minX
        let rightSpace = screenSize.width - targetFrame.maxX
        
        // Determine best position based on available space
        if topSpace > 100 {
            // Show above the target
            return CGPoint(x: targetCenter.x, y: targetFrame.minY - 50)
        } else if bottomSpace > 100 {
            // Show below the target
            return CGPoint(x: targetCenter.x, y: targetFrame.maxY + 50)
        } else if leftSpace > 120 {
            // Show to the left
            return CGPoint(x: targetFrame.minX - 60, y: targetCenter.y)
        } else if rightSpace > 120 {
            // Show to the right
            return CGPoint(x: targetFrame.maxX + 60, y: targetCenter.y)
        } else {
            // Fallback: show near the target
            return CGPoint(x: targetCenter.x, y: targetCenter.y - 80)
        }
    }
    
    func getIndicatorDirection(for targetId: String, indicatorPosition: CGPoint) -> ClickIndicatorDirection {
        guard let targetPosition = getViewPosition(for: targetId) else {
            return .down
        }
        
        let targetCenter = targetPosition.center
        let deltaX = indicatorPosition.x - targetCenter.x
        let deltaY = indicatorPosition.y - targetCenter.y
        
        // Determine direction based on relative position
        if abs(deltaY) > abs(deltaX) {
            return deltaY > 0 ? .up : .down
        } else {
            return deltaX > 0 ? .left : .right
        }
    }
}

// MARK: - Click Indicator Direction
enum ClickIndicatorDirection {
    case up, down, left, right
}

// MARK: - View Tracker Modifier
struct ViewTracker: ViewModifier {
    let id: String
    @StateObject private var viewFinder = ViewFinder.shared
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            let frame = geometry.frame(in: .global)
                            viewFinder.updateViewPosition(id: id, frame: frame)
                        }
                        .onChange(of: geometry.frame(in: .global)) { newFrame in
                            viewFinder.updateViewPosition(id: id, frame: newFrame)
                        }
                }
            )
    }
}

// MARK: - View Extension for Easy Tracking
extension View {
    func trackView(id: String) -> some View {
        self.modifier(ViewTracker(id: id))
    }
}
