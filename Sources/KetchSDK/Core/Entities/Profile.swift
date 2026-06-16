//
//  Profile.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// ketch-types `ProfilePreferencesIdentity`
    public struct ProfilePreferencesIdentity: Codable {
        public let identitySpace: String
        public let identityValue: String

        public init(identitySpace: String, identityValue: String) {
            self.identitySpace = identitySpace
            self.identityValue = identityValue
        }
    }

    /// ketch-types `ProfilePreferencesAttribute`
    public struct ProfilePreferencesAttribute: Codable {
        public let attributeCode: String
        public let attributeValue: String?
        public let source: String

        public init(attributeCode: String, attributeValue: String? = nil, source: String) {
            self.attributeCode = attributeCode
            self.attributeValue = attributeValue
            self.source = source
        }
    }

    /// ketch-types `ProfilePreferencesContext`
    public struct ProfilePreferencesContext: Codable {
        public let source: String
        public let updatedAt: Int?
        public let configId: String?

        public init(source: String, updatedAt: Int? = nil, configId: String? = nil) {
            self.source = source
            self.updatedAt = updatedAt
            self.configId = configId
        }
    }

    /// ketch-types `GetProfileRequest`
    public struct GetProfileRequest: Codable {
        public let organizationCode: String
        public let propertyCode: String
        public let jurisdictionCode: String
        public let languageCode: String
        public let identities: [ProfilePreferencesIdentity]
        public let controllerCode: String?
        public let environmentCode: String?
        public let accountID: String?
        public let regionCode: String?

        public init(
            organizationCode: String,
            propertyCode: String,
            jurisdictionCode: String,
            languageCode: String,
            identities: [ProfilePreferencesIdentity],
            controllerCode: String? = nil,
            environmentCode: String? = nil,
            accountID: String? = nil,
            regionCode: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.jurisdictionCode = jurisdictionCode
            self.languageCode = languageCode
            self.identities = identities
            self.controllerCode = controllerCode
            self.environmentCode = environmentCode
            self.accountID = accountID
            self.regionCode = regionCode
        }
    }

    /// ketch-types `GetProfileResponse`
    public struct GetProfileResponse: Codable {
        public let controllerCode: String?
        public let propertyCode: String?
        public let environmentCode: String?
        public let jurisdictionCode: String?
        public let regionCode: String?
        public let attributes: [ProfilePreferencesAttribute]?
    }

    /// ketch-types `PutProfileRequest`
    public struct PutProfileRequest: Codable {
        public let organizationCode: String
        public let propertyCode: String
        public let jurisdictionCode: String
        public let languageCode: String
        public let identities: [ProfilePreferencesIdentity]
        public let context: ProfilePreferencesContext
        public let controllerCode: String?
        public let environmentCode: String?
        public let attributes: [ProfilePreferencesAttribute]?
        public let accountId: String?
        public let regionCode: String?

        public init(
            organizationCode: String,
            propertyCode: String,
            jurisdictionCode: String,
            languageCode: String,
            identities: [ProfilePreferencesIdentity],
            context: ProfilePreferencesContext,
            controllerCode: String? = nil,
            environmentCode: String? = nil,
            attributes: [ProfilePreferencesAttribute]? = nil,
            accountId: String? = nil,
            regionCode: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.jurisdictionCode = jurisdictionCode
            self.languageCode = languageCode
            self.identities = identities
            self.context = context
            self.controllerCode = controllerCode
            self.environmentCode = environmentCode
            self.attributes = attributes
            self.accountId = accountId
            self.regionCode = regionCode
        }
    }
}
