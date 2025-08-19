import Foundation
import FirebaseCore

class FirebaseConfig {
    static func configure() {
        // Make sure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}
