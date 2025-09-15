//
//  SimpleShareViewController.swift
//  BetterSelfSharing
//
//  Created by Adam Damou on 15/09/2025.
//

import UIKit
import Social

class SimpleShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        // Simply launch the main app
        launchMainApp()
        
        // Complete the extension
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func didSelectCancel() {
        // Just cancel
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
    
    private func launchMainApp() {
        // Launch the main app using URL scheme
        if let url = URL(string: "betterself://share") {
            var responder = self as UIResponder?
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url, options: [:], completionHandler: nil)
                    break
                }
                responder = responder?.next
            }
        }
    }
}
