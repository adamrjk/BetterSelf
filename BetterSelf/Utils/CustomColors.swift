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

    static let darkPurple = Color(red: 0.802,green:  0.624,blue:  0.641)

    static let darkPurpleMainGradient = LinearGradient(
        colors: [
            Color(red: 0.5, green: 0, blue: 0.5).opacity(0.3),
            Color(red: 0.5, green: 0, blue: 0.5).opacity(0.2),
            Color(red: 0.5, green: 0, blue: 0.5).opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let systemGrayGradient = LinearGradient(
        colors: [
            Color(.systemGray6),
            Color(.systemGray6)
        ],
        startPoint: .top,
        endPoint: .bottom
    )


    static let whiteItemGradient: LinearGradient =
            LinearGradient(
                colors: [
                    Color.white,
                    Color.white.opacity(0.9),
                    Color.white.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )


    static let whiteBackgroundGradient: LinearGradient =
            LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.15)
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
    static let blueGradient = LinearGradient(
        colors: [
            Color.blue.opacity(0.3),
            Color.blue.opacity(0.2),
            Color.blue.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tabViewGradient = LinearGradient(
        colors: [
            Color(red: 80/255, green: 60/255, blue: 100/255, opacity: 0.6),  // darker muted purple
            Color(red: 70/255, green: 55/255, blue: 90/255, opacity: 0.5),
            Color(red: 60/255, green: 50/255, blue: 80/255, opacity: 0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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

    static let darkNavy = Color(red: 10/255, green: 31/255, blue: 68/255)


    static let creamyYellowGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.95, blue: 0.8),
            Color(red: 1.0, green: 0.93, blue: 0.75)

        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let blackGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.06, blue: 0.06),  // #0f0f0f
            Color(red: 0.10, green: 0.10, blue: 0.10)   // #1a1a1a
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let overlayCreamyYellowGradient = RadialGradient(
        colors: [
            Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.3),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 400
    )

    // Overlay for light mode in Black & White theme
    static let whiteOverlayGradient = RadialGradient(
        colors: [
            Color.white.opacity(0.25),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 400
    )

    // Overlay for dark mode in Black & White theme
    static let blackOverlayGradient = RadialGradient(
        colors: [
            Color.black.opacity(0.25),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 400
    )

    // Item/background accents for Black & White theme (light mode)
    static let grayItemGradient = LinearGradient(
        colors: [
            Color(white: 0.95),
            Color(white: 0.90)
        ],
        startPoint: .top,
        endPoint: .bottom
    )



    // Button fills for Black & White theme (light mode)
    static let grayButtonGradient = LinearGradient(
        colors: [
            Color(white: 0.20),
            Color(white: 0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Button fills for Black & White theme (dark mode)
    static let whiteButtonGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.95),
            Color.white.opacity(0.85)
        ],
        startPoint: .top,
        endPoint: .bottom
    )



}


