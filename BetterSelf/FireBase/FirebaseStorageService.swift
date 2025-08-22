import Foundation
import FirebaseStorage
import FirebaseCore
import UIKit

class FirebaseStorageService: ObservableObject {
    static let shared = FirebaseStorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    // Upload video to Firebase Storage
    func uploadVideo(videoURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let fileName = "\(UUID().uuidString).mov"
        let videoRef = storage.reference().child("videos/\(fileName)")
        
        // Convert video to Data
        do {
            let videoData = try Data(contentsOf: videoURL)
            
            // Upload video data
            let metadata = StorageMetadata()
            metadata.contentType = "video/quicktime"
            
            videoRef.putData(videoData, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Get download URL
                videoRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    if let downloadURL = url {
                        completion(.success(downloadURL.absoluteString))
                    } else {
                        completion(.failure(NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }

    }
    
    // Download video from Firebase Storage
    func downloadVideo(firebaseURL: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: firebaseURL) else {
            completion(.failure(NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase URL"])))
            return
        }
        
        // For now, we'll use the Firebase URL directly since it's accessible
        // In a production app, you might want to cache videos locally
        completion(.success(url))
    }
    
    // Delete video from Firebase Storage
    func deleteVideo(firebaseURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: firebaseURL) else {
            completion(.failure(NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase URL"])))
            return
        }
        
        // Extract the path from the Firebase URL
        // Firebase URL structure: https://firebasestorage.googleapis.com:443/v0/b/bucket-name/o/path/to/file
        // We need to extract just the path part after /o/
        let pathComponents = url.pathComponents
        if let oIndex = pathComponents.firstIndex(of: "o"), oIndex + 1 < pathComponents.count {
            let path = pathComponents[(oIndex + 1)...].joined(separator: "/")
            let videoRef = storage.reference().child(path)
            
            videoRef.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            completion(.failure(NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase Storage URL format"])))
        }
    }
}

