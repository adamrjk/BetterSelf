//
//  InstagramReelView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

import WebKit
import SwiftUI
import SafariServices


struct InstagramReelView: View {
    
    @Environment(\.dismiss) var dismiss
    let reelID: String   // e.g. "CzX123abc"

    var body: some View {
        Color.clear
            .onAppear {
                openInInstagram()
                dismiss()


            }
    }

    private func openInInstagram() {
        if let appURL = URL(string: "instagram://reel/\(reelID)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: "https://www.instagram.com/reel/\(reelID)/") {
            UIApplication.shared.open(webURL)
        }
    }
}

#Preview {
//    InstagramReelView(reelID: "https://www.instagram.com/reel/C8NQ25giWZh")
}
