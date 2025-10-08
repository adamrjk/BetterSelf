//
//  Arrow.swift
//  BetterSelf
//
//  Created by Adam Damou on 06/10/2025.
//

import SwiftUI

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Arrow shaft
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.7))

        // Arrow head
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY * 0.7))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.4))

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY * 0.7))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))

        return path
    }
}

#Preview {
    Arrow()
        .stroke(.blue, lineWidth: 5) // color & thickness
        .frame(width: 100, height: 150)
        .padding()
}
