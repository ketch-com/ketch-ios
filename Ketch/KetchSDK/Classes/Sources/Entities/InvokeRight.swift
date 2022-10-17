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
    }
}
