//
//  MyYoutubePlayerView.swift
//  BetterSelf
//
//  Created by Adam Damou on 22/09/2025.
//
import WebKit

import SwiftUI

struct MyYouTubePlayerView: UIViewRepresentable {
    let videoID: String
    @Binding var time: Int
    @State private var webView: WKWebView
    @State var isPlayable: Bool

    class Coordinator {
        var lastLoadedTime: Int?
        let videoID: String
        let isPlayable: Bool
        init(videoID: String, isPlayable: Bool) {
            self.videoID = videoID
            self.isPlayable = isPlayable
        }
        func html(for time: Int) -> String {
            return """
             <!DOCTYPE html>
             <html style=\"margin:0; padding:0; height:100%;\">
                 <body style=\"margin:0; padding:0; height:100%;\">
                 <div id=\"player\"></div>
                 <script>
                     var tag = document.createElement('script');
                     tag.src = \"https://www.youtube.com/iframe_api\";
                     var firstScriptTag = document.getElementsByTagName('script')[0];
                     firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

                     var player;
                     function onYouTubeIframeAPIReady() {
                     player = new YT.Player('player', {
                         height: '100%',
                         width: '100%',
                         videoId: '\(videoID)',
                         playerVars: {
                         'playsinline': 1,
                         'modestbranding': 1,
                         'controls': 1,
                         'rel': 0,
                         'start': \(time)
                         }
                    });
                    }

                    function getCurrentTime() {
                    return player.getCurrentTime();
                    }
                    function seekTo(time) {
                    player.seekTo(time, true);
                    }
                    function playVideo() {
                    player.playVideo();
                    }
                    function pauseVideo() {
                    player.pauseVideo();
                    }
                </script>
                </body>
            </html>
            """
        }
    }

    init(videoID: String, time: Binding<Int>, isPlayable: Bool, saveView: (WKWebView) -> Void) {
        self.videoID = videoID
        _time = time
        self.isPlayable = isPlayable

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        self.webView = WKWebView(frame: .zero, configuration: config)

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(videoID: videoID, isPlayable: isPlayable)
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.isUserInteractionEnabled = isPlayable
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        let html = context.coordinator.html(for: time)

        webView.loadHTMLString(html, baseURL: nil)
        context.coordinator.lastLoadedTime = time
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // If the bound `time` changed, rebuild and reload the HTML so the player starts from the new time
        if context.coordinator.lastLoadedTime != time {
            let html = context.coordinator.html(for: time)
            uiView.loadHTMLString(html, baseURL: nil)
            context.coordinator.lastLoadedTime = time
        }
        // Also keep interaction flags in sync
        uiView.isUserInteractionEnabled = isPlayable
        uiView.scrollView.isScrollEnabled = false
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
    }
}

//#Preview {
//    MyYoutubePlayerView()
//}
