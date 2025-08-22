//
//  Movie.swift
//  BetterSelf
//
//  Created by Adam Damou on 17/08/2025.
//

import AVKit
import PhotosUI
import SwiftUI

struct Movie {
    let url: URL
    let thumbnail: UIImage?  // ✅ Thumbnail property
    
    init(url: URL, thumbnail: UIImage? = nil) {
        self.url = url
        self.thumbnail = thumbnail
    }

//    static var transferRepresentation: some TransferRepresentation {
//        FileRepresentation(contentType: .movie) { movie in
//            SentTransferredFile(movie.url)
//        } importing: { received in
//
//            let thumbnail = await generateThumbnail(from: received.file)
//
//            // 🚀 Generate thumbnail from received data (NO local storage!)
//            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
//
//           if FileManager.default.fileExists(atPath: copy.path()) {
//               try FileManager.default.removeItem(at: copy)
//           }
//
//           try FileManager.default.copyItem(at: received.file, to: copy)
//
//
//            
//            // ✅ Return Movie with original URL and thumbnail (no copy!)
//            return Self.init(url: copy, thumbnail: thumbnail)
//        }
//    }
    
   
}
