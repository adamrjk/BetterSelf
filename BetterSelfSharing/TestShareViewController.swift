//
//  TestShareViewController.swift
//  BetterSelfSharing
//
//  Created by Adam Damou on 15/09/2025.
//

import UIKit
import Social

class TestShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        // Show an alert to confirm it's working
        let alert = UIAlertController(title: "BetterSelf", message: "Share extension is working! Content: \(self.contentText ?? "No text")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Complete the extension
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        })
        
        present(alert, animated: true)
    }

    override func didSelectCancel() {
        // Just cancel
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
}
