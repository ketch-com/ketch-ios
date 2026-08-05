//
//  PreferenceQR.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// ketch-types `GetPreferenceQRRequest`
    public struct PreferenceQRRequest {
        public let organizationCode: String
        public let propertyCode: String
        public let environmentCode: String?
        public let imageSize: Int?
        public let path: String?
        public let backgroundColor: String?
        public let foregroundColor: String?
        public let parameters: [String: String]

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String? = nil,
            imageSize: Int? = nil,
            path: String? = nil,
            backgroundColor: String? = nil,
            foregroundColor: String? = nil,
            parameters: [String: String] = [:]
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.imageSize = imageSize
            self.path = path
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.parameters = parameters
        }
    }
}
