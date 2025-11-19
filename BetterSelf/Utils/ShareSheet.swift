//
//  ShareSheet.swift
//  BetterSelf
//
//  A lightweight wrapper around UIActivityViewController for sharing items.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}




struct ShareURL: Identifiable {
    let id: UUID
    let url: URL

    init(_ url: URL) {
        self.id = UUID()
        self.url = url
    }

}
