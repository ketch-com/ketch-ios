//
//  InvokeRight.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct InvokeRightConfig: Codable {
        public let propertyCode: String
        public let environmentCode: String
        public let jurisdictionCode: String
        public let invokedAt: Int?
        public let identities: [String: String]
        public let rightCode: String?
        public let user: User

        public init(
            propertyCode: String,
            environmentCode: String,
            jurisdictionCode: String,
            invokedAt: Int?,
            identities: [String: String],
            rightCode: String?,
            user: User
        ) {
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.jurisdictionCode = jurisdictionCode
            self.invokedAt = invokedAt
            self.identities = identities
            self.rightCode = rightCode
            self.user = user
        }
    }
}

extension KetchSDK {
    /// ketch-types `InvokeRightRequest`
    public struct InvokeRightRequest: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String
        public let environmentCode: String
        public let identities: [String: String]
        public let invokedAt: Int?
        public let jurisdictionCode: String
        public let rightCode: String
        public let user: DataSubject
        public let recaptchaToken: String?
        public let regionCode: String?
        public let isAuthenticated: Bool?

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String,
            identities: [String: String],
            jurisdictionCode: String,
            rightCode: String,
            user: DataSubject,
            controllerCode: String? = nil,
            invokedAt: Int? = nil,
            recaptchaToken: String? = nil,
            regionCode: String? = nil,
            isAuthenticated: Bool? = nil
        ) {
            self.organizationCode = organizationCode
            self.controllerCode = controllerCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.identities = identities
            self.invokedAt = invokedAt
            self.jurisdictionCode = jurisdictionCode
            self.rightCode = rightCode
            self.user = user
            self.recaptchaToken = recaptchaToken
            self.regionCode = regionCode
            self.isAuthenticated = isAuthenticated
        }
    }

    /// ketch-types `DataSubject`
    public struct DataSubject: Codable {
        public let email: String
        public let firstName: String
        public let lastName: String
        public let country: String?
        public let stateRegion: String?
        public let city: String?
        public let description: String?
        public let phone: String?
        public let postalCode: String?
        public let addressLine1: String?
        public let addressLine2: String?

        public init(
            email: String,
            firstName: String,
            lastName: String,
            country: String? = nil,
            stateRegion: String? = nil,
            city: String? = nil,
            description: String? = nil,
            phone: String? = nil,
            postalCode: String? = nil,
            addressLine1: String? = nil,
            addressLine2: String? = nil
        ) {
            self.email = email
            self.firstName = firstName
            self.lastName = lastName
            self.country = country
            self.stateRegion = stateRegion
            self.city = city
            self.description = description
            self.phone = phone
            self.postalCode = postalCode
            self.addressLine1 = addressLine1
            self.addressLine2 = addressLine2
        }
    }
}

extension KetchSDK.InvokeRightRequest {
    /// Builds a headless request from the legacy `InvokeRightConfig` (WebView-era shape).
    init(organizationCode: String, config: KetchSDK.InvokeRightConfig) {
        let user = config.user
        self.init(
            organizationCode: organizationCode,
            propertyCode: config.propertyCode,
            environmentCode: config.environmentCode,
            identities: config.identities,
            jurisdictionCode: config.jurisdictionCode,
            rightCode: config.rightCode ?? "",
            user: KetchSDK.DataSubject(
                email: user.email,
                firstName: user.first,
                lastName: user.last,
                country: user.country,
                stateRegion: user.stateRegion,
                description: user.description,
                phone: user.phone,
                postalCode: user.postalCode,
                addressLine1: user.addressLine1,
                addressLine2: user.addressLine2
            ),
            invokedAt: config.invokedAt,
            regionCode: nil
        )
    }
}

extension KetchSDK.InvokeRightConfig {
    public struct User: Codable {
        public let email: String
        public let first: String
        public let last: String
        public let country: String?
        public let stateRegion: String?
        public let description: String?
        public let phone: String?
        public let postalCode: String?
        public let addressLine1: String?
        public let addressLine2: String?

        public init(
            email: String,
            first: String,
            last: String,
            country: String?,
            stateRegion: String?,
            description: String?,
            phone: String?,
            postalCode: String?,
            addressLine1: String?,
            addressLine2: String?
        ) {
            self.email = email
            self.first = first
            self.last = last
            self.country = country
            self.stateRegion = stateRegion
            self.description = description
            self.phone = phone
            self.postalCode = postalCode
            self.addressLine1 = addressLine1
            self.addressLine2 = addressLine2
        }
    }
}
