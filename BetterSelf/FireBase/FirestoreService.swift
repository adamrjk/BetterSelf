import Foundation
import FirebaseFirestore 

final class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // Add a document with an auto-generated ID to a collection
    // Returns the created document ID
    @discardableResult
    func addDocument(
        to collectionPath: String,
        data inputData: [String: Any],
        addTimestamps: Bool = true,
        ttlDays: Int? = nil
    ) async throws -> String {
        var data = inputData
        if addTimestamps {
            if data["createdAt"] == nil { data["createdAt"] = FieldValue.serverTimestamp() }
            data["updatedAt"] = FieldValue.serverTimestamp()
        }
        if let ttlDays = ttlDays {
            let expiresAt = Date().addingTimeInterval(TimeInterval(ttlDays * 24 * 60 * 60))
            data["expiresAt"] = Timestamp(date: expiresAt)
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            var ref: DocumentReference? = nil
            ref = db.collection(collectionPath).addDocument(data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let id = ref?.documentID {
                    continuation.resume(returning: id)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing document ID"]))
                }
            }
        }
    }

    // Create or update a document at an explicit path
    func setDocument(
        at documentPath: String,
        data inputData: [String: Any],
        merge: Bool = true,
        addTimestamps: Bool = true,
        ttlDays: Int? = nil
    ) async throws {
        var data = inputData
        if addTimestamps {
            if data["createdAt"] == nil { data["createdAt"] = FieldValue.serverTimestamp() }
            data["updatedAt"] = FieldValue.serverTimestamp()
        }
        if let ttlDays = ttlDays {
            let expiresAt = Date().addingTimeInterval(TimeInterval(ttlDays * 24 * 60 * 60))
            data["expiresAt"] = Timestamp(date: expiresAt)
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.document(documentPath).setData(data, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // Convenience: load a local JSON file and write it as a document
    // If documentId is nil, an auto-ID document will be created in the collection
    @discardableResult
    func uploadJSON(
        from fileURL: URL,
        to collectionPath: String,
        documentId: String? = nil,
        merge: Bool = true,
        ttlDays: Int? = nil
    ) async throws -> String {
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data, options: [])

        guard var jsonDict = json as? [String: Any] else {
            throw NSError(domain: "FirestoreService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Top-level JSON must be an object"])
        }

        if let ttlDays = ttlDays {
            let expiresAt = Date().addingTimeInterval(TimeInterval(ttlDays * 24 * 60 * 60))
            jsonDict["expiresAt"] = Timestamp(date: expiresAt)
        }

        if let documentId = documentId {
            let documentPath = "\(collectionPath)/\(documentId)"
            try await setDocument(at: documentPath, data: jsonDict, merge: merge)
            return documentId
        } else {
            return try await addDocument(to: collectionPath, data: jsonDict)
        }
    }
}


