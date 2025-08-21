//
//  CustomColors.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

extension Color {

    static let purpleMainGradient = LinearGradient(
        colors: [
            Color.purple.opacity(0.3),
            Color.purple.opacity(0.2),
            Color.purple.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleOverlayGradient = RadialGradient(
        colors: [
            Color.purple.opacity(0.2),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 400
    )
    
    static let whiteCardGradient = LinearGradient(
        colors: [
            Color.white,
            Color.white.opacity(0.98),
            Color.white.opacity(0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let whiteFieldGradient = LinearGradient(
        colors: [
            Color.white,
            Color.white.opacity(0.98)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let yellowAccentGradient = LinearGradient(
        colors: [
            Color.yellow.opacity(0.6),
            Color.yellow.opacity(0.5)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let creamyYellow = Color(red: 1.0, green: 0.95, blue: 0.8)




    static let cardBackground = LinearGradient(
            colors: [
                Color("CreamyYellow1"),
                Color("CreamyYellow2")
            ],
            startPoint: .top,
            endPoint: .bottom
        )


    static let creamyYellowGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.95, blue: 0.8),
            Color(red: 1.0, green: 0.93, blue: 0.75)

        ],
        startPoint: .top,
        endPoint: .bottom
    )



}


