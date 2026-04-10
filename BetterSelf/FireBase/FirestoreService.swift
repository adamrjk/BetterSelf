import Foundation
import FirebaseFirestore

final class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}
    
    
    @discardableResult
    func storeReminder(_ reminder: Reminder) async throws -> String {
        guard let jsonString = encode(reminder) else {
            throw NSError(domain: "FirestoreService", code: -10, userInfo: [NSLocalizedDescriptionKey: "Failed to encode reminder to JSON string"])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "FirestoreService", code: -11, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to Data"])
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDict = jsonObject as? [String: Any] else {
            throw NSError(domain: "FirestoreService", code: -12, userInfo: [NSLocalizedDescriptionKey: "Encoded JSON is not an object"])
        }

        let id = reminder.shareID ?? generateShortID()
        reminder.shareID = id

        let documentId = try await addDocument(
            to: "sharedReminders",
            withId: id,
            data: jsonDict,
            addTimestamps: true,
            ttlDays: 90
        )

        // Build internal deep link for the newly created shared reminder
        let link = "https://bettermyself.app/share/\(documentId)"
        return link
    }

    func generateShortID(length: Int = 6) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""
        for _ in 0..<length {
            result.append(chars.randomElement()!)
        }
        return result
    }


    @MainActor
    func receiveReminder(_ docId: String) async throws -> Reminder? {
        let data = try await fetchJSON(id: docId)
        return decode(data)
    }


    // Add a document with an auto-generated ID to a collection
    // Returns the created document ID
    @discardableResult
    func addDocument(
        to collectionPath: String,
        withId documentId: String? = nil,
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

        if let documentId = documentId {
            let documentPath = "\(collectionPath)/\(documentId)"
            try await setDocument(
                at: documentPath,
                data: data,
                merge: false,
                addTimestamps: false,
                ttlDays: nil
            )
            return documentId
        } else {
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

    // Fetch a document by ID and return its JSON data (Data)
    // Default collection is "sharedReminders"
    func fetchJSON(
        from collectionPath: String = "sharedReminders",
        id documentId: String
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            db.collection(collectionPath).document(documentId).getDocument { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    continuation.resume(throwing: NSError(
                        domain: "FirestoreService",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Document not found"]
                    ))
                    return
                }

                guard let raw = snapshot.data() else {
                    continuation.resume(throwing: NSError(
                        domain: "FirestoreService",
                        code: -20,
                        userInfo: [NSLocalizedDescriptionKey: "Empty document data"]
                    ))
                    return
                }

                // Convert Firestore types to JSON-safe values (e.g., Timestamp -> ISO string)
                var jsonObject: [String: Any] = [:]
                let iso = ISO8601DateFormatter()
                for (key, value) in raw {
                    if let ts = value as? Timestamp {
                        jsonObject[key] = iso.string(from: ts.dateValue())
                    } else if JSONSerialization.isValidJSONObject([key: value]) {
                        jsonObject[key] = value
                    }
                }

                do {
                    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }


    func encode(_ reminder: Reminder) -> String? {
        let shared = SharedReminder(
            id: reminder.id,
            title: reminder.title,
            type: reminder.type.rawValue,
            text: reminder.text,
            photo: reminder.photoURL,
            video: reminder.firebaseVideoURL,
            link: reminder.link,
            time: reminder.time,
            isFront: reminder.isFront
        )

        if let encoded = try? JSONEncoder().encode(shared){
            if let json = String(data: encoded, encoding: .utf8){
                return json
            }
            else {
                print("Failed to create the String")
                return nil
            }


        }
        else {
            print("Failed encoding")
            return nil
        }
        
    }




@MainActor
func decode(_ data: Data) -> Reminder? {
    guard let decoded = try? JSONDecoder().decode(SharedReminder.self, from: data) else {
        print("Failed to decode")
        return nil
    }

    let reminder = Reminder(
        title: decoded.title,
        type: ReminderType(rawValue: decoded.type) ?? .InstantInsight,
        text: decoded.text,
        photoURL: decoded.photo.isEmpty ? nil : decoded.photo,
        firebaseVideoURL: decoded.video.isEmpty ? nil : decoded.video,
        link: decoded.link
    )
    reminder.isFront = decoded.isFront
    reminder.time = decoded.time
    return reminder






    }
}


