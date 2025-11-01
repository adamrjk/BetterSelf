//
//  SharedLinkView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

struct SharedLinkView: View {

    @Environment(\.dismiss) var dismiss
    @State private var reel = true
    let link: String


    @State private var type: LinkType
    @State private var shortType: ShortType = .instaReel

    @Binding var time: Int
    let text: String
    @EnvironmentObject var color: ColorManager
    @Environment(\.colorScheme) var scheme

    var isSheet: Bool

    var body: some View {
        NavigationStack {

            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()

                switch type {
                case .youtube:
                    //                YoutubeView(isPlayable: true, youtubeId: getYoutubeId() ?? "", time: $time)
                    YoutubeView(videoURL: link,  time: $time, text: text)


                case .shortForm:
//                    ArticleView(link: link)
//                        .ignoresSafeArea()
                    InAppOpen(link: URL(string: link)!)
//                    switch shortType {
//                    case .youtubeShort:
//                        Text("youtube Shorts handling coming soon")
//                    case .instaReel:
//                        InstagramReelView(reelID: getInstagramReelID() ?? "")
//                    case .tiktok:
//                        TikTokVideoView(username: getTikTokUsername() ?? "", videoID: getTikTokVideoID() ?? "")
//                    }

                case .article:
                    ArticleView(link: link)
                        .ignoresSafeArea()
                }





            }
            .toolbar {
                if isSheet {
                    ToolbarItem(placement: .topBarLeading){
                        Button("Cancel"){
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "cancel",
                                "view": "SharedLinkView",
                                "url": link
                            ])
                            dismiss()

                        }
                    }
                }
            }
        }
    }

    func getYoutubeId() -> String? {
        let patterns = [
              "youtube\\.com/watch\\?v=([a-zA-Z0-9_-]{11})",
              "youtu\\.be/([a-zA-Z0-9_-]{11})",
              "youtube\\.com/embed/([a-zA-Z0-9_-]{11})"
          ]

          for pattern in patterns {
              if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                  let range = NSRange(link.startIndex..<link.endIndex, in: link)
                  if let match = regex.firstMatch(in: link, options: [], range: range) {
                      if let idRange = Range(match.range(at: 1), in: link) {
                          return String(link[idRange])
                      }
                  }
              }
          }
          return nil

    }


    func getInstagramReelID() -> String? {
        // Try path-based patterns first
        let patterns = [
            "instagram\\.com/reel/([A-Za-z0-9_-]+)",
            "instagram\\.com/p/([A-Za-z0-9_-]+)",
            "instagram\\.com/tv/([A-Za-z0-9_-]+)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(link.startIndex..<link.endIndex, in: link)
                if let match = regex.firstMatch(in: link, options: [], range: range),
                   let idRange = Range(match.range(at: 1), in: link) {
                    // Trim trailing slashes if present
                    return String(link[idRange]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                }
            }
        }

        // Fallback: Check for id-like query parameters (e.g., ?reel_id=... or ?id=...)
        if let url = URL(string: link),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            if let value = queryItems.first(where: { ["reel_id", "id", "shortcode"].contains($0.name.lowercased()) })?.value,
               !value.isEmpty {
                return value
            }
        }

        return nil
    }

    func getTikTokVideoID() -> String? {
        // Path-based patterns
        let patterns = [
            // Standard format with username
            "tiktok\\.com/@[A-Za-z0-9_\\.]+/video/([0-9]+)",
            // Mobile legacy format
            "tiktok\\.com/v/([0-9]+)\\.html"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(link.startIndex..<link.endIndex, in: link)
                if let match = regex.firstMatch(in: link, options: [], range: range),
                   let idRange = Range(match.range(at: 1), in: link) {
                    return String(link[idRange])
                }
            }
        }

        // Fallback to query params (some shared links add ?video_id=...)
        if let url = URL(string: link),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let value = queryItems.first(where: { ["video_id", "vid", "id"].contains($0.name.lowercased()) })?.value,
           !value.isEmpty {
            return value
        }

        return nil
    }

    func getTikTokUsername() -> String? {
        // Username in path
        let pattern = "tiktok\\.com/@([A-Za-z0-9_\\.]+)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(link.startIndex..<link.endIndex, in: link)
            if let match = regex.firstMatch(in: link, options: [], range: range),
               let idRange = Range(match.range(at: 1), in: link) {
                return String(link[idRange])
            }
        }

        // Fallback: sometimes username appears as query param (rare, but handle)
        if let url = URL(string: link),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let value = queryItems.first(where: { ["user", "username"].contains($0.name.lowercased()) })?.value,
           !value.isEmpty {
            return value.replacingOccurrences(of: "@", with: "")
        }

        return nil
    }

    init(link: String, time: Binding<Int>, text: String, isSheet: Bool? = nil) {
        
        self.link = link
        self.text = text
        _time = time
        self.isSheet = isSheet ?? false

        if link.localizedStandardContains("youtube.com") || link.localizedStandardContains("youtu.be") {
//            if link.localizedStandardContains("shorts") {
//                self.type = .shortForm
//                self.shortType = .youtubeShort
//            }
//            else {
                self.type = .youtube
//            }

        }
        else if link.localizedStandardContains("tiktok.com"){
            self.type = .shortForm
            self.shortType = .tiktok
        }
        else if link.localizedStandardContains("instagram.com") {
            self.type = .shortForm
            self.shortType = .instaReel
        }
        else {
            self.type = .article
        }




    }
}


enum LinkType: String, Codable, CaseIterable {
    case youtube = "Youtube"
    case shortForm = "ShortForm"
    case article = "Article"
}

enum ShortType {
    case youtubeShort
    case instaReel
    case tiktok
}

//#Preview {
//    SharedLinkView(id: "nQY3-VGTXpk", time)
//}

