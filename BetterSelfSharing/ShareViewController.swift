import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool { true }

    override func didSelectPost() {
        forwardContent()
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func didSelectCancel() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    override func configurationItems() -> [Any]! { [] }

    private func forwardContentToMainApp() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else { return }

        var sharedString: String?

        for provider in item.attachments ?? [] {
            if provider.hasItemConformingToTypeIdentifier("public.url") {
                provider.loadItem(forTypeIdentifier: "public.url", options: nil) { data, error in
                    if let url = data as? URL {
                        sharedString = url.absoluteString
                        self.saveToAppGroup(sharedString!)
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier("public.text") {
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, error in
                    if let text = data as? String {
                        sharedString = text
                        self.saveToAppGroup(sharedString!)
                    }
                }
            }
        }
    }

    private func saveToAppGroup(_ content: String) {
        if let userDefaults = UserDefaults(suiteName: "group.adam.betterself") {
            userDefaults.set(content, forKey: "sharedContent")
            userDefaults.synchronize()
        }
    }
    private func forwardContent() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else { return }

        for provider in item.attachments ?? [] {
            if provider.hasItemConformingToTypeIdentifier("public.url") {
                provider.loadItem(forTypeIdentifier: "public.url", options: nil) { data, error in
                    if let url = data as? URL {
                        let userDefaults = UserDefaults(suiteName: "group.adam.betterself")
                        userDefaults?.set(url.absoluteString, forKey: "sharedContent")
                        userDefaults?.synchronize()
                    }
                }
            }
        }
    }
}
