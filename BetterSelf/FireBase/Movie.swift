//
//  Movie.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import AVKit
import PhotosUI
import SwiftUI

struct Movie: Transferable {
    let url: URL
    let thumbnail: UIImage?  // ✅ Thumbnail property
    
    init(url: URL, thumbnail: UIImage? = nil) {
        self.url = url
        self.thumbnail = thumbnail
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            // 🚀 Generate thumbnail from received data (NO local storage!)
            let thumbnail = await generateThumbnail(from: received.file)
            
            // ✅ Return Movie with original URL and thumbnail (no copy!)
            return Self.init(url: received.file, thumbnail: thumbnail)
        }
    }
    
    // 🚀 NEW: Fast thumbnail generation from file URL
    private static func generateThumbnail(from videoURL: URL) async -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        // Get thumbnail at 0.1 seconds (very fast)
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        
        do {
            let cgImage = try await generator.image(at: time).image
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail generation error: \(error)")
            return nil
        }
    }
}
