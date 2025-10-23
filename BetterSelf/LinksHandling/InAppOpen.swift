//
//  InAppOpen.swift
//  BetterSelf
//
//  Created by Adam Damou on 23/10/2025.
//

import SwiftUI

struct InAppOpen: View {
    @Environment(\.dismiss) var dismiss
    let link: URL

    var body: some View {
        Color.clear
            .onAppear {
                openInApp()
                dismiss()


            }
    }

    private func openInApp() {
        UIApplication.shared.open(link)
//        if let appURL = URL(string: "instagram://reel/\(reelID)"),
//           UIApplication.shared.canOpenURL(appURL) {
//            UIApplication.shared.open(appURL)
//        } else if let webURL = URL(string: "https://www.instagram.com/reel/\(reelID)/") {
//            UIApplication.shared.open(webURL)
//        }
    }
}

//#Preview {
//    InAppOpen(link: URL(string: ""))
//}
