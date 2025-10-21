//
//  AppearanceController.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/10/2025.
//

import Foundation
import UIKit


final class AppearanceController {
    static let shared = AppearanceController()

    func apply(_ mode: ThemeMode) {
        let style: UIUserInterfaceStyle = {
            switch mode {
            case .auto:  return .unspecified   // follow system (no override)
            case .light: return .light
            case .dark:  return .dark
            }
        }()

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
