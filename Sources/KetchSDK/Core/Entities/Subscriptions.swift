//
//  Subscriptions.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// ketch-types `GetSubscriptionsRequest` / `SetSubscriptionsRequest`
    public struct SubscriptionsRequest: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String?
        public let environmentCode: String?
        public let identities: [String: String]?
        public let topics: [String: [String: String]]?
        public let controls: [String: [String: String]]?
        public let collectedAt: Int?
        public let jurisdictionCode: String?
        public let regionCode: String?

        public init(
            organizationCode: String,
            propertyCode: String? = nil,
            environmentCode: String? = nil,
            identities: [String: String]? = nil,
            topics: [String: [String: String]]? = nil,
            controls: [String: [String: String]]? = nil,
            controllerCode: String? = nil,
            collectedAt: Int? = nil,
            jurisdictionCode: String? = nil,
            regionCode: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.identities = identities
            self.topics = topics
            self.controls = controls
            self.controllerCode = controllerCode
            self.collectedAt = collectedAt
            self.jurisdictionCode = jurisdictionCode
            self.regionCode = regionCode
        }
    }

    /// ketch-types `GetSubscriptionsResponse`
    public typealias SubscriptionsResponse = SubscriptionsRequest
}
