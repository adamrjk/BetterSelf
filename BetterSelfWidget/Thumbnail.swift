//
//  Thumbnail.swift
//  BetterSelf
//
//  Created by Adam Damou on 12/10/2025.
//


import SwiftUI

struct Thumbnail: View {
    let videoURL: String


    private var videoID: String? {
        if let url = URL(string: videoURL) {
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
               let v = queryItems.first(where: { $0.name == "v" })?.value {
                return v
            }
            if url.host == "youtu.be" {
                return url.lastPathComponent
            }
            return nil
        }
        return nil
    }

    private var thumbnailURL: URL? {
        guard let id = videoID else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
    }


    var body: some View {
        if let thumbnailURL {
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .clipShape(.rect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            EmptyView()
        }
    }
}

//#Preview {
//    YoutubeThumbnailView()
//}

