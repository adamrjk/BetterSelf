//
//  YoutubeShortsPlayer.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = .black
        vc.preferredControlTintColor = .white
        return vc
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

struct YoutubeShortsPlayer: View {
    @State private var show = false
    var body: some View {
        Button("Open Short") {
            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                "button": "open_short",
                "view": "YoutubeShortsPlayer"
            ])
            show = true
        }
        .sheet(isPresented: $show) {
            // Use the /shorts/ link
            SafariView(url: URL(string:"https://www.youtube.com/shorts/FpT3Fi3_484")!)
                .ignoresSafeArea()
        }
    }
}
