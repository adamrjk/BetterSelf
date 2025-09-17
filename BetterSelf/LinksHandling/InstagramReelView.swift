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

//Version 1: Embed Reel
//struct InstagramReelEmbedView: UIViewRepresentable {
//    let reelPermalink: String // e.g. "https://www.instagram.com/reel/<SHORTCODE>/"
//
//    func makeUIView(context: Context) -> WKWebView {
//        let config = WKWebViewConfiguration()
//        config.allowsInlineMediaPlayback = true
//        let web = WKWebView(frame: .zero, configuration: config)
//        web.scrollView.isScrollEnabled = false
//
//        let html = """
//        <!doctype html><html><head>
//          <meta name="viewport" content="width=device-width, initial-scale=1">
//          <style>html,body{margin:0;background:#000;}</style>
//        </head><body>
//          <blockquote class="instagram-media"
//            data-instgrm-permalink="\(reelPermalink)"
//            data-instgrm-captioned="false"
//            data-instgrm-version="14"></blockquote>
//          <script async src="https://www.instagram.com/embed.js"></script>
//        </body></html>
//        """
//        web.loadHTMLString(html, baseURL: nil)
//        return web
//    }
//    func updateUIView(_ uiView: WKWebView, context: Context) {}
//}
//
//struct InstagramReelView: View {
//    var body: some View {
//        InstagramReelEmbedView(reelPermalink: "https://www.instagram.com/reel/C8NQ25giWZh/")
//            .frame(maxWidth: .infinity)
//            .frame(maxHeight: .infinity) // tune for your layout
//            .scaledToFit()
//            .background(.black)
//    }
//}

// Version 2: SafariView

//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        let vc = SFSafariViewController(url: url)
//        vc.dismissButtonStyle = .close
//        return vc
//    }
//    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
//}
//
//struct InstagramReelView: View {
//    let link: String
//    @State private var show = true
//
//    var body: some View {
//        Color.clear
//            .fullScreenCover(isPresented: $show) {
//                SafariView(url: URL(string: link)!)
//                    .ignoresSafeArea()
//            }
//    }
//}
//Version 3: WebView
//struct WebViewReel: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        let config = WKWebViewConfiguration()
//        config.allowsInlineMediaPlayback = true
//        let webView = WKWebView(frame: .zero, configuration: config)
//        webView.scrollView.isScrollEnabled = false
//        webView.scrollView.bounces = false
//        webView.load(URLRequest(url: url))
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {}
//}
//
//struct InstagramReelView: View {
//    let link: String
//    var body: some View {
//        WebViewReel(url: URL(string: link)!)
//            .ignoresSafeArea()
//
//    }
//}

//Version 4: In app open

struct InstagramReelView: View {
    let reelID: String   // e.g. "CzX123abc"

    var body: some View {
        Color.clear
            .onAppear {
                openInInstagram()
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
