//
//  ProblemSolverManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 01/11/2025.
//

import SwiftUI

import FirebaseFunctions

class ProblemSolverManager: ObservableObject {
    private let functions = Functions.functions()

    static let shared = ProblemSolverManager()

    enum ProblemSolverError: Error {
        case emptyResponse
        case invalidFormat
        case decodeFailed
    }

    func solveProblem(_ input: String, reminders: [String]) async throws -> String {

        let payload: [String: Any] = [
            "text": input,
            "reminders": reminders
        ]

//        print("Payload:", payload)

        let anyResponse = try await call(function: "chooseReminder", payload: payload)

        // 1) If the function returned a full reminder payload
        if let chosenReminderTitle = anyResponse as? String {

            return chosenReminderTitle
        }

        print("Failed")
        throw ProblemSolverError.invalidFormat
    }

    private func call(function name: String, payload: [String: Any]) async throws -> Any {
        try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable(name).call(payload) { result, error in
                if let error = error {
                    print("Got Error")
                    continuation.resume(throwing: error)
                    return
                }
                guard let any = result?.data else {
                    print("Empty Response")
                    continuation.resume(throwing: ProblemSolverError.emptyResponse)
                    return
                }
                continuation.resume(returning: any)
            }
        }
    }
}
