import Foundation

/// Flip `enabled` to redirect UAT tag script URLs to local dev servers.
enum DevUrlOverrides {
    static let enabled = false

    private static let localKetchSdk: [String: String] = [
        "https://cdn.uat.ketchjs.com/ketchtag/stable/v2.12/ketch-sdk.js": "http://localhost:9000/ketch-sdk.js",
        "ketch-sdk.js": "http://localhost:9000/ketch-sdk.js",
    ]

    static let forSimulator = localKetchSdk
    static let forDevice = localKetchSdk
}
