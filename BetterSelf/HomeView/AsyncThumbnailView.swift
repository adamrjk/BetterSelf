//
//  AsyncThumbnailView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/08/2025.
//
import AVKit
import SwiftUI

struct AsyncThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: Image?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            } else if isLoading {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.whiteCardGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.purple.opacity(0.7))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            } else {
                // Fallback when thumbnail generation fails
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.whiteCardGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "video")
                            .font(.title2)
                            .foregroundColor(.purple.opacity(0.7))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            }
        }
        .task {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        isLoading = true
        defer { isLoading = false }

        if let image = await generateThumbnail(from: videoURL) {
            await MainActor.run {
                thumbnail = image
            }
        }
    }

    private func generateThumbnail(from videoURL: URL, atTime time: CMTime = CMTimeMake(value: 1, timescale: 1)) async -> Image? {
        // Create an AVAsset from the video URL
        let asset = AVURLAsset(url: videoURL)

        // Create an AVAssetImageGenerator
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 3, preferredTimescale: 600)

        do {
            let videoDuration = try await asset.load(.duration)
            let thumbnail = try await generator.image(at: videoDuration).image
            return Image(uiImage: UIImage(cgImage: thumbnail))
        } catch {
            debugPrint("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
//#Preview {
//    AsyncThumbnailView(videoURL: )
//}
