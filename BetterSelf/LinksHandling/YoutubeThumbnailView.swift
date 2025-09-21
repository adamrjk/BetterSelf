//
//  YoutubeThumbnailView.swift
//  BetterSelf
//
//  Created by Adam Damou on 21/09/2025.
//

import SwiftUI

struct YouTubeThumbnailView: View {
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
    @State var type: thumbnailType

    var width: CGFloat {
        switch type {
        case .addReminder:
            400
        case .reminderRow:
            80
        case .preview:
            40
        }
    }
    var heigth: CGFloat{
        switch type {
        case .addReminder:
            300
        case .reminderRow:
            80
        case .preview:
            40
        }

    }

    var body: some View {
        if let thumbnailURL {
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    if type == .addReminder {
                        image
                            .resizable()

                            .frame(maxHeight: 300)
                            .cornerRadius(30)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .purple.opacity(0.15), radius: 8, x: 0, y: 4)
                            .shadow(color: .purple.opacity(0.1), radius: 16, x: 0, y: 8)





                    }

                    else {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: heigth)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }


                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "xmark.circle")
        }
    }
    enum thumbnailType {
        case addReminder
        case reminderRow
        case preview
    }
}

//#Preview {
//    YoutubeThumbnailView()
//}
