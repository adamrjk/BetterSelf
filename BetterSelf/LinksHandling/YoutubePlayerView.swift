//
//  Youtube PlayerView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import WebKit
import SwiftUI

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    @State private var webView: WKWebView

    init(videoID: String, saveView: (WKWebView) -> Void) {
        self.videoID = videoID
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        self.webView = WKWebView(frame: .zero, configuration: config)

    }

    func makeUIView(context: Context) -> WKWebView {
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        // Embed YouTube IFrame with inline playback and full controls
        let html = """
         <!DOCTYPE html>
         <html style="margin:0; padding:0; height:100%;">
             <body style="margin:0; padding:0; height:100%;">
             <div id="player"></div>
             <script>
                 var tag = document.createElement('script');
                 tag.src = "https://www.youtube.com/iframe_api";
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
                     'rel': 0
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

        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct YoutubeView: View {
    @State private var webView = WKWebView()
    @State private var isFullscreen = false
    let youtubeId: String


    var body: some View {
        ZStack {
            Color.purpleMainGradient
                .ignoresSafeArea()

            Color.purpleOverlayGradient
                .ignoresSafeArea()

            GeometryReader { proxy in
                VStack {
                    Spacer()
                    ZStack {
                        YouTubePlayerView(videoID: youtubeId){ web in
                            self.webView = web
                        }
                        .ignoresSafeArea(.all, edges: .top)
                        .scaledToFit()
                        .cornerRadius(30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .purple.opacity(0.15), radius: 8, x: 0, y: 4)
                        .shadow(color: .purple.opacity(0.1), radius: 16, x: 0, y: 8)
                        .frame(width: proxy.size.width)

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    goFullscreen()
                                } label: {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .padding()
                            }
                        }


                    }


                    Spacer()
                }

            }
        }
       .fullScreenCover(isPresented: $isFullscreen) {
           FullscreenPlayerView(webView: webView)
               .ignoresSafeArea()

       }
    }
    func goFullscreen() {
         // Pause briefly to capture current time
         webView.evaluateJavaScript("getCurrentTime();") { result, _ in
             if let time = result as? Double {
                 // Seek in fullscreen player to same time
                 webView.evaluateJavaScript("seekTo(\(time)); playVideo();")
                 isFullscreen = true
             }
         }
     }
}
struct FullscreenPlayerView: View {
    let webView: WKWebView

    var body: some View {
        ZStack {
            WebViewContainer(webView: webView)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}



#Preview {
    YoutubeView(youtubeId: "nQY3-VGTXpk")
}
