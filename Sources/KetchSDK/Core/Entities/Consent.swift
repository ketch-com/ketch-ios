//
//  Consent.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct ConsentUpdate: Codable {
        public let organizationCode: String
        public let propertyCode: String
        public let environmentCode: String
        public let identities: [String: String]
        public let jurisdictionCode: String
        public let migrationOption: MigrationOption
        public let purposes: [String: PurposeAllowedLegalBasis]
        public let vendors: [String]?
        public let protocols: [String: String]?

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String,
            identities: [String: String],
            jurisdictionCode: String,
            migrationOption: MigrationOption,
            purposes: [String: PurposeAllowedLegalBasis],
            vendors: [String]?,
            protocols: [String: String]?
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.identities = identities
            self.jurisdictionCode = jurisdictionCode
            self.migrationOption = migrationOption
            self.purposes = purposes
            self.vendors = vendors
            self.protocols = protocols
        }
    }
}

extension KetchSDK.ConsentUpdate {
    public enum MigrationOption: String, Codable {
        case migrateDefault = "MIGRATE_DEFAULT"
        case migrateNever = "MIGRATE_NEVER"
        case migrateFromAllow = "MIGRATE_FROM_ALLOW"
        case migrateFromDeny = "MIGRATE_FROM_DENY"
        case migrateAlways = "MIGRATE_ALWAYS"
    }

    public struct PurposeAllowedLegalBasis: Codable {
        public let allowed: Bool
        public let legalBasisCode: String

        public init(
            allowed: Bool,
            legalBasisCode: String
        ) {
            self.allowed = allowed
            self.legalBasisCode = legalBasisCode
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(allowed.description, forKey: .allowed)
            try container.encode(legalBasisCode, forKey: .legalBasisCode)
        }
    }
}

extension KetchSDK {
    public struct ConsentConfig: Codable {
        public let organizationCode: String
        public let propertyCode: String
        public let environmentCode: String
        public let jurisdictionCode: String
        public let identities: [String: String]
        public let purposes: [String: PurposeLegalBasis]

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String,
            jurisdictionCode: String,
            identities: [String: String],
            purposes: [String: PurposeLegalBasis]
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.jurisdictionCode = jurisdictionCode
            self.identities = identities
            self.purposes = purposes
        }
    }
}

extension KetchSDK.ConsentConfig {
    public struct PurposeLegalBasis: Codable {
        public let legalBasisCode: String

        public init(
            legalBasisCode: String
        ) {
            self.legalBasisCode = legalBasisCode
        }
    }
}

extension KetchSDK {
    public struct ConsentStatus: Codable {
        public let purposes: [String: Bool]?
        public let vendors: [String]?
        public var protocols: [String: String]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            purposes = try? container.decodeIfPresent([String: Bool].self, forKey: .purposes)
            vendors = try? container.decodeIfPresent([String].self, forKey: .vendors)
            protocols = try? container.decodeIfPresent([String: String].self, forKey: .protocols)

        }

        public init(
            purposes: [String: Bool]?,
            vendors: [String]?,
            protocols: [String: String]?
        ) {
            self.purposes = purposes
            self.vendors = vendors
            self.protocols = protocols
        }
    }
}
