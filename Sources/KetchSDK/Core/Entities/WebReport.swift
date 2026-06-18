//
//  WebReport.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// ketch-types `WebReportRequest`
    public struct WebReportRequest: Codable {
        public let type: String
        public let age: Int
        public let url: String
        public let userAgent: String
        public let body: [String: String]

        enum CodingKeys: String, CodingKey {
            case type
            case age
            case url
            case userAgent = "user_agent"
            case body
        }

        public init(
            type: String,
            age: Int,
            url: String,
            userAgent: String,
            body: [String: String]
        ) {
            self.type = type
            self.age = age
            self.url = url
            self.userAgent = userAgent
            self.body = body
        }
    }
}
