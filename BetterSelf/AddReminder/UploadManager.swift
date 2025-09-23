//
//  UploadManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import Foundation
import FirebaseStorage
import SwiftUI

class UploadManager: ObservableObject {
    

    static let shared = UploadManager()

    @Published var activeUploads: [String: UploadStatus] = [:]

    @StateObject var color = ColorManager.shared

    private init() {}

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
