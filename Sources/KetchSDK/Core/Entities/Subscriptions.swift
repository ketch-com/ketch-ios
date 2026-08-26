//
//  Subscriptions.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public enum SubscriptionStatus: String, Codable {
        case granted
        case denied
    }

    /// How one contact method is set for a topic.
    public struct SubscriptionTopicContactMethodSetting: Codable, Equatable {
        public let status: SubscriptionStatus

        public init(status: SubscriptionStatus) {
            self.status = status
        }
    }

    /// Contact method code to the setting for that method.
    public typealias SubscriptionTopicSetting = [String: SubscriptionTopicContactMethodSetting]

    public struct SubscriptionsRequest: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String?
        public let environmentCode: String?
        public let identities: [String: String]?
        /// Topic code to its per-contact-method settings, e.g. `marketing_emails -> email -> granted`.
        public let topics: [String: SubscriptionTopicSetting]?
        public let controls: [String: [String: String]]?
        public let collectedAt: Int?
        public let jurisdictionCode: String?
        public let regionCode: String?

        public init(
            organizationCode: String,
            propertyCode: String? = nil,
            environmentCode: String? = nil,
            identities: [String: String]? = nil,
            topics: [String: SubscriptionTopicSetting]? = nil,
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

    public struct SubscriptionsResponse: Codable {
        public let controllerCode: String?
        public let propertyCode: String?
        public let environmentCode: String?
        public let identities: [String: String]?
        public let topics: [String: SubscriptionTopicSetting]?
        public let controls: [String: [String: String]]?
        public let collectedAt: Int?
        public let jurisdictionCode: String?
        public let regionCode: String?
    }
}
