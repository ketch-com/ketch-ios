//
//  InvokeRight.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct InvokeRightConfig: Codable {
        public let controllerCode: String?
        public let propertyCode: String
        public let environmentCode: String
        public let jurisdictionCode: String
        public let invokedAt: Int?
        public let identities: [String: String]
        public let rightCode: String?
        public let user: User

        public init(
            controllerCode: String?,
            propertyCode: String,
            environmentCode: String,
            jurisdictionCode: String,
            invokedAt: Int?,
            identities: [String: String],
            rightCode: String?,
            user: User
        ) {
            self.controllerCode = controllerCode
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
