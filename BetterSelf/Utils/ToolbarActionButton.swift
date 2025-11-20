//
//  ToolbarActionButton.swift
//  BetterSelf
//
//  Created by AI Assistant on 19/11/2025.
//

import SwiftUI

struct VideoRecorderToolBarButton: View {
    let flow: AppFlow
    let color: Color
    var body: some View {
        Button("Quick Add", systemImage: "video.fill.badge.plus"){
            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                "button": "quick_add",
                "view": "HomeView"
            ])
            flow.cameraSheet()
        }
        .buttonStyle(.plain)
        .foregroundStyle(color)
        .padding(8)
    }
}




// Small helper to conditionally apply a modifier
private extension View {
    @ViewBuilder
    func ifLet<T>(_ value: T?, apply: (Self, T) -> some View) -> some View {
        if let value {
            apply(self, value)
        } else {
            self
        }
    }
}


