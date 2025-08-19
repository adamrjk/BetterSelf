//
//  WebView.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import WebKit
import SwiftUI


struct VideoWebView: View {
    @State private var urlString: String = ""
    @State private var isFullscreen = false // Toggle for fullscreen mode

    var body: some View {
        VStack {
            TextField("Enter Video URL", text: $urlString)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Ensure the URL is valid before attempting to load it
            if let url = URL(string: urlString), isValidURL(url) {
                WebView(url: url, isFullscreen: $isFullscreen)
                    .frame(width: isFullscreen ? UIScreen.main.bounds.width : 300,
                           height: isFullscreen ? UIScreen.main.bounds.height : 300)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            } else {
                Text("Enter a valid URL")
            }

            // Fullscreen toggle
            Button(action: {
                isFullscreen.toggle()
            }) {
                Text(isFullscreen ? "Exit Fullscreen" : "Go Fullscreen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    // Helper to check if the URL is valid
    func isValidURL(_ url: URL) -> Bool {
        return url.absoluteString.contains("youtube.com") || url.absoluteString.contains("tiktok.com") || url.absoluteString.contains("instagram.com")
    }
}


struct WebView: UIViewRepresentable {
    var url: URL
    @Binding var isFullscreen: Bool

    func makeUIView(context: Context) -> WKWebView {
        // Set up the WKWebViewConfiguration
        let configuration = WKWebViewConfiguration()

        // Enable inline media playback
        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = .

        // Create WKWebView with the configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false // Disable scrolling
        webView.configuration.allowsAirPlayForMediaPlayback = true // Enable AirPlay

        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // You can update the WebView dynamically if needed
    }
}
#Preview {
//    https:www.youtube.com/watch?v=mH3Kzzt1v0g&list=LL&index=24&ab_channel=ElevateStart
//    https:www.youtube.com/embed/<enXA7xepu2U&t=1058s&ab_channel=ChrisWilliamson>
    WebView(url: URL(string: "https:www.youtube.com/watch?v=mH3Kzzt1v0g&list=LL&index=24&ab_channel=ElevateStart")!, isFullscreen: .constant(false))
}
