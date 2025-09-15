//
//  ShareViewController.swift
//  BetterSelfSharing
//
//  Created by Adam Damou on 15/09/2025.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        // Launch the main app immediately
        launchMainApp()
        
        // Complete the extension
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func didSelectCancel() {
        // Just cancel
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatically launch the app when the view loads
        launchMainApp()
        
        // Complete the extension immediately
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func launchMainApp() {
        // Try to launch the main app using URL scheme
        if let url = URL(string: "betterself://") {
            self.extensionContext?.open(url, completionHandler: { success in
                print("App launch result: \(success)")
            })
        }
    }
}