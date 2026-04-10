//
//  UtilFuncs.swift
//  BetterSelf
//
//  Created by Adam Damou on 19/11/2025.
//

import Foundation


enum IDGenerator {
    static func generateShortID(length: Int = 6) -> String {
        let characters = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""
        result.reserveCapacity(length)
        for _ in 0..<length {
            result.append(characters.randomElement()!)
        }
        return result
    }
}
