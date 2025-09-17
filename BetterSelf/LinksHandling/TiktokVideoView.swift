//
//  TiktokVideoView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

import SwiftUI

struct TikTokVideoView: View {
    let username: String   // e.g. "scout2015"
    let videoID: String    // e.g. "6718335390845095173"

    var body: some View {
        Color.clear
            .onAppear {
                openInTikTok()
            }
    }

    private func openInTikTok() {
        // Deep link into TikTok app
        if let appURL = URL(string: "snssdk1128://user/@\(username)/video/\(videoID)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: "https://www.tiktok.com/@\(username)/video/\(videoID)") {
            // Fallback to web player
            UIApplication.shared.open(webURL)
        }
    }
}
//#Preview {
//    TiktokVideoView()
//}
