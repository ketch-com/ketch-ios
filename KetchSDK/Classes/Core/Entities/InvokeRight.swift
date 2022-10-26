//
//  InvokeRight.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 12.10.2022.
//

import Foundation

extension KetchSDK {
    public struct InvokeRightConfig: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String
        public let environmentCode: String
        public let identities: [String: String]
        public let invokedAt: Int?
        public let jurisdictionCode: String
        public let rightCode: String
        public let user: User

        public init(
            organizationCode: String,
            controllerCode: String?,
            propertyCode: String,
            environmentCode: String,
            identities: [String: String],
            invokedAt: Int?,
            jurisdictionCode: String,
            rightCode: String,
            user: User
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
