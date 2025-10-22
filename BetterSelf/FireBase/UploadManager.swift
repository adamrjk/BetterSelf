//
//  UploadManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import Foundation
import AVKit
import FirebaseStorage
import SwiftUI

class UploadManager: ObservableObject {
    

    static let shared = UploadManager()

    @Published var activeUploads: [String: UploadStatus] = [:]

    private init() {}


    func uploadVideoToFirebase(videoURL: URL, reminder: Reminder) async {
        startUpload(videoURL: videoURL){ result in
            switch result {
            case .success(let firebaseURL):
                reminder.firebaseVideoURL = firebaseURL

            case .failure(let error):
                print("Firebase upload failed: \(error.localizedDescription)")
            }
        }
    }

    func loadVideo(_ reminder: Reminder, recordedVideoURL: URL?) {
            Task {
                if let url = recordedVideoURL {
                    // Generate thumbnail immediately
                    if let thumbnail = await generateThumbnail(from: url) {
                        reminder.photo = thumbnail.jpegData(compressionQuality: 0.8)
                    }

                    // Upload video in background
                    await uploadVideoToFirebase(videoURL: url, reminder: reminder)
                }
            }
        }

    // Generate thumbnail from video URL
    func generateThumbnail(from videoURL: URL) async -> UIImage? {
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



    func startUpload(
        videoURL: URL,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Void {
        let uploadID = UUID().uuidString

        // Create upload status
        let status = UploadStatus(
            id: uploadID,
            progress: 0.0,
            status: .uploading
        )

        activeUploads[uploadID] = status

        // Start upload in background
        FirebaseStorageService.shared.uploadVideo(
            videoURL: videoURL){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let firebaseURL):
                    self.activeUploads[uploadID]?.status = .completed
                    self.activeUploads[uploadID]?.firebaseURL = firebaseURL
                    completion(.success(firebaseURL))

                case .failure(let error):
                    self.activeUploads[uploadID]?.status = .failed
                    self.activeUploads[uploadID]?.error = error
                    completion(.failure(error))
                }

                // Clean up after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.activeUploads.removeValue(forKey: uploadID)
                }
            }
        }
    }

    func startUpload(
        videoData: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Void {
        let uploadID = UUID().uuidString

        // Create upload status
        let status = UploadStatus(
            id: uploadID,
            progress: 0.0,
            status: .uploading
        )

        activeUploads[uploadID] = status

        // Start upload in background
        FirebaseStorageService.shared.uploadVideo(
            videoData: videoData){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let firebaseURL):
                    self.activeUploads[uploadID]?.status = .completed
                    self.activeUploads[uploadID]?.firebaseURL = firebaseURL
                    completion(.success(firebaseURL))

                case .failure(let error):
                    self.activeUploads[uploadID]?.status = .failed
                    self.activeUploads[uploadID]?.error = error
                    completion(.failure(error))
                }

                // Clean up after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.activeUploads.removeValue(forKey: uploadID)
                }
            }
        }
    }

    func startUpload(
        imageData: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Void {
        let uploadID = UUID().uuidString

        let status = UploadStatus(
            id: uploadID,
            progress: 0.0,
            status: .uploading
        )

        activeUploads[uploadID] = status

        let fileName = "\(UUID().uuidString).jpg"
        let imageRef = Storage.storage().reference().child("images/\(fileName)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.activeUploads[uploadID]?.status = .failed
                    self.activeUploads[uploadID]?.error = error
                    completion(.failure(error))
                } else {
                    imageRef.downloadURL { url, urlError in
                        if let urlError = urlError {
                            self.activeUploads[uploadID]?.status = .failed
                            self.activeUploads[uploadID]?.error = urlError
                            completion(.failure(urlError))
                        } else if let downloadURL = url?.absoluteString {
                            self.activeUploads[uploadID]?.status = .completed
                            self.activeUploads[uploadID]?.firebaseURL = downloadURL
                            completion(.success(downloadURL))
                        } else {
                            let genericError = NSError(
                                domain: "UploadManager",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to obtain download URL"]
                            )
                            self.activeUploads[uploadID]?.status = .failed
                            self.activeUploads[uploadID]?.error = genericError
                            completion(.failure(genericError))
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            self.activeUploads.removeValue(forKey: uploadID)
                        }
                    }
                }
            }
        }
    }

    // Fetch image bytes for a Firebase photo URL (supports https and gs://)
    func fetchImageData(
        from firebaseURL: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: firebaseURL) else {
            completion(.failure(NSError(domain: "UploadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])))
            return
        }

        if url.scheme == "gs" {
            // Use Firebase Storage reference for gs:// URLs
            let ref = Storage.storage().reference(forURL: firebaseURL)
            // 20 MB limit by default; adjust as needed
            ref.getData(maxSize: 20 * 1024 * 1024) { data, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(NSError(domain: "UploadManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])) )
                    }
                }
            }
            return
        }

        // For https download URLs, fetch via URLSession
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
                    completion(.failure(NSError(domain: "UploadManager", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])) )
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "UploadManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Empty response body"])) )
                    return
                }

                completion(.success(data))
            }
        }
        task.resume()
    }


    func getUploadStatus(for id: String) -> UploadStatus? {
        return activeUploads[id]
    }

    func cancelUpload(id: String) {
        // You can add cancellation logic here
        activeUploads.removeValue(forKey: id)
    }
}

// MARK: - Upload Status
struct UploadStatus: Identifiable {
    let id: String
    var progress: Double
    var status: UploadState
    var firebaseURL: String?
    var error: Error?

    enum UploadState {
        case uploading, completed, failed
    }
}


enum VideoQuality {
    case low, medium, high

    var presetName: String {
        switch self {
        case .low:
            return "640x480"      // 480p
        case .medium:
            return "1280x720"    // 720p
        case .high:
            return "1920x1080"   // 1080p
        }
    }

    var displayName: String {
        switch self {
        case .low: return "480p"
        case .medium: return "720p"
        case .high: return "1080p"
        }
    }

    var estimatedFileSize: String {
        switch self {
        case .low: return "~5-15 MB"
        case .medium: return "~15-50 MB"
        case .high: return "~50-150 MB"
        }
    }

    var uploadTimeEstimate: String {
        switch self {
        case .low: return "~10-30 seconds"
        case .medium: return "~30-90 seconds"
        case .high: return "~90-300 seconds"
        }
    }
}
