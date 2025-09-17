//
//  SharedLinkView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

struct SharedLinkView: View {
    @State private var reel = true
    let link: String

    @State private var type: LinkType

    @Binding var time: Int


    var body: some View {
        ZStack {
            Color.purpleMainGradient
                .ignoresSafeArea()
            Color.purpleOverlayGradient
                .ignoresSafeArea()

            switch type {
            case .youtube:
                YoutubeView(isPlayable: true, youtubeId: getId() ?? "", time: $time)
            case .shortForm:
                Text("ShortForm handling coming soon")
            case .article:
                ArticleView(link: link)
            }





        }
    }

    func getId() -> String? {
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

    init(link: String, time: Binding<Int>) {
        self.link = link
        _time = time

        if link.localizedStandardContains("youtube.com") {
            if link.localizedStandardContains("shorts") {
                self.type = .shortForm
            }
            else {
                self.type = .youtube
            }

        }
        else if link.localizedStandardContains("tiktok.com") || link.localizedStandardContains("instagram.com") {
            self.type = .shortForm
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


//#Preview {
//    SharedLinkView(id: "nQY3-VGTXpk", time)
//}
