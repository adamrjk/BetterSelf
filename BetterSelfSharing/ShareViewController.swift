import UIKit
import Social
import CoreServices
import UniformTypeIdentifiers
import SwiftUI



class ShareViewController: UIViewController {
    private var appURLString = "betterself://home?url="
    private let groupName = "group.adam.betterself"
    private let urlDefaultName = "incomingURL"

    override func loadView() {

           let view = UIView()
           view.backgroundColor = .clear
           view.frame = .zero
           self.view = view

    }




    func open(_ url: URL) -> Void {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                break
            }
            responder = responder?.next
        }
    }

    private var hasLaunched = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Get the all encompasing object that holds whatever was shared. If not, dismiss view.
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        // Check if object is of type text
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            handleIncomingText(itemProvider)
        // Check if object is of type URL
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            handleIncomingURL(itemProvider)
        } else {
            print("Error: No url or text found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: self.appURLString) else { return }
            self.open(url)

        })
    }

    private func handleIncomingURL(_ itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier){ (item, error) in
            if let error = error {
                print("Error loading URL: \(error.localizedDescription)")
                return
            }
            else{
                if let url = item as? URL {
                    print(url.absoluteString)
                    self.appURLString += url.absoluteString
                }else if let url = item as? NSURL, let urlString = url.absoluteString {
                    print(urlString)
                    self.appURLString += urlString
                }
                else if let str = item as? String, let url = URL(string: str) {
                    print(str)
                    self.appURLString += url.absoluteString
                }
                else {
                    print("Unsupported type:", type(of: item))
                }
                self.saveURLString(self.appURLString)
                self.openMainApp()

            }
        }
    }

    private func handleIncomingText(_ itemProvider: NSItemProvider){
        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
            if let error = error {
                print("Text-Error: \(error.localizedDescription)")
            }

            if let text = item as? String {
                do {
                    // Detect URLs in String
                    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(
                        in: text,
                        options: [],
                        range: NSRange(location: 0, length: text.utf16.count)
                    )
                    // Get first URL found
                    if let firstMatch = matches.first, let range = Range(firstMatch.range, in: text) {
                        self.appURLString += text[range]
                        self.saveURLString(self.appURLString)
                        self.openMainApp()
                    }
                } catch let error {
                    print("Do-Try Error: \(error.localizedDescription)")
                }
            }

            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    private func saveURLString(_ urlString: String) {
        UserDefaults(suiteName: self.groupName)?.set(urlString, forKey: self.urlDefaultName)
      }



}
//import UIKit
//import Social
//
//class ShareViewController: SLComposeServiceViewController {
//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post.
//        // Do the upload of the contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it dismisses the extension UI.
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem.
//        return []
//    }
//}
