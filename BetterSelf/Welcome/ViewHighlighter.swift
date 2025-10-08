//
//  ViewHighlighter.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

// MARK: - View Highlighter Manager
class ViewHighlighter: ObservableObject {
    static let shared = ViewHighlighter()
    
    @Published var highlightedViewId: String? = nil
    @Published var highlightIntensity: Double = 0.0
    
    private init() {}
    
    func highlightView(id: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            highlightedViewId = id
            highlightIntensity = 1.0
        }
    }
    
    func clearHighlight() {
        withAnimation(.easeInOut(duration: 0.3)) {
            highlightedViewId = nil
            highlightIntensity = 0.0
        }
    }
    
    func isHighlighted(id: String) -> Bool {
        return highlightedViewId == id
    }
}

// MARK: - Highlight Modifier (Simplified - No Visual Effects)
struct HighlightModifier: ViewModifier {
    let id: String
    @StateObject private var highlighter = ViewHighlighter.shared
    
    func body(content: Content) -> some View {
        content
        // No visual effects - just tracking for opacity control
    }
}

// MARK: - View Extension for Highlighting
extension View {
    func tutorialHighlight(id: String) -> some View {
        self.modifier(HighlightModifier(id: id))
    }
}

// MARK: - Tutorial Overlay with Smart Dimming
struct SmartTutorialOverlay: View {
    let targetViewId: String?
    @StateObject private var viewFinder = ViewFinder.shared
    @StateObject private var highlighter = ViewHighlighter.shared
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // Cutout for target view using Path
                if let targetId = targetViewId,
                   let targetPosition = viewFinder.getViewPosition(for: targetId) {
                    
                    let targetFrame = targetPosition.frame
                    let padding: CGFloat = 8
                    let cutoutRect = CGRect(
                        x: targetFrame.minX - padding,
                        y: targetFrame.minY - padding,
                        width: targetFrame.width + (padding * 2),
                        height: targetFrame.height + (padding * 2)
                    )
                    
                    // Create cutout using Path
                    Path { path in
                        // Add full screen rectangle
                        path.addRect(CGRect(origin: .zero, size: geometry.size))
                        // Subtract the target view area
                        path.addRoundedRect(in: cutoutRect, cornerSize: CGSize(width: 12, height: 12))
                    }
                    .fill(Color.black.opacity(0.4))
                    .blendMode(.destinationOut)
                }
            }
        }
        .allowsHitTesting(false) // Allow taps to pass through
        .onAppear {
            if let targetId = targetViewId {
                highlighter.highlightView(id: targetId)
            }
        }
        .onDisappear {
            highlighter.clearHighlight()
        }
    }
}
 
