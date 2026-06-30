//
//  FullConfigurationRequest.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// Parameters for v3 `getFullConfiguration` (ketch-types `GetFullConfigurationRequest`).
    public struct FullConfigurationRequest: Sendable {
        public let organizationCode: String
        public let propertyCode: String
        public let environmentCode: String?
        public let jurisdictionCode: String?
        public let languageCode: String?
        public let hash: String?

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String? = nil,
            jurisdictionCode: String? = nil,
            languageCode: String? = nil,
            hash: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.jurisdictionCode = jurisdictionCode
            self.languageCode = languageCode
            self.hash = hash
        }
    }
}
