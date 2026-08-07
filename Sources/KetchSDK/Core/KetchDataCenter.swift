//
//  KetchDataCenter.swift
//  KetchSDK
//

import Foundation

/// Ketch CDN region for headless and WebView API calls.
public enum KetchDataCenter: String, Codable, Sendable {
    case us
    case eu
    case uat

    /// web/v3 base URL for this region (matches Flutter / React Native maps).
    public var baseURL: URL {
        URL(string: Self.baseURLString[self]!)!
    }

    private static let baseURLString: [KetchDataCenter: String] = [
        .us: "https://global.ketchcdn.com/web/v3",
        .eu: "https://eu.ketchcdn.com/web/v3",
        .uat: "https://dev.ketchcdn.com/web/v3",
    ]
}
